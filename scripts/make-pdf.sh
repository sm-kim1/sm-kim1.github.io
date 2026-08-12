#!/usr/bin/env bash
# 포트폴리오 PDF 생성 — jekyll serve가 4000 포트에 떠 있어야 함
# 사용: scripts/make-pdf.sh  → 저장소 루트에 portfolio_sangmin.pdf 생성
set -e
cd "$(dirname "$0")/.."

curl -sf -o /dev/null http://localhost:4000/print/ || { echo "jekyll serve 먼저 실행 필요 (bundle exec jekyll serve)"; exit 1; }

CHROME="/mnt/c/Program Files/Google/Chrome/Application/chrome.exe"
WINTMP="$(wslpath 'C:\Users\arche\AppData\Local\Temp')/portfolio_sangmin.pdf"

"$CHROME" --headless=new --disable-gpu --no-pdf-header-footer \
  --print-to-pdf="$(wslpath -w "$WINTMP")" \
  "http://localhost:4000/print/" 2>/dev/null

cp "$WINTMP" portfolio_sangmin.pdf
echo "생성 완료: portfolio_sangmin.pdf ($(du -h portfolio_sangmin.pdf | cut -f1))"
