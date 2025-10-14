export type IngestJob = {
  userId: string;
  filePath: string;
  hash: string;
};

export type OcrJob = IngestJob & {
  width?: number;
  height?: number;
};

export type EnrichJob = OcrJob & {
  ocr: {
    store?: string;
    date?: string;
    items: Array<{ name: string; qty?: number; price?: number }>;
    raw?: string;
  };
};
