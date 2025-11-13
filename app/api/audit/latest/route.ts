import { NextResponse } from "next/server";

export async function GET() {
  const res = await fetch(
    new URL("/dashboard/data/latest.json", process.env.NEXT_PUBLIC_BASE_URL || "http://localhost:3000")
  );
  const data = await res.json().catch(() => ({}));
  return NextResponse.json(data, { headers: { "cache-control": "no-store" } });
}

