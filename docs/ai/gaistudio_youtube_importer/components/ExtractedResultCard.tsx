// Source: Google AI Studio Export
// Imported for reference (YouTube OCR + URL Enrichment Prototype)

import React, { useState } from 'react';
import type { ParsedVideo, Notification } from '../types';
import { DeleteIcon, DoneAllIcon, RemoveDoneIcon, SpinnerIcon, CloudUploadIcon, ErrorIcon, CheckIcon, PageViewIcon, PublishIcon, LinkIcon } from './icons';
import { Switch } from './Switch';

interface ExtractedResultCardProps {
  videos: ParsedVideo[];
  isBulkLinking: boolean;
  isUploading: boolean;
  isPublishing: boolean;
  notification: Notification | null;
  enrichProgress: { current: number; total: number };
  uploadCompleted: boolean;
  publishCompleted: boolean;
  onToggleSelected: (id: string) => void;
  onTogglePublic: (id: string) => void;
  onRemove: (id: string) => void;
  onSelectAll: (select: boolean) => void;
  onUpload: () => void;
  onPublish: () => void;
}

export const ExtractedResultCard: React.FC<ExtractedResultCardProps> = ({
  videos,
  isBulkLinking,
  isUploading,
  isPublishing,
  notification,
  enrichProgress,
  uploadCompleted,
  publishCompleted,
  onToggleSelected,
  onTogglePublic,
  onRemove,
  onSelectAll,
  onUpload,
  onPublish,
}) => {
  const [showPublishModal, setShowPublishModal] = useState(false);
  
  const total = videos.length;
  const selectedCount = videos.filter(v => v.selected).length;
  const publicCount = videos.filter(v => v.isPublic).length;
  const isProcessing = isBulkLinking || isUploading || isPublishing;

  // Check if there are any unsaved videos to determine the mode of "Select All"
  const hasUnsaved = videos.some(v => !v.isSaved);
  const selectAllLabel = hasUnsaved ? "全選択" : "公開全選択";
  const selectAllTooltip = hasUnsaved ? "未登録の項目を全て選択" : "全ての項目の公開設定をON";

  const videosToPublish = videos.filter(v => v.isPublic);

  const handlePublishClick = () => {
    if (videosToPublish.length > 0 && !publishCompleted) {
      setShowPublishModal(true);
    }
  };

  const confirmPublish = () => {
    setShowPublishModal(false);
    onPublish();
  };

  return (
    <div className="w-full relative">
       <h2 className="text-lg font-bold text-slate-900 mb-4 flex items-center">
        <span className="flex items-center justify-center w-7 h-7 rounded-full bg-indigo-600 text-white text-sm font-bold mr-3 shadow-sm shadow-indigo-200">3</span>
        抽出結果の確認・編集
      </h2>

      <div className="bg-white rounded-xl shadow-sm border border-slate-200 overflow-hidden flex flex-col h-[800px]">
        
        {/* Header Toolbar */}
        <div className="p-4 border-b border-slate-200 bg-white sticky top-0 z-10 shadow-sm">
          <div className="flex flex-col xl:flex-row xl:items-center justify-between gap-4">
            
            {/* Left: Selection Tools */}
            <div className="flex items-center justify-between sm:justify-start gap-4">
               <div className="flex items-center gap-2 bg-slate-100 rounded-lg px-3 py-1.5">
                  <span className="text-xs font-bold text-slate-500">全件</span>
                  <span className="text-sm font-bold text-slate-900">{total}</span>
               </div>
               <div className="flex items-center gap-2">
                  <button
                    onClick={() => onSelectAll(true)}
                    disabled={isProcessing}
                    className="inline-flex items-center px-3 py-1.5 rounded-md text-xs font-bold text-indigo-600 bg-indigo-50 hover:bg-indigo-100 transition-colors disabled:opacity-50"
                    title={selectAllTooltip}
                  >
                    <DoneAllIcon className="h-4 w-4 mr-1" /> {selectAllLabel}
                  </button>
                  <button
                    onClick={() => onSelectAll(false)}
                    disabled={isProcessing}
                    className="inline-flex items-center px-3 py-1.5 rounded-md text-xs font-bold text-slate-500 hover:bg-slate-100 transition-colors disabled:opacity-50"
                    title="選択を全て解除"
                  >
                     <RemoveDoneIcon className="h-4 w-4 mr-1" /> 解除
                  </button>
               </div>
            </div>

            {/* Right: Main Actions */}
            <div className="flex items-center gap-3 w-full sm:w-auto overflow-x-auto pb-1 sm:pb-0">
               <button
                onClick={onUpload}
                disabled={isProcessing || selectedCount === 0}
                className="whitespace-nowrap flex-1 sm:flex-none inline-flex items-center justify-center px-5 py-2 border border-transparent text-xs font-bold rounded-lg text-white bg-slate-800 hover:bg-slate-900 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-slate-500 disabled:bg-slate-200 disabled:text-slate-400 disabled:cursor-not-allowed transition-all shadow-sm"
              >
                {isUploading ? <SpinnerIcon className="animate-spin -ml-1 mr-2 h-4 w-4" /> : <CloudUploadIcon className="-ml-1 mr-2 h-4 w-4" />}
                DB登録 ({selectedCount})
              </button>
              
              <div className="h-6 w-px bg-slate-200 mx-1 hidden sm:block"></div>

              <button
                  onClick={handlePublishClick}
                  disabled={isProcessing || publicCount === 0 || publishCompleted}
                  className="whitespace-nowrap flex-1 sm:flex-none inline-flex items-center justify-center px-5 py-2 border border-transparent text-xs font-bold rounded-lg text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500 disabled:bg-slate-200 disabled:text-slate-400 disabled:cursor-not-allowed transition-all shadow-sm"
                >
                  {isPublishing ? <SpinnerIcon className="animate-spin -ml-1 mr-2 h-4 w-4" /> : <PublishIcon className="-ml-1 mr-2 h-4 w-4" />}
                  公開 ({publicCount})
              </button>

              {publishCompleted && (
                <a
                  href="https://ai.studio/apps/drive/1ZqhNOw8B_7pACM8fXfJAsLCzHBi_0zFP"
                  className="whitespace-nowrap flex-1 sm:flex-none inline-flex items-center justify-center px-5 py-2 border border-transparent text-xs font-bold rounded-lg text-white bg-emerald-600 hover:bg-emerald-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-emerald-500 transition-all shadow-sm animate-fadeIn"
                >
                  <PageViewIcon className="-ml-1 mr-2 h-4 w-4" />
                  データベースを確認
                </a>
              )}
            </div>
          </div>
          
          {/* Progress Bar for Bulk Linking */}
          {isBulkLinking && (
             <div className="mt-4 relative">
                <div className="flex items-center justify-between text-[10px] font-bold text-indigo-600 mb-1 uppercase tracking-wide">
                   <span className="flex items-center"><SpinnerIcon className="animate-spin h-3 w-3 mr-1"/> URL取得中</span>
                   <span>{Math.round((enrichProgress.current / enrichProgress.total) * 100)}%</span>
                </div>
                <div className="w-full bg-indigo-100 rounded-full h-1">
                  <div 
                    className="bg-indigo-600 h-1 rounded-full transition-all duration-300 ease-out" 
                    style={{ width: `${(enrichProgress.current / enrichProgress.total) * 100}%` }}
                  ></div>
                </div>
             </div>
          )}
        </div>

        {/* Notification Banner */}
        {notification && (
          <div className={`px-6 py-3 text-sm font-medium flex items-center justify-center animate-slideDown ${notification.type === 'success' ? 'bg-emerald-50 text-emerald-700 border-b border-emerald-100' : 'bg-red-50 text-red-700 border-b border-red-100'}`}>
             {notification.type === 'success' ? <CheckIcon className="h-5 w-5 mr-2"/> : <ErrorIcon className="h-5 w-5 mr-2"/>}
             {notification.message}
          </div>
        )}

        {/* Card List Container */}
        <div className="flex-1 overflow-y-auto bg-slate-50 p-4">
          {videos.length === 0 ? (
            <div className="h-full flex flex-col items-center justify-center text-slate-400">
              <div className="w-16 h-16 rounded-full bg-slate-100 flex items-center justify-center mb-4">
                 <CloudUploadIcon className="h-8 w-8 text-slate-300" />
              </div>
              <p className="text-sm font-medium">データがありません</p>
              <p className="text-xs mt-1">画像をアップロードしてOCRを実行してください</p>
            </div>
          ) : (
            <div className="space-y-3">
              {videos.map(video => {
                const isSaved = !!video.isSaved;
                return (
                  <div 
                    key={video.id} 
                    className={`
                      relative bg-white rounded-lg border shadow-sm transition-all duration-200
                      ${video.selected ? 'border-indigo-300 ring-1 ring-indigo-100' : 'border-slate-200 hover:border-indigo-200 hover:shadow-md'}
                      ${isSaved ? 'bg-emerald-50/10 border-emerald-200' : ''}
                    `}
                  >
                    <div className="p-4 flex gap-4">
                      
                      {/* Checkbox Area */}
                      <div className="flex-shrink-0 pt-1">
                         {isSaved ? (
                             <div className="h-6 w-6 rounded-full bg-emerald-100 text-emerald-600 flex items-center justify-center border border-emerald-200" title="登録済み">
                               <CheckIcon className="h-4 w-4" />
                             </div>
                         ) : (
                           <div className="relative flex items-center justify-center">
                             <input
                               type="checkbox"
                               checked={video.selected}
                               onChange={() => onToggleSelected(video.id)}
                               className="peer h-6 w-6 rounded border-slate-300 text-indigo-600 focus:ring-indigo-500 cursor-pointer transition-all"
                               disabled={isProcessing}
                             />
                           </div>
                         )}
                      </div>

                      {/* Main Content */}
                      <div className="flex-1 min-w-0 grid grid-cols-1 md:grid-cols-12 gap-4 items-start">
                        
                        {/* Info: Title & Channel */}
                        <div className="md:col-span-7 lg:col-span-8 space-y-1">
                           <h3 className="text-sm font-bold text-slate-900 leading-snug break-words">
                             {video.videoUrl ? (
                               <a href={video.videoUrl} target="_blank" rel="noreferrer" className="group/link hover:text-indigo-600 transition-colors flex items-start gap-1">
                                 <span>{video.title}</span>
                                 <LinkIcon className="h-3.5 w-3.5 text-slate-400 group-hover/link:text-indigo-500 mt-0.5 flex-shrink-0 transition-colors" />
                               </a>
                             ) : (
                               video.title
                             )}
                           </h3>
                           <div className="flex items-center gap-2">
                             <p className="text-xs font-medium text-slate-500 px-2 py-0.5 bg-slate-100 rounded inline-block">{video.channel}</p>
                             
                             {/* Match Score Badge */}
                             {video.videoUrl && video.matchScore !== null && (
                               <span 
                                 className={`text-[10px] font-bold px-1.5 py-0.5 rounded border ${
                                   (video.matchScore || 0) > 0.8 
                                     ? 'bg-emerald-50 text-emerald-600 border-emerald-100' 
                                     : 'bg-amber-50 text-amber-600 border-amber-100'
                                 }`}
                               >
                                 一致率: {Math.round((video.matchScore || 0) * 100)}%
                               </span>
                             )}
                           </div>
                        </div>

                        {/* Actions & Status */}
                        <div className="md:col-span-5 lg:col-span-4 flex flex-row md:flex-col lg:flex-row items-center md:items-end lg:items-center justify-between md:justify-end gap-3 md:gap-2">
                           
                           {/* Status / Error Message */}
                           <div className="flex-1 md:flex-none text-right min-w-[80px]">
                             {video.isLinkLoading ? (
                               <span className="inline-flex items-center text-[10px] font-medium text-indigo-500 bg-indigo-50 px-2 py-1 rounded-full">
                                 <SpinnerIcon className="animate-spin h-3 w-3 mr-1"/> 検索中
                               </span>
                             ) : video.enrichError ? (
                               <span className="inline-flex items-center text-[10px] font-medium text-red-500 bg-red-50 px-2 py-1 rounded-full" title={video.enrichError}>
                                 <ErrorIcon className="h-3 w-3 mr-1" /> 取得失敗
                               </span>
                             ) : null}
                           </div>

                           <div className="h-4 w-px bg-slate-200 hidden lg:block"></div>

                           {/* Public Toggle */}
                           <div 
                              className={`flex items-center gap-2 transition-opacity ${!isSaved ? 'opacity-40 grayscale cursor-not-allowed' : ''}`}
                              title={!isSaved ? "DB登録後に公開設定が可能になります" : "公開設定を切り替え"}
                           >
                              <span className={`text-[10px] font-bold uppercase tracking-wide ${video.isPublic ? 'text-indigo-600' : 'text-slate-400'}`}>
                                {video.isPublic ? '公開' : '非公開'}
                              </span>
                              <Switch
                                checked={video.isPublic}
                                onChange={() => onTogglePublic(video.id)}
                                disabled={isProcessing || !isSaved}
                              />
                           </div>

                           {/* Delete Button */}
                           <button
                             onClick={() => onRemove(video.id)}
                             disabled={isProcessing}
                             className="p-1.5 text-slate-400 hover:text-red-600 hover:bg-red-50 rounded-md transition-colors"
                             title="リストから除外"
                           >
                             <DeleteIcon className="h-4 w-4" />
                           </button>
                        </div>
                      </div>
                    </div>
                  </div>
                );
              })}
            </div>
          )}
        </div>
      </div>

      {/* Publish Confirmation Modal */}
      {showPublishModal && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-slate-900/60 backdrop-blur-sm animate-fadeIn">
          <div className="bg-white rounded-2xl shadow-2xl w-full max-w-lg overflow-hidden animate-scaleIn">
            <div className="p-6 border-b border-slate-100">
              <h3 className="text-lg font-bold text-slate-900 flex items-center">
                <PublishIcon className="h-5 w-5 text-indigo-600 mr-2" />
                公開の確認
              </h3>
              <p className="mt-1 text-sm text-slate-500">
                以下の {videosToPublish.length} 件のデータを公開しますか？
              </p>
            </div>
            
            <div className="max-h-[300px] overflow-y-auto p-0 bg-slate-50">
              <ul className="divide-y divide-slate-200">
                {videosToPublish.map((v) => (
                  <li key={v.id} className="px-6 py-3 flex items-start gap-3 hover:bg-white transition-colors">
                    <div className="flex-shrink-0 mt-1">
                       <div className="h-2 w-2 rounded-full bg-indigo-500"></div>
                    </div>
                    <div className="min-w-0">
                      <p className="text-sm font-medium text-slate-800 truncate">{v.title}</p>
                      <p className="text-xs text-slate-500 truncate">{v.channel}</p>
                    </div>
                  </li>
                ))}
              </ul>
            </div>

            <div className="p-6 border-t border-slate-100 bg-white flex justify-end gap-3">
              <button
                onClick={() => setShowPublishModal(false)}
                className="px-5 py-2.5 rounded-lg text-sm font-bold text-slate-600 bg-slate-100 hover:bg-slate-200 transition-colors"
              >
                キャンセル
              </button>
              <button
                onClick={confirmPublish}
                className="px-5 py-2.5 rounded-lg text-sm font-bold text-white bg-indigo-600 hover:bg-indigo-700 shadow-lg shadow-indigo-200 transition-all hover:-translate-y-0.5"
              >
                OK, 公開する
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};