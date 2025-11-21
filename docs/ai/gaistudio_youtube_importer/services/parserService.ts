// Source: Google AI Studio Export
// Imported for reference (YouTube OCR + URL Enrichment Prototype)

import { ParsedVideo } from '../types';

/**
 * Generates a stable ID from a title and channel name.
 * Uses a simple concatenation and lowercasing instead of MD5 for simplicity in the browser
 * without external libraries.
 * @param {string} title - The video title.
 * @param {string} channel - The channel name.
 * @returns {string} A stable identifier string.
 */
const stableId = (title: string, channel: string): string => {
  return `${title.trim()}|${channel.trim()}`.toLowerCase();
};

/**
 * Parses raw OCR text into a list of structured video data using heuristics.
 * @param {string} raw - The raw text from OCR.
 * @returns {ParsedVideo[]} An array of parsed video objects.
 */
export const parseOcrText = (raw: string): ParsedVideo[] => {
  const text = raw.trim();
  if (!text) return [];

  const allLines = text.split('\n')
    .map(l => l.trim())
    .filter(Boolean); // Filter out empty lines

  if (allLines.length === 0) return [];
  
  // Find the index of the first plausible video title. This helps skip preambles.
  let startIndex = allLines.findIndex(line => {
      const isPreamble = /^(here are|sure, here|Sure, |Here are|以下に|はい、)/i.test(line);
      const isHeaderLike = line.endsWith(':');
      // A plausible title is not a preamble, not a header, and has some length.
      return !isPreamble && !isHeaderLike && line.length > 5;
  });

  if (startIndex === -1) {
    // If no clear start found, check if it's because the list is very short
    // and doesn't contain preamble. If so, process from start.
    const hasPreamble = allLines.some(line => /^(here are|sure, here|Sure, |Here are|以下に|はい、)/i.test(line));
    if (hasPreamble) return []; // Contains preamble but no clear start, likely junk.
    startIndex = 0;
  }
  
  const lines = allLines.slice(startIndex);
  const items: ParsedVideo[] = [];
  
  for (let i = 0; i < lines.length; i++) {
    // Clean the line from any leading list markers.
    let currentLine = lines[i].replace(/^[\*\-\d\.]+\s*/, '').trim();
    if (!currentLine) continue;

    // Pattern A: Title and Channel on the same line, separated by ' - '
    const dashIndex = currentLine.lastIndexOf(' - ');
    if (dashIndex > 0 && dashIndex < currentLine.length - 3) {
      const title = currentLine.substring(0, dashIndex).trim();
      const channel = currentLine.substring(dashIndex + 3).trim();
      items.push({ id: stableId(title, channel), title, channel, selected: false, isPublic: false });
      continue;
    }

    // Pattern B: Title is the current line, channel might be the next.
    const title = currentLine;
    let channel = '';
    
    // Check if next line exists and could be a channel name.
    if (i + 1 < lines.length) {
      const nextLine = lines[i + 1];
      // A channel line should NOT look like a new video title (i.e., not start with a list marker, and not contain ' - ').
      const isNextLineAnotherTitle = /^[\*\-\d\.]+\s*/.test(nextLine) || nextLine.lastIndexOf(' - ') > 0;
      
      if (!isNextLineAnotherTitle) {
        // We'll assume this is the channel line.
        channel = nextLine;
        
        // Clean up common channel line artifacts.
        const splitters = ['・', '•', '—', '視聴回数', '回視聴'];
        for (const s of splitters) {
          if (channel.includes(s)) {
            channel = channel.split(s)[0].trim();
            break;
          }
        }
        i++; // Consume the channel line, so we skip it in the next iteration.
      }
    }

    items.push({ id: stableId(title, channel), title, channel, selected: false, isPublic: false });
  }

  // A final cleanup step: if an item looks like a preamble that slipped through, remove it.
  return items.filter(item => !/^(here are|sure, here|Sure, |Here are|以下に|はい、)/i.test(item.title));
};