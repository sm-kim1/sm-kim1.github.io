# 포트폴리오 전면 리디자인 - Apple식 미니멀 화이트

작성: 2026-09-03. 대상: `sm-kim1.github.io` 전체 (랜딩, 케이스 3, print).
시안: 랜딩 A안 아티팩트 (세션 내 승인됨).

## 1. 목표

- 채용담당자가 첫 화면에서 정체성 한 문장과 핵심 수치 4개를 바로 본다.
- 케이스 3건이 페이지의 중심. 카드 전체가 딥다이브 링크.
- 랜딩, 케이스, print가 한 디자인 시스템(색, 폰트, 라벨 체계)을 쓴다.
- 인라인 스타일을 없애고 SCSS 한 파일로 관리한다.

비목표: 케이스 페이지 본문(마크다운) 수정, `data_ko.yml` 데이터 구조 변경, 다이어그램 SVG 내부 색 변경, JS 프레임워크 도입.

## 2. 디자인 토큰

CSS 커스텀 프로퍼티로 `:root`에 정의. 다크는 `prefers-color-scheme: dark`에서 토큰만 재정의.

| 토큰 | 라이트 | 다크 |
|---|---|---|
| `--bg` | `#FFFFFF` | `#000000` |
| `--surface` | `#F5F5F7` | `#1C1C1E` |
| `--ink` | `#1D1D1F` | `#F5F5F7` |
| `--muted` | `#6E6E73` | `#A1A1A6` |
| `--line` | `#E5E5EA` | `#2C2C2E` |
| `--accent` | `#0071E3` | `#2997FF` |
| `--nav` | `rgba(255,255,255,.72)` | `rgba(0,0,0,.72)` |

폰트
- 본문/제목: Pretendard Variable - jsDelivr CDN (`https://cdn.jsdelivr.net/gh/orioncactus/pretendard@v1.3.9/dist/web/variable/pretendardvariable-dynamic-subset.min.css`), `display=swap`. 폴백 `-apple-system, BlinkMacSystemFont, "Apple SD Gothic Neo", "Noto Sans KR", system-ui, sans-serif`
- 수치/기간/코드: `ui-monospace, "SF Mono", Menlo, Consolas, monospace`, `font-variant-numeric: tabular-nums`
- IBM Plex 링크 전부 제거

타이포 스케일
- 히어로 h1: `clamp(34px, 5vw, 56px)` / 1.12 / -0.025em / 700
- 섹션 h2: `clamp(26px, 3.2vw, 34px)` / 1.2 / -0.02em / 700
- 카드 h3: 24px / 1.25 / -0.02em / 700
- 본문: 17px / 1.6 / 0
- 보조: 15px, 14px (`--muted`)
- 라벨: 12px / 600 / +0.06em / uppercase / `--muted`

간격, 형태
- 콘텐츠 폭 980px, 좌우 패딩 24px. 단락 최대 640px
- 섹션 간격 `clamp(72px, 10vw, 128px)`
- 카드 모서리 22px(모바일 18px), 내부 패딩 36px(모바일 24px). 버튼/칩 999px
- 카드 그림자: 기본 없음, hover `0 2px 4px rgba(0,0,0,.05), 0 24px 48px rgba(0,0,0,.10)` (다크는 alpha .5/.6)

## 3. 랜딩 (`index.html`)

위에서 아래 순서. 글은 시안 문구 그대로. 수치/불릿은 기존 사이트 것 유지.

1. **네비** - sticky, `backdrop-filter: blur(20px) saturate(180%)`, `--nav` 배경, 아래 1px `--line`. 높이 52px. 왼쪽 "Sangmin Kim"(홈), 오른쪽 Work, How I work, Resume, 인쇄용 -> (`/print/`). 모바일에서 "인쇄용" 숨김.
2. **히어로** - 라벨 "Embedded Platform Engineer, 5+ yrs" -> h1 "Jetson 커스텀 보드의 커널부터 ROS2까지, 자율주행 플랫폼을 만듭니다." -> 설명 2줄(시안 문구) -> 알약 버튼 3개(이메일 보내기 = accent 채움, GitHub, LinkedIn = 테두리). 오른쪽 프로필 사진 88px 원형 (`object-position: top`). 모바일: 사진 64px, 위로.
3. **핵심 수치** - 위아래 1px 선, 4열(모바일 2열). 66h / 91% / 23% / 5건. 숫자 40px 700 -0.03em, 단위는 22px `--muted`. 설명 14px.
4. **Work** - 라벨 "Work" + h2 "대표 작업 세 건". 카드 3장 세로 배치, 간격 24px. 카드 = `<a>` 전체 링크. 2열 grid(글 | 다이어그램), CS-02는 1열 + 칩 4개. 각 카드: 모노 `CS-0N, 기간` -> h3 -> 한 줄 요약(`--muted`) -> 불릿 3개(accent 점) -> "... ->" 링크 텍스트(accent). 다이어그램은 `--bg` 배경 + 1px `--line` + 14px 모서리, 클릭 시 lightbox.
5. **How I work** - 라벨 + h2 "일하는 방식". 3열(모바일 1열). 소제목 17px 600, 불릿 "-" accent. 기존 문구 그대로 (번호 "01 -" 제거).
6. **Other work** - 라벨 + h2 "그 밖의 작업". 4행 grid `160px 1fr`, 위아래 1px 선. 기존 문구 그대로.
7. **Resume** - 라벨 + h2 "요약", 오른쪽 "기술경력서 전체 보기 (인쇄용) ->". 5행(Career, Education, R&D, Patents, Skills). Skills는 칩.
8. **푸터** - 면책 문구 + (c) 2026 Sangmin Kim.

