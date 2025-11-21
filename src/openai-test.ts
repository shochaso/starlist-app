import "dotenv/config";
import OpenAI from "openai";

async function main() {
  const apiKey = process.env.OPENAI_API_KEY;
  if (!apiKey) {
    console.error("OPENAI_API_KEY is not set. Please add it to your .env file.");
    process.exit(1);
  }

  const client = new OpenAI({ apiKey });

  const response = await client.responses.create({
    model: "gpt-4.1-mini",
    input: "Hello from STARLIST OpenAI smoke test.",
  });

  const textOutput =
    (response as { output_text?: string }).output_text ??
    JSON.stringify(response, null, 2);

  console.log("OpenAI response:", textOutput);
}

main().catch((error) => {
  console.error("OpenAI test failed:", error);
  process.exit(1);
});
