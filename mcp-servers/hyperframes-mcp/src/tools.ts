import { spawn } from "child_process";
import { z } from "zod";
import { trackRender, trackTts, trackTranscribe, getSessionCost, resetSessionCost } from "./cost-tracker.js";

// ---------------------------------------------------------------------------
// Utility: run hf CLI command and capture output
// ---------------------------------------------------------------------------

interface ExecResult {
  stdout: string;
  stderr: string;
  exitCode: number;
}

function runHf(args: string[], timeoutMs = 120_000): Promise<ExecResult> {
  return new Promise((resolve) => {
    const proc = spawn("hf", args, {
      shell: true,
      timeout: timeoutMs,
    });

    let stdout = "";
    let stderr = "";

    proc.stdout?.on("data", (chunk: Buffer) => {
      stdout += chunk.toString();
    });

    proc.stderr?.on("data", (chunk: Buffer) => {
      stderr += chunk.toString();
    });

    proc.on("close", (code) => {
      resolve({ stdout, stderr, exitCode: code ?? 1 });
    });

    proc.on("error", (err) => {
      resolve({ stdout: "", stderr: err.message, exitCode: 1 });
    });
  });
}

function hfNotFoundError(): string {
  return JSON.stringify({
    error: "hf (hyperframes-cli) not found in PATH",
    hint: "Install hyperframes-cli: npm install -g hyperframes-cli",
  });
}

// ---------------------------------------------------------------------------
// Tool input schemas
// ---------------------------------------------------------------------------

export const LintInput = z.object({
  path: z.string().describe("Path to the HyperFrames composition file or directory"),
});

export const PreviewInput = z.object({
  path: z.string().describe("Path to the composition file"),
  scene: z.string().optional().describe("Optional scene name/index to preview"),
});

export const RenderInput = z.object({
  path: z.string().describe("Path to the composition file"),
  output: z.string().describe("Output video file path"),
  quality: z.enum(["low", "medium", "high", "ultra"]).default("medium").describe("Render quality preset"),
});

export const TranscribeInput = z.object({
  audioPath: z.string().describe("Path to audio file to transcribe"),
  lang: z.string().optional().describe("Language code (e.g. en, es, fr). Defaults to auto-detect"),
});

export const TtsInput = z.object({
  text: z.string().describe("Text to convert to speech"),
  voice: z.string().default("default").describe("Voice name or ID"),
  output: z.string().describe("Output audio file path"),
});

export const DoctorInput = z.object({});

export const BenchmarkInput = z.object({
  path: z.string().describe("Path to the composition file to benchmark"),
});

export const EstimateCostInput = z.object({
  path: z.string().describe("Path to the composition file to analyze"),
});

export const SessionCostInput = z.object({
  reset: z.boolean().optional().default(false).describe("If true, reset the session cost accumulator"),
});

// ---------------------------------------------------------------------------
// Tool implementations
// ---------------------------------------------------------------------------

export async function hyperframes_lint(input: z.infer<typeof LintInput>): Promise<string> {
  const result = await runHf(["lint", input.path]);

  if (result.exitCode !== 0 && result.stderr.includes("not found")) {
    return hfNotFoundError();
  }

  // Parse error lines: typical format "file:line:col: error: message"
  const errorPattern = /^(.+):(\d+):(\d+):\s+(error|warning|info):\s+(.+)$/gm;
  const errors: Array<{ file: string; line: number; col: number; severity: string; message: string }> = [];
  let match: RegExpExecArray | null;

  while ((match = errorPattern.exec(result.stdout + "\n" + result.stderr)) !== null) {
    errors.push({
      file: match[1],
      line: parseInt(match[2], 10),
      col: parseInt(match[3], 10),
      severity: match[4],
      message: match[5],
    });
  }

  return JSON.stringify({
    success: result.exitCode === 0,
    error_count: errors.filter((e) => e.severity === "error").length,
    warning_count: errors.filter((e) => e.severity === "warning").length,
    issues: errors,
    raw_output: result.stdout || result.stderr,
  });
}

