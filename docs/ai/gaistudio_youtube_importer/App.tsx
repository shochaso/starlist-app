// Source: Google AI Studio Export
// Imported for reference (YouTube OCR + URL Enrichment Prototype)

import React, { useState, useCallback, useRef, ChangeEvent, useEffect } from 'react';
import { ImageUploadCard } from './components/ImageUploadCard';
import { OcrResultCard } from './components/OcrResultCard';
import { ExtractedResultCard } from './components/ExtractedResultCard';
import { performOcr } from './services/ocrService';
import { parseOcrText } from './services/parserService';
import { findYouTubeUrl } from './services/linkEnricherService';
import { OcrState, ParsedVideo, Notification } from './types';

const App: React.FC = () => {
  const [state, setState] = useState<OcrState>({
    imageFile: null,
    imageUrl: null,
    ocrText: '',
    isRunning: false,
    error: null,
  });

  const [parsedVideos, setParsedVideos] = useState<ParsedVideo[]>([]);
  const [isBulkLinking, setIsBulkLinking] = useState(false);
  const [isUploading, setIsUploading] = useState(false);
  const [isPublishing, setIsPublishing] = useState(false);
  const [notification, setNotification] = useState<Notification | null>(null);
  const [shouldAutoEnrich, setShouldAutoEnrich] = useState(false);
  const [enrichProgress, setEnrichProgress] = useState({ current: 0, total: 0 });
  const [uploadCompleted, setUploadCompleted] = useState(false);
  const [publishCompleted, setPublishCompleted] = useState(false);
  const fileInputRef = useRef<HTMLInputElement>(null);

  useEffect(() => {
    const newVideos = parseOcrText(state.ocrText);
    
    setParsedVideos(currentVideos => {
      const prevVideosById = new Map<string, ParsedVideo>(currentVideos.map(v => [v.id, v]));
      
      return newVideos.map(newVideo => {
        const prevVideo = prevVideosById.get(newVideo.id);
        // Preserve state if video already existed, otherwise use defaults
        return prevVideo 
          ? { 
              ...newVideo, 
              selected: prevVideo.selected, 
              isPublic: prevVideo.isPublic,
              videoUrl: prevVideo.videoUrl,
              isLinkLoading: prevVideo.isLinkLoading ?? false,
              matchScore: prevVideo.matchScore,
              matchReason: prevVideo.matchReason,
              enrichError: prevVideo.enrichError,
              isSaved: prevVideo.isSaved ?? false,
            } 
          : { 
              ...newVideo, 
              selected: false, 
              isPublic: false,
              videoUrl: null,
              isLinkLoading: false,
              matchScore: null,
              matchReason: null,
              enrichError: null,
              isSaved: false,
            };
      });
    });
  }, [state.ocrText]);

  const handleImageSelect = (event: ChangeEvent<HTMLInputElement>) => {
    const file = event.target.files?.[0];
    if (file) {
      if (state.imageUrl) {
        URL.revokeObjectURL(state.imageUrl);
      }
      setState(prevState => ({
        ...prevState,
        imageFile: file,
        imageUrl: URL.createObjectURL(file),
        error: null,
        ocrText: '',
      }));
      setUploadCompleted(false);
      setPublishCompleted(false);
    }
  };

  const handlePickImage = useCallback(() => {
    fileInputRef.current?.click();
  }, []);

  const handleRunOcr = useCallback(async () => {
    if (!state.imageFile) {
      setState(prevState => ({ ...prevState, error: '画像が選択されていません' }));
      return;
    }
    setState(prevState => ({ ...prevState, isRunning: true, error: null }));
    setUploadCompleted(false);
    setPublishCompleted(false);
    try {
      const text = await performOcr(state.imageFile);
      setState(prevState => ({ ...prevState, isRunning: false, ocrText: text }));
      if (text.trim()) {
        setShouldAutoEnrich(true);
      }
    } catch (err) {
      setState(prevState => ({ ...prevState, isRunning: false, error: 'OCR処理に失敗しました。' }));
    }
  }, [state.imageFile]);

  const handleClear = useCallback(() => {
    if (state.imageUrl) {
      URL.revokeObjectURL(state.imageUrl);
    }
    if (fileInputRef.current) {
      fileInputRef.current.value = "";
    }
    setState({
      imageFile: null,
      imageUrl: null,
      ocrText: '',
      isRunning: false,
      error: null,
    });
    setUploadCompleted(false);
    setPublishCompleted(false);
  }, [state.imageUrl]);
  
  const handleTextChange = (newText: string) => {
    setState(prevState => ({ ...prevState, ocrText: newText }));
  };

  const handleToggleSelected = (id: string) => {
    setParsedVideos(videos => 
      videos.map(v => (v.id === id ? { ...v, selected: !v.selected } : v))
    );
  };

  const handleTogglePublic = (id: string) => {
    setParsedVideos(videos => 
      videos.map(v => (v.id === id ? { ...v, isPublic: !v.isPublic } : v))
    );
  };

  const handleRemove = (id: string) => {
    setParsedVideos(videos => videos.filter(v => v.id !== id));
  };

  const handleSelectAll = (select: boolean) => {
    setParsedVideos(videos => {
      // 未保存(DB登録前)のビデオがあるかチェック
      const hasUnsaved = videos.some(v => !v.isSaved);
      
      if (hasUnsaved) {
        // DB登録フェーズ: 未保存のアイテムの選択状態(selected)を切り替える
        // 保存済みのアイテムは操作しない
        return videos.map(v => 
          v.isSaved ? v : { ...v, selected: select }
        );
      } else {
        // 公開設定フェーズ: 全て保存済みの場合、公開設定(isPublic)を切り替える
        return videos.map(v => ({ ...v, isPublic: select }));
      }
    });
  };

  const enrichOneVideo = useCallback(async (video: ParsedVideo) => {
    setParsedVideos(current => current.map(v => {
      if (v.id === video.id) {
        return { ...v, isLinkLoading: true, enrichError: null };
      }
      return v;
    }));

    const enrichedData = await findYouTubeUrl(video.title, video.channel);

    setParsedVideos(current => current.map(v => {
      if (v.id === video.id) {
        const hasUrl = !!enrichedData?.url;
        return {
          ...v,
          videoUrl: enrichedData?.url || null,
          matchScore: enrichedData?.score || null,
          matchReason: enrichedData?.reason || null,
          isLinkLoading: false,
          enrichError: hasUrl ? null : (enrichedData?.reason || 'URLの取得に失敗しました'),
        };
      }
      return v;
    }));
  }, []);

  const handleEnrichBulk = useCallback(async (all: boolean) => {
    setIsBulkLinking(true);
    const videosToProcess = parsedVideos.filter(v => (all || v.selected) && !v.videoUrl);
    setEnrichProgress({ current: 0, total: videosToProcess.length });

    let processedCount = 0;
    for (const video of videosToProcess) {
        await enrichOneVideo(video);
        processedCount++;
        setEnrichProgress({ current: processedCount, total: videosToProcess.length });
        // Rate limit cushion: 2 seconds to prevent "Rpc failed due to xhr error"
        await new Promise(resolve => setTimeout(resolve, 2000)); 
    }
    setIsBulkLinking(false);
  }, [parsedVideos, enrichOneVideo]);

  // This effect triggers the automatic URL enrichment after OCR is successfully run.
  useEffect(() => {
    if (shouldAutoEnrich && parsedVideos.length > 0) {
      setNotification({ message: 'OCR完了。動画URLの自動取得を開始します...', type: 'success' });
      const timer = setTimeout(() => {
        setNotification(prev => 
          prev?.message === 'OCR完了。動画URLの自動取得を開始します...' ? null : prev
        );
      }, 4000);

      handleEnrichBulk(true);
      setShouldAutoEnrich(false);

      return () => clearTimeout(timer);
    }
  }, [parsedVideos, shouldAutoEnrich, handleEnrichBulk]);

  const handleUpload = async () => {
    const videosToUpload = parsedVideos.filter(v => v.selected && !v.isSaved);
    if (videosToUpload.length === 0) {
      setNotification({ message: '登録対象の動画が選択されていません。', type: 'error' });
      setTimeout(() => setNotification(null), 3000);
      return;
    }

    setIsUploading(true);
    setNotification(null);
    try {
      // Simulate API call to a backend like Supabase
      await new Promise(resolve => setTimeout(resolve, 1500));

      setParsedVideos(currentVideos =>
        currentVideos.map(v =>
          videosToUpload.find(uploaded => uploaded.id === v.id)
            ? { ...v, isSaved: true, selected: false }
            : v
        )
      );
      
      setNotification({ message: `${videosToUpload.length} 件を登録しました`, type: 'success' });
      setUploadCompleted(true);

    } catch (error) {
      console.error("Upload failed:", error);
      setNotification({ message: '登録処理に失敗しました。', type: 'error' });
    } finally {
      setIsUploading(false);
      setTimeout(() => setNotification(null), 5000);
    }
  };

  const handlePublish = async () => {
    const videosToPublish = parsedVideos.filter(v => v.isPublic);
    if (videosToPublish.length === 0) {
      setNotification({ message: '公開対象のデータがありません。', type: 'error' });
      setTimeout(() => setNotification(null), 3000);
      return;
    }

    setIsPublishing(true);
    setNotification(null);
    try {
      // Simulate API call to publish data
      await new Promise(resolve => setTimeout(resolve, 1500));
      
      setNotification({ message: `${videosToPublish.length} 件を公開しました`, type: 'success' });
      setPublishCompleted(true);

    } catch (error) {
      console.error("Publish failed:", error);
      setNotification({ message: '公開処理に失敗しました。', type: 'error' });
    } finally {
      setIsPublishing(false);
      setTimeout(() => setNotification(null), 5000);
    }
  };

  return (
    <div className="min-h-screen bg-slate-100 text-slate-800 font-sans selection:bg-indigo-100 selection:text-indigo-800">
      <header className="bg-white/80 backdrop-blur-sm border-b border-slate-200 sticky top-0 z-30">
        <div className="max-w-5xl mx-auto px-4 sm:px-6 py-4 flex items-center justify-between">
          <div className="flex items-center gap-2">
            <h1 className="text-xl font-bold text-slate-900 tracking-tight">YouTube History Importer</h1>
            <span className="px-2 py-0.5 rounded-full bg-indigo-50 text-indigo-600 text-[10px] font-bold tracking-wide border border-indigo-100">BETA</span>
          </div>
          <div className="text-xs text-slate-500 font-medium">v0.1.0</div>
        </div>
      </header>
      
      <main className="max-w-5xl mx-auto px-4 sm:px-6 py-8 pb-32">
        <div className="space-y-8">
          <section>
            <ImageUploadCard 
              state={state}
              onPickImage={handlePickImage}
              onClear={handleClear}
              fileInputRef={fileInputRef}
              onImageSelect={handleImageSelect}
            />
          </section>
          
          <section>
             <OcrResultCard 
              ocrText={state.ocrText}
              onTextChange={handleTextChange}
              onRunOcr={handleRunOcr}
              isRunning={state.isRunning}
              isImageSelected={!!state.imageUrl}
            />
          </section>

          <section>
            <ExtractedResultCard
              videos={parsedVideos}
              isBulkLinking={isBulkLinking}
              isUploading={isUploading}
              isPublishing={isPublishing}
              notification={notification}
              enrichProgress={enrichProgress}
              uploadCompleted={uploadCompleted}
              publishCompleted={publishCompleted}
              onToggleSelected={handleToggleSelected}
              onTogglePublic={handleTogglePublic}
              onRemove={handleRemove}
              onSelectAll={handleSelectAll}
              onUpload={handleUpload}
              onPublish={handlePublish}
            />
          </section>
        </div>
      </main>
    </div>
  );
};

export default App;