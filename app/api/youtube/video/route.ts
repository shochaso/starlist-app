import { NextRequest, NextResponse } from "next/server";
import { YoutubeClient } from "../../../lib/youtubeClient";

export async function GET(request: NextRequest) {
  const url = new URL(request.url);
  const videoId = url.searchParams.get("videoId");

  if (!videoId) {
    return NextResponse.json({ error: "Missing videoId" }, { status: 400 });
  }

  try {
    const client = new YoutubeClient();
    const video = await client.fetchVideoById(videoId);

    if (!video) {
      return NextResponse.json({ error: "Video not found" }, { status: 404 });
    }

    return NextResponse.json(video, { status: 200 });
  } catch (error) {
    console.error("[api/youtube/video] failed to fetch video", error);
    return NextResponse.json({ error: "Failed to fetch video data" }, { status: 502 });
  }
}
