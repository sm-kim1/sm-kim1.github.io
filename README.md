# sm-kim1.github.io

포트폴리오. 자체 제작 미니멀 Jekyll 테마 (Pretendard, 흰 배경 + 파랑 accent, 다크모드 자동).

## 구조

- 랜딩: `index.html` (정적, `layout: default`). 케이스: `case-*.md` (`layout: case`). 경력기술서: `resume.html`(`/resume/`, 웹) + `print.html`(`/print/`, A4 인쇄용). 데이터는 `_data/data_ko.yml`
- 레이아웃: `_layouts/default.html` (네비, 푸터, lightbox 공용) -> `_layouts/case.html`
- 스타일: `_sass/portfolio.scss` 단일 파일. 색, 폰트는 `:root` 토큰
- 다이어그램: `assets/diagram-*.svg` - 공통 스타일(제목 블록, 점 패턴 배경, 그림자 카드, 상태 알약), viewBox 1600x900

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

`/print/` 가 A4용 경력기술서. `scripts/make-pdf.sh`로 PDF 생성 (WSL + Windows 크롬).
