param(
    [string]$Output = "code_export.html"
)

$ErrorActionPreference = "Stop"

$root = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$outputPath = if ([System.IO.Path]::IsPathRooted($Output)) {
    $Output
} else {
    Join-Path $root $Output
}

$extensions = @(".cpp", ".c", ".h", ".hpp", ".qml", ".ino", ".txt")
$explicitFiles = @("CMakeLists.txt")
$ignoredDirs = @(
    "\.git\",
    "\build\",
    "\cmake-build-",
    "\.vs\",
    "\.vscode\"
)

function Test-IgnoredPath {
    param([string]$Path)

    $normalized = ($Path.Replace("/", "\") + "\")
    foreach ($ignored in $ignoredDirs) {
        if ($normalized -like "*$ignored*") {
            return $true
        }
    }

    return $false
}

function ConvertTo-HtmlText {
    param([string]$Text)

    return [System.Net.WebUtility]::HtmlEncode($Text)
}

function Get-RelativePath {
    param(
        [string]$BasePath,
        [string]$TargetPath
    )

    $baseUri = [System.Uri]((Resolve-Path $BasePath).Path.TrimEnd("\") + "\")
    $targetUri = [System.Uri](Resolve-Path $TargetPath).Path
    $relativeUri = $baseUri.MakeRelativeUri($targetUri)

    return [System.Uri]::UnescapeDataString($relativeUri.ToString()).Replace("/", "\")
}

$files = Get-ChildItem -Path $root -Recurse -File |
    Where-Object {
        -not (Test-IgnoredPath $_.FullName) -and
        ($extensions -contains $_.Extension -or $explicitFiles -contains $_.Name)
    } |
    Sort-Object FullName

$generatedAt = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$builder = [System.Text.StringBuilder]::new()

[void]$builder.AppendLine("<!doctype html>")
[void]$builder.AppendLine("<html lang=""tr"">")
[void]$builder.AppendLine("<head>")
[void]$builder.AppendLine("  <meta charset=""utf-8"">")
[void]$builder.AppendLine("  <title>Sliper Kod Dokumu</title>")
[void]$builder.AppendLine("  <style>")
[void]$builder.AppendLine("    @page { margin: 14mm; }")
[void]$builder.AppendLine("    body { font-family: Arial, sans-serif; color: #111827; margin: 0; }")
[void]$builder.AppendLine("    h1 { font-size: 24px; margin: 0 0 8px; }")
[void]$builder.AppendLine("    .meta { color: #4b5563; font-size: 12px; margin-bottom: 24px; }")
[void]$builder.AppendLine("    .toc { border-top: 1px solid #d1d5db; border-bottom: 1px solid #d1d5db; padding: 12px 0; margin-bottom: 24px; }")
[void]$builder.AppendLine("    .toc h2 { font-size: 16px; margin: 0 0 8px; }")
[void]$builder.AppendLine("    .toc ol { margin: 0; padding-left: 22px; }")
[void]$builder.AppendLine("    .toc li { margin: 3px 0; font-family: Consolas, 'Courier New', monospace; font-size: 11px; }")
[void]$builder.AppendLine("    section { break-before: page; }")
[void]$builder.AppendLine("    section:first-of-type { break-before: auto; }")
[void]$builder.AppendLine("    h2 { font-family: Consolas, 'Courier New', monospace; font-size: 15px; margin: 0 0 8px; }")
[void]$builder.AppendLine("    pre { white-space: pre-wrap; word-break: break-word; overflow-wrap: anywhere; font-family: Consolas, 'Courier New', monospace; font-size: 10px; line-height: 1.35; margin: 0; }")
[void]$builder.AppendLine("    code { font-family: inherit; }")
[void]$builder.AppendLine("  </style>")
[void]$builder.AppendLine("</head>")
[void]$builder.AppendLine("<body>")
[void]$builder.AppendLine("  <h1>Sliper Kod Dokumu</h1>")
[void]$builder.AppendLine("  <div class=""meta"">Olusturulma: $generatedAt<br>Dosya sayisi: $($files.Count)</div>")
[void]$builder.AppendLine("  <div class=""toc"">")
[void]$builder.AppendLine("    <h2>Dosyalar</h2>")
[void]$builder.AppendLine("    <ol>")

foreach ($file in $files) {
    $relative = Get-RelativePath -BasePath $root -TargetPath $file.FullName
    [void]$builder.AppendLine("      <li>$(ConvertTo-HtmlText $relative)</li>")
}

[void]$builder.AppendLine("    </ol>")
[void]$builder.AppendLine("  </div>")

foreach ($file in $files) {
    $relative = Get-RelativePath -BasePath $root -TargetPath $file.FullName
    $content = Get-Content -LiteralPath $file.FullName -Raw

    [void]$builder.AppendLine("  <section>")
    [void]$builder.AppendLine("    <h2>$(ConvertTo-HtmlText $relative)</h2>")
    [void]$builder.AppendLine("    <pre><code>$(ConvertTo-HtmlText $content)</code></pre>")
    [void]$builder.AppendLine("  </section>")
}

[void]$builder.AppendLine("</body>")
[void]$builder.AppendLine("</html>")

$outputDirectory = Split-Path -Parent $outputPath
if ($outputDirectory -and -not (Test-Path $outputDirectory)) {
    New-Item -ItemType Directory -Path $outputDirectory | Out-Null
}

[System.IO.File]::WriteAllText($outputPath, $builder.ToString(), [System.Text.UTF8Encoding]::new($false))
Write-Host "HTML hazir: $outputPath"
Write-Host "PDF icin tarayicida acip Ctrl+P -> Microsoft Print to PDF -> Kaydet."
