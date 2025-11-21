import { describe, expect, it, vi, beforeEach, afterEach } from "vitest";
import { YoutubeClient } from "../app/lib/youtubeClient";

const mockFetch = vi.fn();

const mockResponse = (data: unknown, ok = true) => ({
  ok,
  status: ok ? 200 : 500,
  json: async () => data,
  text: async () => JSON.stringify(data),
});

describe("YoutubeClient", () => {
  beforeEach(() => {
    vi.stubGlobal("fetch", mockFetch);
    process.env.YOUTUBE_API_KEY = "test-key";
    mockFetch.mockReset();
  });

  afterEach(() => {
    vi.unstubAllGlobals();
    delete process.env.YOUTUBE_API_KEY;
  });

  it("fetchVideoById returns mapped item", async () => {
    mockFetch.mockResolvedValueOnce(
      mockResponse({
        items: [
          {
            id: "abc123",
            snippet: {
              title: "Sample video",
              channelTitle: "Sample channel",
              publishedAt: "2024-01-01T00:00:00Z",
              thumbnails: { high: { url: "https://example.com/thumb.jpg" } },
            },
            statistics: { viewCount: "42" },
          },
        ],
      })
    );

    const client = new YoutubeClient();
    const video = await client.fetchVideoById("abc123");

    expect(video).toEqual({
      id: "abc123",
      title: "Sample video",
      channelTitle: "Sample channel",
      publishedAt: "2024-01-01T00:00:00Z",
      thumbnailUrl: "https://example.com/thumb.jpg",
      viewCount: 42,
    });
  });

  it("clamps search maxResults and returns mapped results", async () => {
    mockFetch.mockResolvedValueOnce(
      mockResponse({
        items: [
          {
            id: { videoId: "xyz" },
            snippet: {
              title: "Hit result",
              channelTitle: "Channel",
              publishedAt: "2024-02-02T00:00:00Z",
              thumbnails: { default: { url: "https://example.com/default.jpg" } },
            },
          },
        ],
      })
    );

    const client = new YoutubeClient();
    const results = await client.searchVideos("query", { maxResults: 200 });

    expect(results.length).toBe(1);
    expect(results[0]?.id).toBe("xyz");

    const calledUrl = mockFetch.mock.calls[0]?.[0] as string;
    expect(calledUrl).toContain("maxResults=20");
  });
});
