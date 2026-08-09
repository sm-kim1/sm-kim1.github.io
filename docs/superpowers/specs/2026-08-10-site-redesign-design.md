# 포트폴리오 사이트 재디자인 — 설계 문서

날짜: 2026-08-10
상태: 사용자 승인 대기

## 목표

online-cv 테마 기반 이력서 사이트를 **미니멀 단일 컬럼 · IBM Plex 테크 미니멀** 디자인으로 전면 재작성한다. 프로젝트 다이어그램 4종은 동일 팔레트의 고품질 스타일로 완전 재작성한다.

## 결정 사항 (브레인스토밍 확정)

- 레이아웃: **미니멀 단일 컬럼** (사이드바 제거), 본문 최대 폭 ~820px
- 톤: **IBM Plex 테크 미니멀** — 기존 다이어그램과 동일 팔레트로 사이트·다이어그램 통일
- 언어: **한국어 단일** (영어판 `en/`, `data_en.yml` 제거)
- 인쇄: `print.html` 제거, `@media print` 최소 스타일로 대체
- 다이어그램: 4종 전부 **완전 재작성** (승인된 샘플 스타일: `.superpowers/brainstorm/*/content/diagram-01-redraw-sample.svg`)
- 구현: **테마 제거 후 새로 작성** (Jekyll + data_ko.yml 데이터 구조는 유지)

## 팔레트 / 타이포

| 역할 | 값 |
|---|---|
| 배경(종이) | `#FAFAF7` |
| 본문 잉크 | `#1A1A1A` |
| 보조 텍스트 | `#77756C` |
| 주 포인트(청록) | `#4D7C7D`, 진한 `#2F5959` |
| 강조(테라코타) | `#C97A5C` |
| 헤어라인 | `#E5E2D8` |

- 본문: **IBM Plex Sans KR** (Google Fonts)
- 라벨·날짜·번호·태그: **IBM Plex Mono**
- 섹션 제목: 청록 상단 굵은 선(2px) + `01 · EXPERIENCE` 형식 모노 라벨
- 기술 태그: 청록 아웃라인 모노 칩

## 페이지 구조

```
헤더        이름 / Platform Engineer / 이메일 · GitHub · LinkedIn 한 줄
01 소개     career-profile.summary
02 스킬     toolset 그룹별 칩 나열
03 경력     아래 "경력 통합" 참조
04 프로젝트  9개: 제목 + 기간·역할 메타(모노) + tagline + 불릿 + 이미지 액자 프레임
05 특허     publications 목록
06 학력     education 목록
푸터        © 2026 Sangmin Kim 한 줄 (online-cv 크레딧 제거)
```

자격증·OSS·추천사 섹션: 데이터가 없으므로 include 자체를 만들지 않는다.

## 경력 통합 (데이터 수정)

ACELAB / ACEWORKS Korea 두 항목을 한 회사 블록으로 합친다:

```
ACEWORKS Korea · 2021.07 — 현재
  (2023.11 인수합병에 따라 ACELAB에서 사명 변경)
  ├ Senior Research Engineer · 2023.11 — 현재   [기존 불릿 유지]
  └ Research Engineer · 2021.07 — 2023.10       [기존 불릿 유지]
```

`data_ko.yml`의 experiences 스키마를 회사 1개 + roles 배열 형태로 조정하고 include가 이를 렌더링한다.

## 다이어그램 재작성 (4종)

대상: `diagram-01-component-manager.svg`, `diagram-02-common-architecture.svg`, `diagram-03-multi-domain.svg`, `diagram-10-data-collection.svg`

승인된 샘플 스타일 요소 (내용·구조·텍스트는 기존 유지):

- 다이어그램 내부 제목 블록: 테라코타 세로 바 + `DIAGRAM NN` 모노 라벨 + 제목
- 배경: 종이색 + 옅은 점 패턴, 레이어는 틴트 배경 밴드로 구분
- 카드: 둥근 모서리 + 부드러운 그림자, 상태별 채움색 (청록 틴트 `#EAF1F1` / 테라코타 틴트 `#F8EEE9` / 비활성 점선)
- 상태 알약: LIVE / INIT / FREE 등 상태 표시
- 화살표: 굵기 3px, 곡선, 모노 라벨 (register / hot-plug 등)
- 보조 정보 텍스트로 실제 시스템 느낌 (uptime, 스택 정보 등)
- viewBox 1600×900 유지

## 파일 작업

| 작업 | 대상 |
|---|---|
| 재작성 | `_layouts/default.html`, `_sass/` 전체(새 SCSS, 목표 ~300줄), `_includes/` 섹션별 새 파일 |
| 수정 | `_data/data_ko.yml` (경력 통합), `_config.yml` (테마 설정 제거, title 유지), `index.html`, `assets/css/main.scss` 진입점 |
| 삭제 | `assets/plugins/` (30MB), `en/`, `_data/data_en.yml`, `print.html`, `_layouts/print.html`, 테마 스킨 이미지(`assets/images/*.jpg` 스킨들), 안 쓰는 `_includes/*` |
| 유지 | `_data/data_ko.yml` 내용, 프로젝트 사진 5장, `assets/profile.jpeg`, GitHub Pages Jekyll 빌드 |

## 알려진 이슈

- **프로젝트 08 이미지 누락**: `assets/project-08-aica.avif` 참조가 있으나 파일이 저장소에 없음. 구현 시 사용자에게 이미지 요청, 없으면 이미지 없는 프로젝트로 렌더링 (이미지 optional 처리).
- 로컬에 ruby/jekyll 미설치 — 구현 시작 시 ruby + bundler 설치 필요.

## 검증

1. `bundle exec jekyll build` 무오류
2. `jekyll serve`로 데스크톱/모바일 폭 육안 확인 (사용자 최종 승인)
3. 다이어그램 4종 각각 브라우저 렌더 확인
4. 브라우저 인쇄 미리보기 1회 확인 (`@media print`)
5. 삭제 후 빌드 산출물에 plugins/en 잔재 없는지 확인
