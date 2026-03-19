#!/usr/bin/env node
/**
 * Batch OCR with Google Cloud Vision API.
 *
 * Default behavior matches requested prompt:
 * - input folder: ./images
 * - output file: ./output.json
 *
 * You can override:
 *   node tools/vision_ocr_batch.js --input "frontend_flutter/MTCDocuments" --output "artifacts/mtcdocuments_vision_output.json" --delay 120
 */

const fs = require("fs/promises");
const path = require("path");
const vision = require("@google-cloud/vision");

const SUPPORTED_EXTENSIONS = new Set([".jpg", ".jpeg", ".png"]);

function parseArgs(argv) {
  const options = {
    input: "images",
    output: "output.json",
    delayMs: 100,
  };

  for (let i = 0; i < argv.length; i += 1) {
    const arg = argv[i];
    if (arg === "--input" && argv[i + 1]) {
      options.input = argv[i + 1];
      i += 1;
      continue;
    }
    if (arg === "--output" && argv[i + 1]) {
      options.output = argv[i + 1];
      i += 1;
      continue;
    }
    if (arg === "--delay" && argv[i + 1]) {
      const parsed = Number(argv[i + 1]);
      if (!Number.isNaN(parsed) && parsed >= 0) {
        options.delayMs = parsed;
      }
      i += 1;
    }
  }
  return options;
}

function normalizeWhitespace(text) {
  if (!text) return "";
  return text
    .replace(/\r\n/g, "\n")
    .replace(/\r/g, "\n")
    .replace(/[ \t]+/g, " ")
    .replace(/\n{3,}/g, "\n\n")
    .split("\n")
    .map((line) => line.trimEnd())
    .join("\n")
    .trim();
}

function sleep(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

async function collectImagesRecursively(rootDir) {
  const files = [];

  async function walk(currentDir) {
    const entries = await fs.readdir(currentDir, { withFileTypes: true });
    for (const entry of entries) {
      const fullPath = path.join(currentDir, entry.name);
      if (entry.isDirectory()) {
        await walk(fullPath);
      } else if (entry.isFile()) {
        const ext = path.extname(entry.name).toLowerCase();
        if (SUPPORTED_EXTENSIONS.has(ext)) {
          files.push(fullPath);
        }
      }
    }
  }

  await walk(rootDir);
  files.sort((a, b) => a.localeCompare(b));
  return files;
}

async function ensureParentDir(filePath) {
  const dir = path.dirname(filePath);
  await fs.mkdir(dir, { recursive: true });
}

async function run() {
  const options = parseArgs(process.argv.slice(2));
  const inputDir = path.resolve(options.input);
  const outputFile = path.resolve(options.output);
  const client = new vision.ImageAnnotatorClient();

  try {
    await fs.access(inputDir);
  } catch {
    throw new Error(`Input folder not found: ${inputDir}`);
  }

  const imageFiles = await collectImagesRecursively(inputDir);
  if (imageFiles.length === 0) {
    console.log(`No images found in: ${inputDir}`);
    await ensureParentDir(outputFile);
    await fs.writeFile(outputFile, "[]\n", "utf8");
    console.log(`Wrote empty output: ${outputFile}`);
    return;
  }

  console.log(`Found ${imageFiles.length} image(s) in ${inputDir}`);
  console.log(`Writing output to: ${outputFile}`);

  const results = [];
  for (let i = 0; i < imageFiles.length; i += 1) {
    const absolutePath = imageFiles[i];
    const relativePath = path.relative(inputDir, absolutePath).replace(/\\/g, "/");
    console.log(`Processing image ${i + 1}/${imageFiles.length}: ${relativePath}`);

    try {
      const [response] = await client.textDetection(absolutePath);
      const fullText = response?.fullTextAnnotation?.text ?? "";
      results.push({
        file: relativePath,
        text: normalizeWhitespace(fullText),
      });
    } catch (error) {
      console.error(`OCR failed for ${relativePath}: ${error.message}`);
      results.push({
        file: relativePath,
        text: "",
        error: error.message,
      });
    }

    if (options.delayMs > 0 && i < imageFiles.length - 1) {
      await sleep(options.delayMs);
    }
  }

  await ensureParentDir(outputFile);
  await fs.writeFile(outputFile, `${JSON.stringify(results, null, 2)}\n`, "utf8");
  console.log(`Done. Wrote ${results.length} result(s) to ${outputFile}`);
}

run().catch((error) => {
  console.error(`Fatal error: ${error.message}`);
  process.exitCode = 1;
});

