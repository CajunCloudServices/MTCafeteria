import { spawnSync } from "node:child_process";
import path from "node:path";
import { fileURLToPath } from "node:url";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const args = process.argv.slice(2);

const run = (command, commandArgs) => {
  const result = spawnSync(command, commandArgs, {
    cwd: path.resolve(__dirname, ".."),
    stdio: "inherit",
    shell: false,
  });
  if (result.error) {
    throw result.error;
  }
  process.exit(result.status ?? 1);
};

if (process.platform === "win32") {
  run("powershell", [
    "-NoProfile",
    "-ExecutionPolicy",
    "Bypass",
    "-File",
    path.join("scripts", "build_and_sync_flutter_web.ps1"),
    ...args,
  ]);
} else {
  run("bash", [path.join("scripts", "build_and_sync_flutter_web.sh"), ...args]);
}
