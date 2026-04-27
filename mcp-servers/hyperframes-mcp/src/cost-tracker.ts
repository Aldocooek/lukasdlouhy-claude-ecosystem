import { readFileSync, writeFileSync } from "fs";
import { homedir } from "os";
import { join } from "path";

const STATE_PATH = join(homedir(), ".hyperframes-mcp-state.json");

export interface CostState {
  session_start: string;
  last_updated: string;
  render_count: number;
  tts_count: number;
  tts_chars: number;
  transcribe_count: number;
  transcribe_seconds: number;
  estimated_usd: number;
  history: CostEntry[];
}

export interface CostEntry {
  timestamp: string;
  tool: string;
  detail: string;
  delta_usd: number;
}

// Rough cost constants (adjust to real pricing)
const COSTS = {
  render_per_minute: 0.005,   // hypothetical compute cost
  tts_per_1k_chars: 0.015,    // e.g. OpenAI TTS pricing
  transcribe_per_minute: 0.006, // e.g. Whisper pricing
} as const;

function loadState(): CostState {
  try {
    const raw = readFileSync(STATE_PATH, "utf-8");
    return JSON.parse(raw) as CostState;
  } catch {
    return {
      session_start: new Date().toISOString(),
      last_updated: new Date().toISOString(),
      render_count: 0,
      tts_count: 0,
      tts_chars: 0,
      transcribe_count: 0,
      transcribe_seconds: 0,
      estimated_usd: 0,
      history: [],
    };
  }
}

function saveState(state: CostState): void {
  state.last_updated = new Date().toISOString();
  writeFileSync(STATE_PATH, JSON.stringify(state, null, 2), "utf-8");
}

export function trackRender(durationSeconds: number): void {
  const state = loadState();
  const minutes = durationSeconds / 60;
  const cost = minutes * COSTS.render_per_minute;
  state.render_count++;
  state.estimated_usd += cost;
  state.history.push({
    timestamp: new Date().toISOString(),
    tool: "render",
    detail: `${durationSeconds}s video`,
    delta_usd: cost,
  });
  saveState(state);
}

export function trackTts(charCount: number): void {
  const state = loadState();
  const cost = (charCount / 1000) * COSTS.tts_per_1k_chars;
  state.tts_count++;
  state.tts_chars += charCount;
  state.estimated_usd += cost;
  state.history.push({
    timestamp: new Date().toISOString(),
    tool: "tts",
    detail: `${charCount} chars`,
    delta_usd: cost,
  });
  saveState(state);
}

export function trackTranscribe(audioSeconds: number): void {
  const state = loadState();
  const minutes = audioSeconds / 60;
  const cost = minutes * COSTS.transcribe_per_minute;
  state.transcribe_count++;
  state.transcribe_seconds += audioSeconds;
  state.estimated_usd += cost;
  state.history.push({
    timestamp: new Date().toISOString(),
    tool: "transcribe",
    detail: `${audioSeconds}s audio`,
    delta_usd: cost,
  });
  saveState(state);
}

export function getSessionCost(): CostState {
  return loadState();
}

export function resetSessionCost(): void {
  const fresh: CostState = {
    session_start: new Date().toISOString(),
    last_updated: new Date().toISOString(),
    render_count: 0,
    tts_count: 0,
    tts_chars: 0,
    transcribe_count: 0,
    transcribe_seconds: 0,
    estimated_usd: 0,
    history: [],
  };
  saveState(fresh);
}
