// Source: Google AI Studio Export
// Imported for reference (YouTube OCR + URL Enrichment Prototype)

export interface OcrState {
  imageFile: File | null;
  imageUrl: string | null;
  ocrText: string;
  isRunning: boolean;
  error: string | null;
}

export interface Notification {
  message: string;
  type: 'success' | 'error';
}

export interface ParsedVideo {
  id: string;
  title: string;
  channel: string;
  selected: boolean;
  isPublic: boolean;
  videoUrl?: string | null;
  isLinkLoading?: boolean;
  matchScore?: number | null;
  matchReason?: string | null;
  enrichError?: string | null;
  isSaved?: boolean;
}