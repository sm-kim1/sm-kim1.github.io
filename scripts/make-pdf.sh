#!/usr/bin/env bash
# 포트폴리오 PDF 생성 — jekyll serve가 4000 포트에 떠 있어야 함
# 사용: scripts/make-pdf.sh  → 저장소 루트에 portfolio_sangmin.pdf 생성
set -e
cd "$(dirname "$0")/.."

curl -sf -o /dev/null http://localhost:4000/print/ || { echo "jekyll serve 먼저 실행 필요 (bundle exec jekyll serve)"; exit 1; }

# Windows 크롬은 WSL localhost 포워딩이 깨질 수 있어 eth0 IP로 직접 접근
WSLIP="$(ip -4 addr show eth0 | grep -oP 'inet \K[\d.]+')"
CHROME="/mnt/c/Program Files/Google/Chrome/Application/chrome.exe"
WINTMP="$(wslpath 'C:\Users\arche\AppData\Local\Temp')/portfolio_sangmin.pdf"

# 전용 프로필: 사용자 크롬이 떠 있어도 headless가 동작하게
"$CHROME" --headless=new --disable-gpu \
  --user-data-dir='C:\Users\arche\AppData\Local\Temp\chrome-headless-profile' \
  --no-pdf-header-footer \
  --print-to-pdf="$(wslpath -w "$WINTMP")" \
  "http://$WSLIP:4000/print/" 2>/dev/null

cp "$WINTMP" portfolio_sangmin.pdf
echo "생성 완료: portfolio_sangmin.pdf ($(du -h portfolio_sangmin.pdf | cut -f1))"
