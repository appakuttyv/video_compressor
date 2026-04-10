# Deployment Script for Flutter Web to GitHub Pages
# Use this script to build and prepare the app for hosting on GH Pages.

$repoName = "video_compressor"
$baseHref = "/$repoName/"

Write-Host "--- Starting Deployment Process for $repoName ---" -ForegroundColor Cyan

# 1. Check if flutter is in path
if (!(Get-Command flutter -ErrorAction SilentlyContinue)) {
    Write-Warning "Flutter command not found in PATH."
    Write-Host "Searching for Flutter SDK in common locations..."
    
    $commonPaths = @(
        "D:\Appakutty\Dev\flutter_sdk\bin",
        "C:\src\flutter\bin",
        "D:\flutter\bin",
        "$env:USERPROFILE\flutter\bin",
        "$env:LOCALAPPDATA\flutter\bin"
    )

    foreach ($path in $commonPaths) {
        if (Test-Path "$path\flutter.bat") {
            Write-Host "Found Flutter at: $path" -ForegroundColor Green
            $env:PATH += ";$path"
            break
        }
    }

    if (!(Get-Command flutter -ErrorAction SilentlyContinue)) {
        Write-Error "Could not find Flutter. Please add Flutter to your PATH or edit this script to include the path."
        exit 1
    }
}

# 2. Build Flutter Web
Write-Host "Building Flutter web release with base-href: $baseHref" -ForegroundColor Blue
flutter build web --release --base-href $baseHref

if ($LASTEXITCODE -ne 0) {
    Write-Error "Flutter build failed."
    exit 1
}

# 3. Prepare docs folder
$docsDir = Join-Path $PSScriptRoot "..\docs"
$buildWebDir = Join-Path $PSScriptRoot "..\build\web"

if (Test-Path $docsDir) {
    Write-Host "Cleaning existing docs directory..." -ForegroundColor Yellow
    Remove-Item -Recurse -Force "$docsDir\*"
} else {
    Write-Host "Creating docs directory..." -ForegroundColor Yellow
    New-Item -ItemType Directory -Path $docsDir
}

# 4. Copy build contents to docs
Write-Host "Copying build output to docs..." -ForegroundColor Green
Copy-Item -Path "$buildWebDir\*" -Destination $docsDir -Recurse -Force

# 5. Routing Fix: Copy index.html to 404.html
Write-Host "Creating 404.html from index.html for SPA routing..." -ForegroundColor Green
Copy-Item -Path "$docsDir\index.html" -Destination "$docsDir\404.html" -Force

Write-Host "--- Deployment preparation complete! ---" -ForegroundColor Cyan
Write-Host "Final steps:"
Write-Host "1. git add docs/"
Write-Host "2. git commit -m 'deploy: web build'"
Write-Host "3. git push origin main"
Write-Host "4. Ensure GitHub Pages is set to use the /docs folder in your repo settings." -ForegroundColor Yellow
