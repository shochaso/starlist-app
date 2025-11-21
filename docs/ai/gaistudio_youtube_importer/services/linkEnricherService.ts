// Source: Google AI Studio Export
// Imported for reference (YouTube OCR + URL Enrichment Prototype)

import { GoogleGenAI } from "@google/genai";

export interface EnrichedData {
  url: string | null;
  score: number | null;
  reason: string | null;
}

const delay = (ms: number) => new Promise(resolve => setTimeout(resolve, ms));

/**
 * Finds a YouTube URL for a given video title and channel using Gemini with Google Search.
 * acts as a proxy for YouTube Data API search to avoid strict daily quotas (100/day).
 * @param {string} title - The title of the video.
 * @param {string} channel - The channel name of the video.
 * @returns {Promise<EnrichedData | null>} A promise that resolves with the enriched data or null if not found.
 */
export const findYouTubeUrl = async (title: string, channel: string): Promise<EnrichedData | null> => {
  const maxRetries = 5;
  let attempt = 0;

  // Optimize query to search specifically within YouTube
  const searchKey = `site:youtube.com "${title}" channel "${channel}"`;

  while (attempt < maxRetries) {
    try {
      const ai = new GoogleGenAI({ apiKey: process.env.API_KEY });
      
      // Configured to act like the YouTube Search API
      const prompt = `
      Role: You are a precise YouTube video finder API.
      
      Task:
      1. Search specifically for the video titled "${title}" uploaded by the channel "${channel}".
      2. You MUST use the Google Search tool to find the real URL.
      3. Verify that the channel name matches closely.
      
      Query used: ${searchKey}

      Response Format (Single Line Only):
      URL: [The full https://www.youtube.com/watch?v=... link] | SCORE: [Confidence 0.0-1.0] | REASON: [Brief verification note]

      Constraints:
      - If the video is not found or the channel does not match, return "URL: null".
      - Do not return generic channel URLs, only specific video URLs.
      `;

      const response = await ai.models.generateContent({
        model: "gemini-2.5-flash",
        contents: prompt,
        config: {
          tools: [{ googleSearch: {} }],
          temperature: 0.0, // Maximum determinism
        },
      });

      const text = response.text.trim();
      
      if (text.startsWith("URL: null")) {
          return { url: null, score: 0, reason: "No confident match found via search." };
      }

      const urlMatch = text.match(/URL: (https:\/\/www\.youtube\.com\/watch\?v=[a-zA-Z0-9_-]+)/);
      const scoreMatch = text.match(/SCORE: (\d\.\d+)/);
      const reasonMatch = text.match(/REASON: (.*)/);

      const url = urlMatch ? urlMatch[1] : null;
      const score = scoreMatch ? parseFloat(scoreMatch[1]) : null;
      const reason = reasonMatch ? reasonMatch[1].trim() : "No reason provided.";

      if (!url) {
        console.warn("Could not parse URL from Gemini response:", text);
        return { url: null, score: null, reason: `Failed to parse response: ${text}` };
      }

      return { url, score, reason };

    } catch (error: any) {
      console.error(`Error finding YouTube URL with Gemini (Attempt ${attempt + 1}/${maxRetries}):`, error);
      
      const isRetryable = true; 
      
      if (isRetryable && attempt < maxRetries - 1) {
        // Exponential backoff: 2s, 4s, 8s, 16s...
        const waitTime = 2000 * Math.pow(2, attempt);
        await delay(waitTime);
        attempt++;
        continue;
      }
      
      return { url: null, score: null, reason: `An API error occurred: ${error instanceof Error ? error.message : String(error)}` };
    }
  }
  
  return { url: null, score: null, reason: "Max retries exceeded" };
};