// Source: Google AI Studio Export
// Imported for reference (YouTube OCR + URL Enrichment Prototype)

import { GoogleGenAI } from "@google/genai";

const toBase64 = (file: File): Promise<string> => new Promise((resolve, reject) => {
    const reader = new FileReader();
    reader.readAsDataURL(file);
    reader.onload = () => {
        if (typeof reader.result === 'string') {
            // Return only the base64 part
            resolve(reader.result.split(',')[1]);
        } else {
            reject(new Error('Failed to convert file to base64 string.'));
        }
    };
    reader.onerror = error => reject(error);
});

/**
 * Performs OCR on an image file using the Gemini API.
 * @param {File} imageFile - The image file to process.
 * @returns {Promise<string>} A promise that resolves with the extracted text.
 */
export const performOcr = async (imageFile: File): Promise<string> => {
  // Per guidelines, API key must be from process.env.API_KEY
  const ai = new GoogleGenAI({ apiKey: process.env.API_KEY });

  const base64Image = await toBase64(imageFile);

  const imagePart = {
    inlineData: {
      mimeType: imageFile.type,
      data: base64Image,
    },
  };

  const textPart = {
    text: "This is a screenshot of a YouTube watch history. Extract the video titles and their corresponding channel names. Each video entry might span one or two lines. Format the output as one line per video, with title and channel separated by ' - '. IMPORTANT: Do not include any introductory text, headers, explanations, or markdown formatting like asterisks. Only return the raw list of videos."
  };

  // Per guidelines, use generateContent for multimodal input.
  // gemini-2.5-flash is suitable for this task.
  const response = await ai.models.generateContent({
    model: 'gemini-2.5-flash',
    contents: { parts: [imagePart, textPart] },
  });
  
  // Per guidelines, extract text directly from the .text property.
  return response.text;
};