$port = 8080
$prefix = "http://localhost:$port/"
$root = "C:\Users\alex dream - alf\.gemini\antigravity\scratch\islamic_prayer_app\build\web"

$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add($prefix)
try {
    $listener.Start()
    Write-Host "Server successfully started at $prefix"
} catch {
    Write-Host "Port $port might be in use, trying 8085..."
    $port = 8085
    $prefix = "http://localhost:$port/"
    $listener = New-Object System.Net.HttpListener
    $listener.Prefixes.Add($prefix)
    $listener.Start()
    Write-Host "Server successfully started at $prefix"
}

while ($listener.IsListening) {
    try {
        $context = $listener.GetContext()
        $request = $context.Request
        $response = $context.Response

        $localPath = $request.Url.LocalPath.TrimStart('/')
        if ([string]::IsNullOrEmpty($localPath)) { $localPath = "index.html" }
        $filePath = Join-Path $root $localPath

        if (-not (Test-Path $filePath -PathType Leaf)) {
            # Only rewrite to index.html for routes (not missing static assets)
            $extTest = [System.IO.Path]::GetExtension($localPath).ToLower()
            if ([string]::IsNullOrEmpty($extTest) -or $extTest -eq ".html") {
                $filePath = Join-Path $root "index.html"
            } else {
                $response.StatusCode = 404
                $response.Close()
                continue
            }
        }

        $ext = [System.IO.Path]::GetExtension($filePath).ToLower()
        $contentType = switch ($ext) {
            ".html"  { "text/html; charset=utf-8" }
            ".js"    { "application/javascript; charset=utf-8" }
            ".mjs"   { "application/javascript; charset=utf-8" }
            ".json"  { "application/json; charset=utf-8" }
            ".css"   { "text/css; charset=utf-8" }
            ".png"   { "image/png" }
            ".jpg"   { "image/jpeg" }
            ".jpeg"  { "image/jpeg" }
            ".webp"  { "image/webp" }
            ".svg"   { "image/svg+xml" }
            ".wasm"  { "application/wasm" }
            ".ttf"   { "font/ttf" }
            ".otf"   { "font/otf" }
            ".woff"  { "font/woff" }
            ".woff2" { "font/woff2" }
            default  { "application/octet-stream" }
        }

        $bytes = [System.IO.File]::ReadAllBytes($filePath)
        $response.ContentType = $contentType
        $response.ContentLength64 = $bytes.Length
        $response.AddHeader("Access-Control-Allow-Origin", "*")
        $response.AddHeader("Cache-Control", "no-cache, no-store, must-revalidate")
        $response.AddHeader("Pragma", "no-cache")
        $response.AddHeader("Expires", "0")
        $response.OutputStream.Write($bytes, 0, $bytes.Length)
        $response.Close()
    } catch {
        # ignore client disconnects
    }
}
