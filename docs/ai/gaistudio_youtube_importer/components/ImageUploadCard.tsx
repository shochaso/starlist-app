// Source: Google AI Studio Export
// Imported for reference (YouTube OCR + URL Enrichment Prototype)

import React, { RefObject, ChangeEvent } from 'react';
import type { OcrState } from '../types';
import { ClearIcon, ErrorIcon, ImageIcon, CloudUploadIcon } from './icons';

interface ImageUploadCardProps {
  state: OcrState;
  onPickImage: () => void;
  onClear: () => void;
  fileInputRef: RefObject<HTMLInputElement>;
  onImageSelect: (event: ChangeEvent<HTMLInputElement>) => void;
}

export const ImageUploadCard: React.FC<ImageUploadCardProps> = ({
  state,
  onPickImage,
  onClear,
  fileInputRef,
  onImageSelect,
}) => {
  return (
    <div className="w-full">
      <h2 className="text-lg font-bold text-slate-900 mb-4 flex items-center">
        <span className="flex items-center justify-center w-7 h-7 rounded-full bg-indigo-600 text-white text-sm font-bold mr-3 shadow-sm shadow-indigo-200">1</span>
        画像のアップロード
      </h2>
      
      <div className="bg-white rounded-xl shadow-sm border border-slate-200 overflow-hidden transition-all hover:shadow-md">
        {!state.imageUrl ? (
          <div 
            onClick={onPickImage}
            className="group relative cursor-pointer h-64 flex flex-col items-center justify-center border-2 border-dashed border-slate-300 hover:border-indigo-500 hover:bg-indigo-50/30 transition-all duration-300 m-4 rounded-lg"
          >
            <div className="p-5 bg-indigo-50 rounded-full group-hover:bg-indigo-100 group-hover:scale-110 transition-all duration-300">
              <CloudUploadIcon className="h-8 w-8 text-indigo-600" />
            </div>
            <h3 className="mt-4 text-base font-bold text-slate-700 group-hover:text-indigo-700 transition-colors">
              画像をここにドロップ または 選択
            </h3>
            <p className="mt-2 text-xs text-slate-500 text-center max-w-xs leading-relaxed">
              YouTubeの視聴履歴のスクリーンショット<br/>(PNG, JPG 対応)
            </p>
          </div>
        ) : (
          <div className="relative group bg-slate-900 rounded-t-xl overflow-hidden flex justify-center items-center min-h-[300px]">
            {/* Image Preview */}
            <img
              src={state.imageUrl}
              alt="Preview"
              className="max-h-[400px] w-auto object-contain shadow-lg"
            />
            
            {/* Overlay Actions */}
            <div className="absolute inset-0 bg-black/60 opacity-0 group-hover:opacity-100 transition-opacity duration-200 flex items-center justify-center gap-4 backdrop-blur-sm">
               <button
                onClick={onPickImage}
                disabled={state.isRunning}
                className="inline-flex items-center justify-center px-5 py-2.5 bg-white text-slate-900 text-sm font-bold rounded-full hover:bg-slate-100 hover:scale-105 transform transition-all shadow-lg focus:outline-none"
              >
                <ImageIcon className="w-4 h-4 mr-2"/>
                画像を変更
              </button>
              <button
                onClick={onClear}
                disabled={state.isRunning}
                className="inline-flex items-center justify-center px-5 py-2.5 bg-red-500/90 text-white text-sm font-bold rounded-full hover:bg-red-600 hover:scale-105 transform transition-all shadow-lg focus:outline-none"
              >
                <ClearIcon className="w-4 h-4 mr-2"/>
                削除
              </button>
            </div>
            
            <div className="absolute bottom-0 left-0 right-0 p-3 bg-gradient-to-t from-black/80 to-transparent text-white">
               <p className="text-xs font-mono opacity-80 text-center">
                {state.imageFile?.name}
               </p>
            </div>
          </div>
        )}
      </div>

      <input
        type="file"
        ref={fileInputRef}
        onChange={onImageSelect}
        className="hidden"
        accept="image/*"
      />

      {state.error && (
        <div className="mt-4 flex items-start p-4 text-sm text-red-700 rounded-lg bg-red-50 border border-red-100 shadow-sm animate-fadeIn" role="alert">
          <ErrorIcon className="flex-shrink-0 inline w-5 h-5 mr-3 mt-0.5" />
          <div>
            <span className="font-bold block mb-1">エラーが発生しました</span>
            {state.error}
          </div>
        </div>
      )}
    </div>
  );
};