export async function hyperframes_preview(input: z.infer<typeof PreviewInput>): Promise<string> {
  const args = ["preview", input.path];
  if (input.scene !== undefined) {
    args.push("--scene", input.scene);
  }

  const result = await runHf(args, 60_000);

  if (result.exitCode !== 0 && result.stderr.includes("not found")) {
    return hfNotFoundError();
  }

  // Extract thumbnail path or URL from output
  const pathMatch = result.stdout.match(/(?:thumbnail|preview|output):\s*(.+)/i);
  const urlMatch = result.stdout.match(/https?:\/\/[^\s]+/);

  return JSON.stringify({
    success: result.exitCode === 0,
    thumbnail_path: pathMatch ? pathMatch[1].trim() : null,
    thumbnail_url: urlMatch ? urlMatch[0] : null,
    scene: input.scene ?? "all",
    raw_output: result.stdout || result.stderr,
  });
}

export async function hyperframes_render(input: z.infer<typeof RenderInput>): Promise<string> {
  const args = ["render", input.path, "--output", input.output, "--quality", input.quality];

  const result = await runHf(args, 600_000); // 10 min timeout for render

  if (result.exitCode !== 0 && result.stderr.includes("not found")) {
    return hfNotFoundError();
  }

  // Extract duration and file size from output
  const durationMatch = result.stdout.match(/duration[:\s]+(\d+(?:\.\d+)?)\s*s/i);
  const sizeMatch = result.stdout.match(/(?:size|file)[:\s]+(\d+(?:\.\d+)?)\s*(MB|KB|GB)/i);
  const outputMatch = result.stdout.match(/(?:written to|output)[:\s]+(.+)/i);

  const durationSeconds = durationMatch ? parseFloat(durationMatch[1]) : 0;

  if (result.exitCode === 0 && durationSeconds > 0) {
    trackRender(durationSeconds);
  }

  return JSON.stringify({
    success: result.exitCode === 0,
    output_path: outputMatch ? outputMatch[1].trim() : input.output,
    duration_seconds: durationSeconds,
    file_size: sizeMatch ? `${sizeMatch[1]} ${sizeMatch[2]}` : null,
    quality: input.quality,
    raw_output: result.stdout || result.stderr,
  });
}

export async function hyperframes_transcribe(input: z.infer<typeof TranscribeInput>): Promise<string> {
  const args = ["transcribe", input.audioPath];
  if (input.lang !== undefined) {
    args.push("--lang", input.lang);
  }

  const result = await runHf(args, 300_000); // 5 min timeout

  if (result.exitCode !== 0 && result.stderr.includes("not found")) {
    return hfNotFoundError();
  }

  // Track cost (estimate audio duration from SRT if available)
  const srtLines = result.stdout.split("\n").filter((l) => l.match(/^\d{2}:\d{2}:\d{2}/));
  const lastTimestamp = srtLines[srtLines.length - 1];
  let audioSeconds = 0;
  if (lastTimestamp) {
    const m = lastTimestamp.match(/(\d{2}):(\d{2}):(\d{2})/);
    if (m) {
      audioSeconds = parseInt(m[1]) * 3600 + parseInt(m[2]) * 60 + parseInt(m[3]);
    }
  }
  if (result.exitCode === 0 && audioSeconds > 0) {
    trackTranscribe(audioSeconds);
  }

  return JSON.stringify({
    success: result.exitCode === 0,
    language: input.lang ?? "auto-detected",
    srt_text: result.stdout,
    segment_count: srtLines.length,
    estimated_audio_seconds: audioSeconds,
  });
}

export async function hyperframes_tts(input: z.infer<typeof TtsInput>): Promise<string> {
  const args = ["tts", "--text", input.text, "--voice", input.voice, "--output", input.output];

  const result = await runHf(args, 120_000);

  if (result.exitCode !== 0 && result.stderr.includes("not found")) {
    return hfNotFoundError();
  }

  if (result.exitCode === 0) {
    trackTts(input.text.length);
  }

  const outputMatch = result.stdout.match(/(?:written to|output|saved)[:\s]+(.+)/i);

  return JSON.stringify({
    success: result.exitCode === 0,
    audio_path: outputMatch ? outputMatch[1].trim() : input.output,
    voice: input.voice,
    char_count: input.text.length,
    raw_output: result.stdout || result.stderr,
  });
}

