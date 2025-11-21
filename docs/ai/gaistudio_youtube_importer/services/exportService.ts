// Source: Google AI Studio Export
// Imported for reference (YouTube OCR + URL Enrichment Prototype)

import { ParsedVideo } from '../types';

// CSVの特殊文字をエスケープする関数
const escapeCsvField = (field: string | null | undefined): string => {
  if (field === null || field === undefined) {
    return '';
  }
  const str = String(field);
  // ダブルクォート、カンマ、改行が含まれている場合はフィールド全体をダブルクォートで囲む
  if (/[",\n\r]/.test(str)) {
    // フィールド内のダブルクォートは2つ重ねる
    return `"${str.replace(/"/g, '""')}"`;
  }
  return str;
};

/**
 * ParsedVideoの配列をCSVファイルとしてダウンロードする
 * @param {ParsedVideo[]} videos - ダウンロードする動画データの配列
 * @param {string} filename - ダウンロードするファイル名
 */
export const exportVideosToCsv = (videos: ParsedVideo[], filename: string = 'youtube_history.csv') => {
  if (videos.length === 0) {
    alert('エクスポートするデータがありません。');
    return;
  }

  const headers = ['タイトル', 'チャンネル', '動画URL', '公開', '一致スコア', '選択理由'];
  const rows = videos.map(v => [
    escapeCsvField(v.title),
    escapeCsvField(v.channel),
    escapeCsvField(v.videoUrl),
    v.isPublic ? 'はい' : 'いいえ',
    v.matchScore !== null && v.matchScore !== undefined ? v.matchScore.toFixed(2) : '',
    escapeCsvField(v.matchReason),
  ]);

  const csvContent = [
    headers.join(','),
    ...rows.map(row => row.join(','))
  ].join('\n');

  // BOMを追加してExcelでの文字化けを防ぐ
  const bom = new Uint8Array([0xEF, 0xBB, 0xBF]);
  const blob = new Blob([bom, csvContent], { type: 'text/csv;charset=utf-8;' });

  const link = document.createElement('a');
  if (link.download !== undefined) {
    const url = URL.createObjectURL(blob);
    link.setAttribute('href', url);
    link.setAttribute('download', filename);
    link.style.visibility = 'hidden';
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
    URL.revokeObjectURL(url);
  }
};