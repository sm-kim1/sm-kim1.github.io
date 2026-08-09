# 포트폴리오 사이트 재디자인 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** online-cv 테마를 걷어내고 미니멀 단일 컬럼 · IBM Plex 테크 미니멀 디자인으로 재작성, 다이어그램 4종 재작성.

**Architecture:** Jekyll + `_data/data_ko.yml` 데이터 구조 유지. `_layouts/default.html` + 섹션별 `_includes/` + 단일 SCSS로 재구성. Bootstrap/FontAwesome 등 플러그인 전부 제거.

**Tech Stack:** Jekyll (GitHub Pages), SCSS, IBM Plex Sans KR / IBM Plex Mono (Google Fonts), 순수 SVG 다이어그램.

## Global Constraints

- 팔레트: 종이 `#FAFAF7`, 잉크 `#1A1A1A`, 보조 `#77756C`, 청록 `#4D7C7D`/`#2F5959`, 테라코타 `#C97A5C`, 헤어라인 `#E5E2D8`
- 본문 최대 폭 820px, 단일 컬럼
- 섹션 라벨 형식: `01 · ABOUT` (IBM Plex Mono, letter-spacing 3px, 청록 상단 2px 선)
- 다이어그램 viewBox 1600×900, 스타일 계약: 제목 블록(테라코타 바 + `DIAGRAM NN`) / 점 패턴 배경 / 틴트 밴드 / 그림자 카드 / 상태 알약 / 라벨 곡선 화살표 — 승인 샘플: `.superpowers/brainstorm/17823-1786318469/content/diagram-01-redraw-sample.svg`
- 검증 기본형: `bundle exec jekyll build` 무오류 + 육안 확인
- 커밋은 task 단위

---

### Task 1: 빌드 환경 구축

**Files:** 없음 (환경만)

- [ ] ruby + bundler 설치: `sudo apt-get install -y ruby-full build-essential zlib1g-dev`
- [ ] `bundle config set --local path 'vendor/bundle' && bundle install`
- [ ] `vendor/`를 `.gitignore`에 추가
- [ ] 현재(구버전) 사이트 빌드 확인: `bundle exec jekyll build` → exit 0
- [ ] Commit: `chore: local jekyll build env`

### Task 2: 경력 데이터 통합

**Files:**
- Modify: `_data/data_ko.yml:35-55` (experiences)

**Produces:** experiences 스키마 = `info: [{company, time, note, roles: [{role, time, details}]}]`

- [ ] experiences를 아래로 교체 (불릿 내용은 기존 그대로 복사):

```yaml
experiences:
  title: 경력
  info:
    - company: ACEWORKS Korea
      time: 2021.07 — 현재
      note: 2023.11 인수합병에 따라 ACELAB에서 사명 변경
      roles:
        - role: Senior Research Engineer
          time: 2023.11 — 현재
          details: |
            [기존 ACEWORKS Korea 불릿 5개 그대로]
        - role: Research Engineer
          time: 2021.07 — 2023.10
          details: |
            [기존 ACELAB 불릿 5개 그대로]
```

- [ ] 검증: `ruby -ryaml -e 'YAML.load_file("_data/data_ko.yml")' ` → 무오류
- [ ] Commit: `feat: merge career entries with M&A rename note`

### Task 3: 레이아웃 + SCSS 기반 + 헤더/푸터

**Files:**
- Rewrite: `_layouts/default.html`, `assets/css/main.scss`
- Create: `_sass/portfolio.scss`, `_includes/header.html`, `_includes/footer.html`
- Modify: `index.html`, `_config.yml`

**Produces:** CSS 클래스 계약 — `.wrap`(820px 컬럼), `.section`, `.section-label`, `.chip`, `.meta`(모노 보조), `.figure`(이미지 액자)

- [ ] `_layouts/default.html`: html lang=ko / head(구글폰트 IBM Plex Sans KR·IBM Plex Mono, title, description) / body > header include + `{{ content }}` + footer include. 기존 head.html의 SEO 메타 중 필요분만 인라인
- [ ] `_includes/header.html`: 이름(h1) + tagline + 이메일·GitHub·LinkedIn 텍스트 링크 한 줄 (`sidebar` 데이터 사용, 아이콘 없음)
- [ ] `_includes/footer.html`: `© 2026 Sangmin Kim` 한 줄 (online-cv 크레딧 제거, `footer` 데이터 대신 하드코딩하고 data의 footer 키 삭제)
- [ ] `_sass/portfolio.scss`: 변수(팔레트) / reset 최소 / 타이포 / `.wrap` / `.section` + `.section-label` / `.chip` / `.meta` / `.figure` / 반응형(640px 브레이크) / `@media print`(배경 흰색, 그림자 제거)
- [ ] `assets/css/main.scss`: front-matter 2줄 + `@import "portfolio";` 만
- [ ] `index.html`: 새 include 목록으로 교체 (about, skills, experiences, projects, publications, education — 아직 없는 include는 Task 4에서. 이 시점엔 임시로 빈 상태 OK. `data_file` 변수 유지)
- [ ] `_config.yml`: theme_skin, chrome_mobile_color, compress 관련 등 테마 잔재 제거. title/description/sass 설정 유지, description 문구를 실제 소개로 교체
- [ ] `bundle exec jekyll serve --port 4001` 육안: 헤더+푸터 렌더
- [ ] Commit: `feat: new minimal layout, base styles, header/footer`