export async function hyperframes_doctor(_input: z.infer<typeof DoctorInput>): Promise<string> {
  const result = await runHf(["doctor"], 30_000);

  if (result.exitCode !== 0 && result.stderr.includes("not found")) {
    return hfNotFoundError();
  }

  // Parse key=value or "✓ / ✗" style diagnostic lines
  const checks: Array<{ name: string; status: string; detail: string }> = [];
  const lines = (result.stdout + "\n" + result.stderr).split("\n").filter(Boolean);

  for (const line of lines) {
    const passMatch = line.match(/[✓✔✅]\s*(.+)/);
    const failMatch = line.match(/[✗✘❌]\s*(.+)/);
    const kvMatch = line.match(/^([^:]+):\s+(.+)/);

    if (passMatch) {
      checks.push({ name: passMatch[1].trim(), status: "ok", detail: "" });
    } else if (failMatch) {
      checks.push({ name: failMatch[1].trim(), status: "fail", detail: "" });
    } else if (kvMatch) {
      checks.push({ name: kvMatch[1].trim(), status: "info", detail: kvMatch[2].trim() });
    }
  }

  return JSON.stringify({
    success: result.exitCode === 0,
    checks,
    ok_count: checks.filter((c) => c.status === "ok").length,
    fail_count: checks.filter((c) => c.status === "fail").length,
    raw_output: result.stdout || result.stderr,
  });
}

export async function hyperframes_benchmark(input: z.infer<typeof BenchmarkInput>): Promise<string> {
  const result = await runHf(["benchmark", input.path], 300_000);

  if (result.exitCode !== 0 && result.stderr.includes("not found")) {
    return hfNotFoundError();
  }

  // Parse timing lines: "phase: Xms" or "phase: X.Xs"
  const timings: Record<string, string> = {};
  const timingPattern = /^([a-zA-Z_\s]+):\s+(\d+(?:\.\d+)?)\s*(ms|s)/gm;
  let m: RegExpExecArray | null;

  while ((m = timingPattern.exec(result.stdout)) !== null) {
    timings[m[1].trim()] = `${m[2]}${m[3]}`;
  }

  return JSON.stringify({
    success: result.exitCode === 0,
    composition: input.path,
    timings,
    raw_output: result.stdout || result.stderr,
  });
}

export async function hyperframes_estimate_cost(input: z.infer<typeof EstimateCostInput>): Promise<string> {
  // Run lint first to validate, then analyze the composition
  const lintResult = await runHf(["lint", input.path]);
  const infoResult = await runHf(["benchmark", "--dry-run", input.path]).catch(() => ({
    stdout: "",
    stderr: "",
    exitCode: 1,
  }));

  // Count scenes, audio references, and assets by scanning raw output
  const combined = lintResult.stdout + "\n" + infoResult.stdout;

  const sceneCount = (combined.match(/scene/gi) ?? []).length;
  const audioCount = (combined.match(/\.mp3|\.wav|\.aac|\.ogg/gi) ?? []).length;
  const imageCount = (combined.match(/\.png|\.jpg|\.jpeg|\.webp|\.svg/gi) ?? []).length;
  const ttsCount = (combined.match(/tts|text.to.speech/gi) ?? []).length;

  // Rough estimates
  const estimatedRenderMinutes = Math.max(1, sceneCount * 0.5);
  const estimatedTtsChars = ttsCount * 500; // rough average
  const renderCost = estimatedRenderMinutes * 0.005;
  const ttsCost = (estimatedTtsChars / 1000) * 0.015;
  const totalCost = renderCost + ttsCost;

  return JSON.stringify({
    composition: input.path,
    estimates: {
      scene_count: sceneCount,
      audio_asset_count: audioCount,
      image_asset_count: imageCount,
      tts_blocks: ttsCount,
      render_minutes_estimate: estimatedRenderMinutes,
      tts_chars_estimate: estimatedTtsChars,
    },
    cost_estimate_usd: {
      render: renderCost.toFixed(4),
      tts: ttsCost.toFixed(4),
      total: totalCost.toFixed(4),
    },
    note: "Estimates are approximate. Actual costs depend on provider pricing and composition complexity.",
  });
}

export async function hyperframes_session_cost(input: z.infer<typeof SessionCostInput>): Promise<string> {
  if (input.reset) {
    resetSessionCost();
    return JSON.stringify({ message: "Session cost tracker reset.", state: getSessionCost() });
  }
  return JSON.stringify(getSessionCost());
}