## 4. 공용 레이아웃

- `_layouts/default.html` 신설: head(메타, Pretendard 링크, `/assets/css/main.css`) + 네비 + `{{ content }}` + 푸터 + lightbox 스크립트.
- `_layouts/case.html`은 `layout: default`를 쓰고 케이스 헤더만 남긴다.
- `index.html`도 `layout: default`. 인라인 `<style>`, 스타일 속성 전부 제거.
- `_includes/footer.html`은 default가 사용. `data_ko.yml`의 `disclaimer` 그대로 읽음.

## 5. 케이스 페이지

- 네비 아래 "<- Work" 링크(`/#work`), 라벨 "Case study", h1 `clamp(28px, 4vw, 40px)`, 기간, 역할 한 줄 `--muted`.
- 본문 폭 680px, 17px / 1.7.
- h2: 22px 700 -0.02em, 위 48px 아래 14px. 모노 라벨, 밑줄 없음.
- h3: 18px 600.
- 표: `--surface` 헤더, 셀 경계 `--line`, 표 전체 14px 모서리 + overflow-x auto.
- 코드 인라인: `--surface` 배경, 4px 모서리. pre: `--surface` 배경, 14px 모서리, 14px 폰트.
- blockquote: 왼쪽 3px accent 선, `--surface` 배경, 14px 모서리.
- 이미지: 1px `--line` + 14px 모서리, 클릭 lightbox.
- 마크다운 본문, front matter는 수정하지 않는다.

## 6. print (`/print/`)

- 폰트 Pretendard로 교체(IBM Plex 제거). 폴백 동일.
- 색: 본문 `#1D1D1F`, 보조 `#6E6E73`, 선 `#D2D2D7`, 배경 박스 `#F5F5F7`. teal, terra 계열 전부 제거. 역할 줄(`.roleline`)은 검정 600.
- 라벨: 12pt->8pt 그대로, 검정 600, 아래 1pt 검정 선.
- 페이지 구조, 섹션 순서, `break-before`, A4 여백, `data_ko.yml` 읽는 방식 전부 유지.
- 완료 기준: `scripts/make-pdf.sh`로 재생성, 페이지 수 4 유지, 표/불릿 잘림 없음.

## 7. 모션, 접근성

- CSS만. 카드 hover `translateY(-3px)` + 그림자, `transition .25s cubic-bezier(.2,.8,.2,1)`. 카드 active `scale(.995)`.
- 알약 버튼 active `scale(.97)`, hover `--surface`.
- 카드 링크 화살표 hover `translateX(3px)`.
- 네비 앵커 `scroll-behavior: smooth`.
- `@media (prefers-reduced-motion: reduce)`: transition, transform, smooth scroll 전부 끔.
- `@media (prefers-reduced-transparency: reduce)`: 네비 배경 불투명, blur 제거.
- 포커스: `:focus-visible` 2px accent 아웃라인.
- 카드 `<a>` 안에 h3, p, ul이 들어가므로 카드에 `aria-label` 불필요. 이미지 alt 유지.
- 라이트, 다크 모두 텍스트 대비 4.5:1 이상 (`--muted` on `--bg`, `--muted` on `--surface` 확인).

## 8. JS

- lightbox 하나. 기존 `index.html` 스크립트를 default 레이아웃으로 옮기고 셀렉터를 `.card figure img, .case main img`로 바꿈. 카드 `<a>` 안 이미지 클릭 시 `preventDefault`로 링크 이동 막고 lightbox 열기.

## 9. 파일 변경 목록

| 파일 | 변경 |
|---|---|
| `_layouts/default.html` | 신설 |
| `_layouts/case.html` | default 상속, 헤더만 |
| `index.html` | 전면 재작성 (layout: default) |
| `_sass/portfolio.scss` | 전면 재작성 (토큰, 랜딩, 케이스, lightbox) |
| `print.html` | 스타일 블록만 교체 |
| `_includes/footer.html` | 클래스명 맞춤 |
| `README.md` | 구조 설명 갱신 (테마 설명 한 줄) |
| `case-*.md`, `_data/data_ko.yml`, `assets/*` | 변경 없음 |

## 10. 검증

1. `bundle exec jekyll build` 경고, 에러 0.
2. `/`, `/case/jetson-vi5/`, `/case/yocto/`, `/case/component-manager/`, `/print/` 5개 200.
3. 빌드 결과에 `IBM Plex`, `#556B2F`, `#4D7C7D`, `#C97A5C` 문자열 없음 (grep).
4. 크롬 헤드리스 스크린샷: 랜딩 1280px, 390px, 케이스 1280px, 라이트, 다크(`--force-dark-mode`) 육안 확인.
5. `scripts/make-pdf.sh` 성공, 4페이지.
6. 비공개 원칙 grep: 보드 제조사명, 제품 코드명, 고객사명 없음.

## 11. 규칙

- push 금지. 커밋까지만.
- 문체: 담백한 평서문. "A가 아닌 B" 대조, 격언식 마무리 금지.
- `HANDOFF.md`, `docs/TODO.md`, `*.pdf` 커밋 금지.
