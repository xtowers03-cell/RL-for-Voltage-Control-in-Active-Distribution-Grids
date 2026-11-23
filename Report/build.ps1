$ErrorActionPreference = "Stop"
Push-Location $PSScriptRoot

try {
    # Refresh PATH from Windows Registry so newly installed MiKTeX is found
    $env:Path = [Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [Environment]::GetEnvironmentVariable("Path", "User")

    $pdflatexArgs = @("-synctex=1", "-interaction=nonstopmode", "-file-line-error", "main.tex")

    Write-Host "[1/4] Running pdflatex (pass 1)..." -ForegroundColor Cyan
    & pdflatex @pdflatexArgs
    if ($LASTEXITCODE -ne 0) { throw "pdflatex pass 1 failed with exit code $LASTEXITCODE" }

    Write-Host "[2/4] Running bibtex..." -ForegroundColor Cyan
    & bibtex main
    if ($LASTEXITCODE -ne 0) { throw "bibtex failed with exit code $LASTEXITCODE" }

    Write-Host "[3/4] Running pdflatex (pass 2)..." -ForegroundColor Cyan
    & pdflatex @pdflatexArgs
    if ($LASTEXITCODE -ne 0) { throw "pdflatex pass 2 failed with exit code $LASTEXITCODE" }

    Write-Host "[4/4] Running pdflatex (pass 3)..." -ForegroundColor Cyan
    & pdflatex @pdflatexArgs
    if ($LASTEXITCODE -ne 0) { throw "pdflatex pass 3 failed with exit code $LASTEXITCODE" }

    # Remove LaTeX auxiliary files after successful build
    $auxExts = @("*.aux", "*.bbl", "*.blg", "*.lof", "*.log", "*.lot", "*.out", "*.toc", "*.synctex.gz")
    Get-ChildItem -Path (Join-Path $PSScriptRoot "*") -Include $auxExts -File | Remove-Item -Force -ErrorAction SilentlyContinue

    Write-Host "Build completed successfully: $(Join-Path $PSScriptRoot 'main.pdf')" -ForegroundColor Green
}
finally {
    Pop-Location
}
