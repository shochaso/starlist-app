// Source: Google AI Studio Export
// Imported for reference (YouTube OCR + URL Enrichment Prototype)

import React, { useState } from 'react';
import { SearchIcon, SpinnerIcon, ChevronDownIcon, ChevronUpIcon, CheckIcon } from './icons';

interface OcrResultCardProps {
  ocrText: string;
  onTextChange: (newText: string) => void;
  onRunOcr: () => void;
  isRunning: boolean;
  isImageSelected: boolean;
}

export const OcrResultCard: React.FC<OcrResultCardProps> = ({ 
  ocrText, 
  onTextChange,
  onRunOcr,
  isRunning,
  isImageSelected
}) => {
  const [isOpen, setIsOpen] = useState(false);
  const lineCount = ocrText ? ocrText.split('\n').length : 0;
  const hasText = ocrText.length > 0;

  return (
    <div className="w-full">
      <h2 className="text-lg font-bold text-slate-900 mb-4 flex items-center">
        <span className="flex items-center justify-center w-7 h-7 rounded-full bg-indigo-600 text-white text-sm font-bold mr-3 shadow-sm shadow-indigo-200">2</span>
        テキスト抽出 (OCR)
      </h2>

      <div className="bg-white rounded-xl shadow-sm border border-slate-200 overflow-hidden transition-all hover:shadow-md">
        <div className="p-6">
           <div className="flex flex-col md:flex-row md:items-center justify-between gap-6">
              <div className="flex-1">
                <h3 className="text-base font-bold text-slate-800 mb-1">画像を解析</h3>
                <p className="text-sm text-slate-500 leading-relaxed">
                  Gemini AIを使用して、スクリーンショットから動画タイトルとチャンネル名を読み取ります。
                </p>
              </div>
              
              <button
                onClick={onRunOcr}
                disabled={isRunning || !isImageSelected}
                className="md:w-auto w-full inline-flex items-center justify-center px-8 py-3 border border-transparent text-sm font-bold rounded-lg shadow-md text-white bg-indigo-600 hover:bg-indigo-700 hover:-translate-y-0.5 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500 disabled:bg-slate-200 disabled:text-slate-400 disabled:shadow-none disabled:cursor-not-allowed disabled:translate-y-0 transition-all duration-200"
              >
                {isRunning ? (
                  <>
                    <SpinnerIcon className="animate-spin -ml-1 mr-2 h-5 w-5 text-indigo-200" />
                    AI解析中...
                  </>
                ) : (
                  <>
                    <SearchIcon className="-ml-1 mr-2 h-5 w-5" />
                    OCRを実行
                  </>
                )}
              </button>
           </div>

           {/* Status Banner (Post-OCR) */}
           {hasText && !isRunning && (
             <div className="mt-6 p-4 bg-emerald-50 border border-emerald-100 rounded-lg flex items-start animate-fadeIn">
                <div className="flex-shrink-0">
                   <CheckIcon className="h-5 w-5 text-emerald-500" />
                </div>
                <div className="ml-3 flex-1 md:flex md:justify-between">
                   <p className="text-sm text-emerald-800 font-medium">
                     解析が完了しました。{lineCount}件のデータが見つかりました。
                   </p>
                </div>
             </div>
           )}
        </div>

        {/* Progressive Disclosure Accordion */}
        <div className={`border-t border-slate-100`}>
           <button 
             onClick={() => setIsOpen(!isOpen)}
             disabled={!hasText}
             className="w-full px-6 py-4 bg-slate-50 hover:bg-slate-100 flex items-center justify-center gap-2 text-xs text-slate-500 font-bold uppercase tracking-wider transition-colors disabled:opacity-50 disabled:cursor-not-allowed focus:outline-none"
           >
             {isOpen ? '詳細を隠す' : '生テキストデータを確認・編集'}
             {isOpen ? <ChevronUpIcon className="h-3 w-3" /> : <ChevronDownIcon className="h-3 w-3" />}
           </button>
           
           {isOpen && (
             <div className="p-0 bg-slate-50 animate-slideDown">
                <textarea
                  value={ocrText}
                  onChange={(e) => onTextChange(e.target.value)}
                  rows={12}
                  className="block w-full p-6 text-xs font-mono leading-relaxed border-y border-slate-200 bg-slate-800 text-slate-200 focus:ring-0 focus:border-slate-200 resize-y"
                  placeholder="ここにOCR結果が表示されます..."
                  spellCheck={false}
                />
                <div className="px-6 py-2 bg-slate-100 text-[10px] text-slate-400 text-right">
                   {ocrText.length} characters
                </div>
             </div>
           )}
        </div>
      </div>
    </div>
  );
};