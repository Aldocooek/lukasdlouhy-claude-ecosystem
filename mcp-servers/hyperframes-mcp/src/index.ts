#!/usr/bin/env node
import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import {
  CallToolRequestSchema,
  ErrorCode,
  ListToolsRequestSchema,
  McpError,
} from "@modelcontextprotocol/sdk/types.js";
import { z, ZodError } from "zod";

import {
  LintInput,
  PreviewInput,
  RenderInput,
  TranscribeInput,
  TtsInput,
  DoctorInput,
  BenchmarkInput,
  EstimateCostInput,
  SessionCostInput,
  hyperframes_lint,
  hyperframes_preview,
  hyperframes_render,
  hyperframes_transcribe,
  hyperframes_tts,
  hyperframes_doctor,
  hyperframes_benchmark,
  hyperframes_estimate_cost,
  hyperframes_session_cost,
} from "./tools.js";

// ---------------------------------------------------------------------------
// Server definition
// ---------------------------------------------------------------------------

const server = new Server(
  {
    name: "@lukasdlouhy/hyperframes-mcp",
    version: "0.1.0",
  },
  {
    capabilities: {
      tools: {},
    },
  }
);

// ---------------------------------------------------------------------------
// Tool registry
// ---------------------------------------------------------------------------

const TOOLS = [
  {
    name: "hyperframes_lint",
    description: "Lint a HyperFrames composition file. Returns parsed errors and warnings.",
    inputSchema: {
      type: "object",
      properties: {
        path: { type: "string", description: "Path to the composition file or directory" },
      },
      required: ["path"],
    },
  },
  {
    name: "hyperframes_preview",
    description: "Generate a preview thumbnail for a HyperFrames composition. Returns thumbnail path or URL.",
    inputSchema: {
      type: "object",
      properties: {
        path: { type: "string", description: "Path to the composition file" },
        scene: { type: "string", description: "Optional scene name or index to preview" },
      },
      required: ["path"],
    },
  },
  {
    name: "hyperframes_render",
    description: "Render a HyperFrames composition to video. Returns output path, duration, and file size.",
    inputSchema: {
      type: "object",
      properties: {
        path: { type: "string", description: "Path to the composition file" },
        output: { type: "string", description: "Output video file path" },
        quality: {
          type: "string",
          enum: ["low", "medium", "high", "ultra"],
          description: "Render quality preset (default: medium)",
        },
      },
      required: ["path", "output"],
    },
  },
  {
    name: "hyperframes_transcribe",
    description: "Transcribe audio to SRT using HyperFrames. Returns SRT text and segment count.",
    inputSchema: {
      type: "object",
      properties: {
        audioPath: { type: "string", description: "Path to the audio file" },
        lang: { type: "string", description: "Language code (e.g. en, es). Defaults to auto-detect" },
      },
      required: ["audioPath"],
    },
  },
  {
    name: "hyperframes_tts",
    description: "Generate speech audio from text using HyperFrames TTS. Returns audio file path.",
    inputSchema: {
      type: "object",
      properties: {
        text: { type: "string", description: "Text to convert to speech" },
        voice: { type: "string", description: "Voice name or ID (default: default)" },
        output: { type: "string", description: "Output audio file path" },
      },
      required: ["text", "output"],
    },
  },
  {
    name: "hyperframes_doctor",
    description: "Run HyperFrames environment diagnostics. Returns check results and environment info.",
    inputSchema: {
      type: "object",
      properties: {},
      required: [],
    },
  },
  {
    name: "hyperframes_benchmark",
    description: "Benchmark a HyperFrames composition. Returns per-phase timing metrics.",
    inputSchema: {
      type: "object",
      properties: {
        path: { type: "string", description: "Path to the composition file" },
      },
      required: ["path"],
    },
  },
  {
    name: "hyperframes_estimate_cost",
    description:
      "Analyze a HyperFrames composition and estimate render cost: compute time, TTS API calls, asset count.",
    inputSchema: {
      type: "object",
      properties: {
        path: { type: "string", description: "Path to the composition file to analyze" },
      },
      required: ["path"],
    },
  },
  {
    name: "hyperframes_session_cost",
    description:
      "Return the running cost total for this session (renders, TTS, transcriptions). Optionally reset the tracker.",
    inputSchema: {
      type: "object",
      properties: {
        reset: { type: "boolean", description: "If true, reset the session cost accumulator" },
      },
      required: [],
    },
  },
] as const;

// ---------------------------------------------------------------------------
// Request handlers
// ---------------------------------------------------------------------------

server.setRequestHandler(ListToolsRequestSchema, async () => ({
  tools: TOOLS,
}));

server.setRequestHandler(CallToolRequestSchema, async (request) => {
  const { name, arguments: args } = request.params;

  try {
    let result: string;

    switch (name) {
      case "hyperframes_lint":
        result = await hyperframes_lint(LintInput.parse(args));
        break;
      case "hyperframes_preview":
        result = await hyperframes_preview(PreviewInput.parse(args));
        break;
      case "hyperframes_render":
        result = await hyperframes_render(RenderInput.parse(args));
        break;
      case "hyperframes_transcribe":
        result = await hyperframes_transcribe(TranscribeInput.parse(args));
        break;
      case "hyperframes_tts":
        result = await hyperframes_tts(TtsInput.parse(args));
        break;
      case "hyperframes_doctor":
        result = await hyperframes_doctor(DoctorInput.parse(args));
        break;
      case "hyperframes_benchmark":
        result = await hyperframes_benchmark(BenchmarkInput.parse(args));
        break;
      case "hyperframes_estimate_cost":
        result = await hyperframes_estimate_cost(EstimateCostInput.parse(args));
        break;
      case "hyperframes_session_cost":
        result = await hyperframes_session_cost(SessionCostInput.parse(args));
        break;
      default:
        throw new McpError(ErrorCode.MethodNotFound, `Unknown tool: ${name}`);
    }

    return {
      content: [
        {
          type: "text",
          text: result,
        },
      ],
    };
  } catch (err) {
    if (err instanceof McpError) throw err;

    if (err instanceof ZodError) {
      throw new McpError(
        ErrorCode.InvalidParams,
        `Invalid parameters for ${name}: ${err.errors.map((e) => `${e.path.join(".")}: ${e.message}`).join(", ")}`
      );
    }

    const message = err instanceof Error ? err.message : String(err);
    throw new McpError(ErrorCode.InternalError, `Tool ${name} failed: ${message}`);
  }
});

// ---------------------------------------------------------------------------
// Startup
// ---------------------------------------------------------------------------

async function main(): Promise<void> {
  const transport = new StdioServerTransport();
  await server.connect(transport);
  process.stderr.write("HyperFrames MCP server running on stdio\n");
}

main().catch((err) => {
  process.stderr.write(`Fatal: ${err instanceof Error ? err.message : String(err)}\n`);
  process.exit(1);
});
