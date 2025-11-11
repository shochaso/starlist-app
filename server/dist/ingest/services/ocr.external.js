export class ExternalOcrProvider {
    async recognize(_buffer) {
        const url = process.env.EXTERNAL_OCR_URL;
        if (!url) {
            throw new Error('EXTERNAL_OCR_URL not configured');
        }
        // TODO: implement external OCR call. Example outline:
        // const response = await fetch(url, {
        //   method: 'POST',
        //   headers: { 'Content-Type': 'application/octet-stream' },
        //   body: buffer,
        // });
        // if (!response.ok) throw new Error(`External OCR failed: ${response.status}`);
        // const payload = await response.json();
        // return { text: payload.text, avgConf: payload.confidence };
        throw new Error('External OCR not implemented');
    }
}
