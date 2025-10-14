export type OcrResult = { text: string; avgConf: number };

export interface OcrProvider {
  recognize(buffer: Buffer): Promise<OcrResult>;
}
