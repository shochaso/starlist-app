export type YoutubeVideoBasic = {
  id: string;
  title: string;
  channelTitle: string;
  publishedAt: string;
  thumbnailUrl: string | null;
  viewCount?: number;
};

type YoutubeApiResponse<T = unknown> = {
  items?: T[];
};

const THUMBNAIL_ORDER = ["maxres", "standard", "high", "medium", "default"] as const;

export class YoutubeClient {
  private readonly apiKey: string;
  private readonly baseUrl = "https://www.googleapis.com/youtube/v3";

  constructor(apiKey = process.env.YOUTUBE_API_KEY) {
    if (!apiKey) {
      throw new Error("YOUTUBE_API_KEY is not set.");
    }
    this.apiKey = apiKey;
  }

  async fetchVideoById(videoId: string): Promise<YoutubeVideoBasic | null> {
    if (!videoId) {
      throw new Error("videoId is required");
    }

    const url = new URL(`${this.baseUrl}/videos`);
    url.search = new URLSearchParams({
      part: "snippet,statistics",
      id: videoId,
      key: this.apiKey,
    }).toString();

    const res = await fetch(url.toString(), { cache: "no-store" });
    if (!res.ok) {
      console.error("[YoutubeClient] videos API failed", res.status, await res.text());
      return null;
    }

    const data = (await res.json()) as YoutubeApiResponse<any>;
    const item = data.items?.[0];
    if (!item) {
      return null;
    }

    return this.mapVideo(item);
  }

  async searchVideos(query: string, opts?: { maxResults?: number }): Promise<YoutubeVideoBasic[]> {
    if (!query.trim()) {
      return [];
    }

    const maxResults = this.normalizeMaxResults(opts?.maxResults);

    const url = new URL(`${this.baseUrl}/search`);
    url.search = new URLSearchParams({
      part: "snippet",
      type: "video",
      q: query,
      maxResults: String(maxResults),
      key: this.apiKey,
    }).toString();

    const res = await fetch(url.toString(), { cache: "no-store" });
    if (!res.ok) {
      console.error("[YoutubeClient] search API failed", res.status, await res.text());
      return [];
    }

    const data = (await res.json()) as YoutubeApiResponse<any>;
    if (!data.items?.length) {
      return [];
    }

    return data.items
      .map((item) => this.mapVideo({ ...item, id: item?.id?.videoId ?? item?.id }))
      .filter((video): video is YoutubeVideoBasic => Boolean(video));
  }

  private normalizeMaxResults(value?: number): number {
    if (!value || Number.isNaN(value)) {
      return 5;
    }
    return Math.min(Math.max(Math.floor(value), 1), 20);
  }

  private mapVideo(item: any): YoutubeVideoBasic | null {
    const snippet = item?.snippet;
    if (!snippet) {
      return null;
    }

    const id = typeof item?.id === "string" ? item.id : item?.id?.videoId;
    if (!id) {
      return null;
    }

    const statistics = item?.statistics;
    const rawViewCount = statistics?.viewCount;
    const viewCount =
      typeof rawViewCount === "string" && rawViewCount.length > 0 ? Number(rawViewCount) : undefined;

    return {
      id,
      title: snippet.title ?? "",
      channelTitle: snippet.channelTitle ?? "",
      publishedAt: snippet.publishedAt ?? "",
      thumbnailUrl: this.resolveThumbnail(snippet) ?? null,
      viewCount: Number.isFinite(viewCount) ? viewCount : undefined,
    };
  }

  private resolveThumbnail(snippet: any): string | null {
    const thumbnails = snippet?.thumbnails ?? {};
    for (const key of THUMBNAIL_ORDER) {
      const candidate = thumbnails[key]?.url;
      if (candidate) {
        return candidate;
      }
    }
    return null;
  }
}
