# Apple 미니멀 리디자인 구현 계획

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 랜딩, 케이스 3, print를 스펙의 토큰 체계(흰 배경, Pretendard, accent 1색, 다크 자동)로 다시 만든다.

**Architecture:** `_layouts/default.html`이 네비, 푸터, lightbox를 갖고, `index.html`과 `_layouts/case.html`이 이를 상속한다. 스타일은 `_sass/portfolio.scss` 한 파일. `print.html`은 독립 문서라 자체 `<style>`만 교체한다.

**Tech Stack:** Jekyll (github-pages gem), SCSS, Pretendard CDN, 크롬 헤드리스(Windows).

**Spec:** `docs/superpowers/specs/2026-09-03-apple-minimal-redesign-design.md`

## Global Constraints

- push 금지. 커밋까지만.
- 비공개 단어 금지: 보드 제조사명, 제품 코드명, 고객사명.
- `case-*.md`, `_data/data_ko.yml`, `assets/*` 수정 금지.
- 문체: 담백한 평서문.
- 미리보기 서버: `bundle exec jekyll serve --host 0.0.0.0 --port 4000 --force_polling` (WSL, 이 저장소 소스).

---

### Task 1: 토큰 + 공용 레이아웃 + 랜딩

**Files:**
- Create: `_layouts/default.html`
- Rewrite: `_sass/portfolio.scss`, `index.html`
- Modify: `_includes/footer.html`

- [ ] `_sass/portfolio.scss`에 스펙 섹션 2 토큰(`:root`, dark media), base, `.nav`, `.hero`, `.stats`, `.block`/`.sec-head`, `.card`, `.how`, `.rows`, `.chip`, `.pill`, `footer`, `.lightbox`, reduced-motion, reduced-transparency, 760px 미디어 쿼리 작성. 시안 아티팩트 CSS를 기준으로 옮기되 Pretendard 링크는 레이아웃 head에.
- [ ] `_layouts/default.html`: head(charset, viewport, title `{{ page.title | default: site.title }}`, description, Pretendard link, main.css) + `<nav class="nav">` + `{{ content }}` + `{% include footer.html %}` + lightbox 스크립트(셀렉터 `.card figure img, .case main img`, 카드 안 이미지는 `preventDefault`).
- [ ] `index.html`: front matter `layout: default`, `permalink: /`. 본문은 시안 마크업 그대로(스펙 섹션 3), 링크는 `relative_url`로 실제 경로.
- [ ] `_includes/footer.html`: `<footer class="site-footer wrap">` 안에 면책 + (c). `data_file` 없을 때 대비 `site.data.data_ko` 직접 참조.
- [ ] 검증: `bundle exec jekyll build` 에러 0. `_site/index.html`에 `IBM Plex`, `#556B2F` 없음.
- [ ] 커밋 `feat: apple minimal landing - tokens, default layout, cards`

### Task 2: 케이스 페이지

**Files:**
- Rewrite: `_layouts/case.html`
- Modify: `_sass/portfolio.scss` (`.case` 블록)

- [ ] `_layouts/case.html`: front matter `layout: default`. 본문 `<div class="wrap case">` -> `<- Work` 링크(`/#work`) -> 라벨 "Case study" -> h1 -> meta(기간, 역할) -> `<main>{{ content }}</main>`.
- [ ] `.case` 스타일: 스펙 섹션 5 (본문 680px, h2 22px 700, 표, code, pre, blockquote, img 규칙).
- [ ] 검증: build 후 `_site/case/jetson-vi5/index.html` 존재, 표 `<table>` 감싸는 overflow 컨테이너는 CSS `display:block; overflow-x:auto`로 처리.
- [ ] 커밋 `feat: case pages on default layout`

### Task 3: print

**Files:**
- Modify: `print.html` (`<link>` 폰트 + `<style>` 블록만)

- [ ] IBM Plex 링크 -> Pretendard 링크. `<style>` 색상 teal, terra -> 스펙 섹션 6 값. `.mono`는 `ui-monospace` 스택.
- [ ] 검증: `scripts/make-pdf.sh` -> `portfolio_sangmin.pdf` 생성, `pdfinfo`(있으면) 또는 크롬 결과로 4페이지 확인.
- [ ] 커밋 `feat(print): pretendard + neutral palette`

### Task 4: 검증, 문서

- [ ] 서버 기동 후 5개 URL 200 (`curl -s -o /dev/null -w "%{http_code}"`).
- [ ] `grep -rn "IBM Plex\|#556B2F\|#4D7C7D\|#C97A5C" _site` 결과 0.
- [ ] 비공개 단어(보드 제조사명, 제품 코드명, 고객사명) grep 결과 0.
- [ ] 크롬 헤드리스 스크린샷 4장(랜딩 1280 라이트, 다크, 랜딩 390, 케이스 1280) -> 육안 확인 -> SendUserFile로 전송.
- [ ] `README.md` 테마 설명 한 줄 갱신(IBM Plex, 청록 -> Pretendard, 흰 배경, 파랑 accent), 레이아웃 설명 갱신.
- [ ] 커밋 `docs: readme for redesigned theme`
