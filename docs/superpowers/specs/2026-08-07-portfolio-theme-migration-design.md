# 포트폴리오 테마 이전 설계 (online-cv fork + 한/영 토글)

날짜: 2026-08-07
저장소: https://github.com/sm-kim1/sm-kim1.github.io
결과 URL: https://sm-kim1.github.io (한국어), https://sm-kim1.github.io/en/ (영문)

## 목표

기존 수제 정적 페이지(index.html 574줄 + styles.css 772줄)를 버리고,
Jekyll 테마 [sharu725/online-cv](https://github.com/sharu725/online-cv)를 기반으로
2컬럼 CV형 페이지로 재구성한다. 내용은 `_data/` 아래 YAML 파일만 고치면 되는
템플릿 구조를 만들고, 한국어/영문 두 버전을 URL로 분리해 제공한다.

## 삭제 / 유지 / 추가

| 구분 | 대상 |
|---|---|
| 삭제 | `index.html`(기존), `styles.css` — git 히스토리에 남으므로 복구 가능 |
| 유지 | `assets/profile.jpeg`, `assets/diagram-*.svg`(4개), `assets/project-*.{png,jpg,avif}`(7개) |
| 추가 | online-cv의 `_config.yml`, `_data/`, `_includes/`, `_layouts/`, `_sass/`, `assets/plugins/`(약 30MB: bootstrap, jquery, fontawesome), `assets/js/`, `assets/css/`, `Gemfile`, `docker-compose.yml`, `print.html` |

online-cv는 Jekyll 플러그인과 remote_theme을 쓰지 않으므로 GitHub Pages 기본
빌드로 동작한다. GitHub Actions 설정이 필요 없다.

주의: 테마의 `CNAME` 파일은 가져오지 않는다(커스텀 도메인 없음). `_config.yml`의
Google Analytics ID는 비운다.

## 기존 내용 → 데이터 파일 대응

| 기존 섹션 | data YAML 키 | 비고 |
|---|---|---|
| Hero (이름·직무·연락처·사진) | `sidebar` | avatar는 `assets/profile.jpeg` |
| About 문단 | `career-profile.summary` | |
| Core Ability 6개 분류 | `skills.toolset` | 테마 수정 필요 — 아래 참조 |
| Career 2건 | `experiences.info` | `details`는 markdownify 되므로 불릿 유지됨 |
| Projects 10건 | `projects.assignments` | 테마 수정 필요 — 아래 참조 |
| Patents 3건 | `publications.papers` | 섹션 제목만 "특허 / Patents"로 변경 |
| 학력 (숭실대) | `education.info` | |

## 테마 수정 1 — skills.html (~5줄)

테마 기본은 `level: 98%` 진행 막대인데, 기존 내용은 카테고리별 기술 목록이라
숙련도 숫자를 지어내야 한다. 숫자를 만들지 않고 `level`이 없으면 태그 목록으로
렌더하도록 분기한다.

```liquid
{% if skill.level %}
  (기존 level-bar 그대로)
{% else %}
  <p class="skill-tags">{{ skill.items | join: " · " }}</p>
{% endif %}
```

```yaml
skills:
  toolset:
    - name: Language
      items: [C, C++, Python, Shell]
```

## 테마 수정 2 — projects.html (~15줄)

테마 기본은 프로젝트당 `title` + `tagline` 한 줄이라 다이어그램 SVG 4개,
사진 7개, 항목별 불릿이 전부 버려진다. 아래 필드를 지원하도록 확장한다.

```yaml
assignments:
  - title: SUGV Component Manager
    period: 2024.02 — 2025.12
    role: 선행 개발 / 주 담당
    image: assets/diagram-01-component-manager.svg
    tagline: ROS2 기반 SUGV 플랫폼의 런타임 센서·디바이스 동적 연결/해제 SW 개발
    details: |
      - 수행 내용 1
      - 수행 내용 2
```

`details`는 `experiences.html`과 동일하게 `| markdownify`로 렌더한다.
`period`, `role`, `image`, `details`는 모두 선택 필드 — 없으면 출력하지 않는다
(테마 원본 데이터와도 호환 유지).

## 한/영 토글

테마에 i18n이 없으므로 데이터 파일 두 벌 + 페이지 두 개로 해결한다.
JS 없음, 레이아웃 복제 없음.

```
_data/data_ko.yml     한국어 내용 (원본 _data/data.yml은 삭제)
_data/data_en.yml     영문 내용 (키 구조 동일)
index.html            front matter: data_file: data_ko, lang: ko
en/index.html         front matter: data_file: data_en, lang: en
```

- `_includes/`, `_layouts/`, `print.html`의 `site.data.data` 참조(14곳)를
  `site.data[page.data_file]`로 일괄 치환한다(sed 한 번).
- 언어 전환은 사이드바에 링크 하나: `/` ↔ `/en/`.
- `default.html`의 `<html lang=...>`은 `page.lang`을 따르게 한다(기본 en).
- print 페이지는 한국어 버전만 유지한다(`print.html`에 `data_file: data_ko`).

버튼(JS 즉시 전환) 대신 URL 분리를 고른 이유: 파일 하나에 두 언어를 섞지 않고,
영문 페이지가 독립 URL이라 링크 공유·검색 노출에 유리하다.
대신 전환 시 페이지가 새로 로드된다.

## 영문 내용

`data_en.yml`은 한국어 내용을 Claude가 초벌 번역해 채운다. 사용자가 검수 후
직접 수정한다. 고유명사(ACEWORKS, SUGV, ROS2 등)는 원문 유지.

## 검증

로컬에 Ruby 없음, docker 있음. 테마 포함 `docker-compose.yml`로
`docker compose up` → `localhost:4000` 확인.

성공 기준:
1. `docker compose up` 이 에러 없이 빌드되고 `/` 한국어, `/en/` 영문이 렌더된다.
2. 프로젝트 10건 전부에 이미지와 불릿이 보인다.
3. 스킬 섹션에 지어낸 % 숫자가 없다.
4. push 후 GitHub Pages 빌드가 성공하고 https://sm-kim1.github.io 가 뜬다.

## 범위 밖 (하지 않음)

- PDF 출력: 테마의 `print.html` + `pdf-generator.js`를 그대로 둔다.
  나중에 원하면 `sidebar.pdf` 한 줄로 활성화.
- 디자인 커스텀(색상 skin 변경 등): 기본 blue skin 사용. 이후 `_config.yml`
  한 줄로 변경 가능.
- 블로그/글 섹션: 요청 없음.
