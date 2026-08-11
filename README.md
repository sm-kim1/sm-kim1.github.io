# sm-kim1.github.io

포트폴리오. 자체 제작 미니멀 단일 컬럼 Jekyll 테마 (IBM Plex, 종이색 + 청록 팔레트).

## 구조

- 내용: `_data/data_ko.yml` — 모든 섹션 텍스트가 여기 있음. 프로젝트 추가 = `projects.assignments`에 항목 추가 (`image` 키는 선택)
- 레이아웃: `_layouts/default.html` + `_includes/s-*.html` (섹션별)
- 스타일: `_sass/portfolio.scss` 단일 파일
- 다이어그램: `assets/diagram-*.svg` — 공통 스타일(제목 블록 · 점 패턴 배경 · 그림자 카드 · 상태 알약), viewBox 1600×900

## 로컬 미리보기

```bash
bundle install          # 최초 1회 (vendor/bundle에 설치됨)
bundle exec jekyll serve
# http://localhost:4000
```

GitHub Pages와 동일한 `github-pages` gem을 쓰므로 로컬 결과 = 배포 결과.

## 배포

`main`에 push하면 GitHub Pages가 자동 빌드한다.

## 인쇄

별도 인쇄 페이지 없음 — 브라우저 인쇄로 충분 (`@media print` 스타일 포함).
