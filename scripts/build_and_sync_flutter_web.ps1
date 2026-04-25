$ErrorActionPreference = "Stop"

$rootDir = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$frontendDir = Join-Path $rootDir "frontend_flutter"
$buildDir = Join-Path $frontendDir "build\web"
$targetDir = Join-Path $rootDir "public\flutter-web"
$flutterBin = if ($env:FLUTTER_BIN) { $env:FLUTTER_BIN } else { "flutter" }

if (-not (Get-Command $flutterBin -ErrorAction SilentlyContinue)) {
  throw "Flutter CLI not found. Set FLUTTER_BIN or add flutter to PATH."
}

if (-not (Test-Path $frontendDir)) {
  throw "Missing frontend directory at $frontendDir"
}

$buildArgs = $args
if (-not $buildArgs -or $buildArgs.Count -eq 0) {
  $buildArgs = @("--release", "--pwa-strategy=none", "--no-tree-shake-icons")
}

Write-Host "Running Flutter dependency sync..."
& $flutterBin pub get --directory $frontendDir
if ($LASTEXITCODE -ne 0) {
  throw "flutter pub get failed."
}

Write-Host "Building Flutter web bundle..."
Push-Location $frontendDir
try {
  & $flutterBin build web @buildArgs
  if ($LASTEXITCODE -ne 0) {
    throw "flutter build web failed."
  }
} finally {
  Pop-Location
}

if (-not (Test-Path (Join-Path $buildDir "index.html")) -or
    -not (Test-Path (Join-Path $buildDir "main.dart.js")) -or
    -not (Test-Path (Join-Path $buildDir "flutter_bootstrap.js"))) {
  throw "Build output is missing required Flutter web artifacts."
}

Write-Host "Syncing Flutter web bundle into public/flutter-web..."
New-Item -ItemType Directory -Force -Path $targetDir | Out-Null
robocopy $buildDir $targetDir /MIR /NFL /NDL /NJH /NJS /NP | Out-Null
if ($LASTEXITCODE -gt 3) {
  throw "robocopy failed with exit code $LASTEXITCODE"
}

Write-Host "Flutter web bundle is ready in $targetDir"