### Task 4: 섹션 includes 6종

**Files:**
- Create: `_includes/s-about.html`, `_includes/s-skills.html`, `_includes/s-experiences.html`, `_includes/s-projects.html`, `_includes/s-publications.html`, `_includes/s-education.html`
- Modify: `index.html`

**Consumes:** Task 2 experiences 스키마, Task 3 CSS 클래스

- [ ] `s-about.html`: `01 · ABOUT` 라벨 + summary(markdownify)
- [ ] `s-skills.html`: `02 · SKILLS` + toolset 그룹명(모노) : 칩 나열
- [ ] `s-experiences.html`: `03 · EXPERIENCE` + 회사 블록(회사명 + 기간 + note 이탤릭) > 역할별(role + 기간 모노 + details markdownify)
- [ ] `s-projects.html`: `04 · PROJECTS` + 프로젝트별: 제목(h3) + `.meta`(period · role) + tagline + details(markdownify) + `{% if a.image %}` `.figure` img — **이미지 없으면 figure 생략** (project-08 누락 대응)
- [ ] `s-publications.html`: `05 · PATENTS` + 제목/출원번호 목록
- [ ] `s-education.html`: `06 · EDUCATION` + degree/university
- [ ] `index.html`에 6개 연결, 구 include 참조 제거
- [ ] 육안: 전 섹션 렌더, 굵게(`**`) 처리 확인, Stack 줄 표시 확인
- [ ] Commit: `feat: all content sections in new design`

### Task 5: 다이어그램 4종 재작성

**Files:**
- Rewrite: `assets/diagram-01-component-manager.svg`, `assets/diagram-02-common-architecture.svg`, `assets/diagram-03-multi-domain.svg`, `assets/diagram-10-data-collection.svg`

**Consumes:** 승인 샘플 스타일 계약 (Global Constraints). 01은 샘플을 그대로 정식화.

- [ ] 01: 샘플 SVG를 assets로 복사·정리 (aria-label 유지)
- [ ] 02: 기존 내용(STANAG/JAUS 공통 메시지 구조) 재배치 — 제목 블록 `DIAGRAM 02`, 계층 밴드(모듈들 → 공통 메시지 레이어 → ROS2 pub/sub), 라벨 화살표
- [ ] 03: 기존 내용(Multi-domain 분리) 재배치 — 도메인별 틴트 카드 + domain id 알약 + 경계 표현
- [ ] 10: 기존 내용(데이터 수집 파이프라인) 재배치 — 차량 → 수집 → snapshot/저장 흐름, 스토리지·네트워크 관리 표현
- [ ] 각 SVG를 브라우저로 열어 육안 확인 (visual companion 서버로 사용자 확인 1회)
- [ ] Commit: `feat: redraw all four project diagrams`

### Task 6: 구자산 삭제 + 정리

**Files:**
- Delete: `assets/plugins/`, `en/`, `_data/data_en.yml`, `print.html`, `_layouts/print.html`, `_layouts/compress.html`, 구 `_includes/`(about, analytics, career-profile, certifications, contact, education, experiences, head, interests, language, oss-contributions, projects, publications, recommendations, scripts, sidebar, skills, footer 구버전), `assets/images/` 스킨 jpg들, 구 `_sass/` 테마 파일
- Modify: `_config.yml` (compress_html 블록 제거 확인)

- [ ] 삭제 실행 후 `grep -r "plugins\|data_en\|print.html" _layouts _includes index.html _config.yml` → 참조 0건
- [ ] `bundle exec jekyll build` → exit 0, `_site/`에 plugins/en 없음 확인
- [ ] `du -sh _site` 확인 (30MB → 수 MB 기대)
- [ ] Commit: `chore: remove theme assets, english version, print page`

### Task 7: 최종 검증

- [ ] `bundle exec jekyll serve --port 4001` — 데스크톱/모바일 폭(devtools) 육안
- [ ] 브라우저 인쇄 미리보기 1회
- [ ] 사용자 승인 (visual companion 또는 localhost:4001 직접)
- [ ] 잔여 이슈 수정 후 Commit: `fix: final polish after review`
