#!/usr/bin/env bash
# 포트폴리오 PDF 생성 - jekyll serve가 4000 포트에 떠 있어야 함
# 사용: scripts/make-pdf.sh [경로] [출력파일]  -> 기본 /print/ -> portfolio_sangmin.pdf
set -e
cd "$(dirname "$0")/.."
PAGE="${1:-/print/}"
OUT="${2:-portfolio_sangmin.pdf}"

curl -sf -o /dev/null "http://localhost:4000$PAGE" || { echo "jekyll serve 먼저 실행 필요 (bundle exec jekyll serve)"; exit 1; }

# WSL이 mirrored 네트워킹이라 Windows 크롬에서 localhost로 WSL 서버에 바로 닿는다
CHROME="/mnt/c/Program Files/Google/Chrome/Application/chrome.exe"
WINTMP="$(wslpath 'C:\Users\arche\AppData\Local\Temp')/$(basename "$OUT")"

# 이전 실행 결과가 남아 있으면 크롬이 실패해도 그걸 복사하게 되므로 먼저 지운다
rm -f "$WINTMP"

# 전용 프로필: 사용자 크롬이 떠 있어도 headless가 동작하게
"$CHROME" --headless=new --disable-gpu \
  --user-data-dir='C:\Users\arche\AppData\Local\Temp\chrome-headless-profile' \
  --no-pdf-header-footer \
  --print-to-pdf="$(wslpath -w "$WINTMP")" \
  "http://localhost:4000$PAGE" 2>/dev/null || true

# WSL에서 띄운 크롬은 부모 프로세스가 먼저 끝나고 파일은 몇 초 뒤에 써진다 - 최대 60초 대기
for _ in $(seq 1 60); do [ -s "$WINTMP" ] && break; sleep 1; done
[ -s "$WINTMP" ] || { echo "PDF 생성 실패: 크롬이 파일을 만들지 않았음"; exit 1; }

cp "$WINTMP" "$OUT"
echo "생성 완료: $OUT ($(du -h "$OUT" | cut -f1))"
