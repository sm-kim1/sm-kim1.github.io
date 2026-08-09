# 포트폴리오 online-cv 테마 이전 구현 계획

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 기존 수제 정적 페이지를 Jekyll 테마 online-cv 기반 2컬럼 CV로 교체하고, `_data/data_ko.yml` / `_data/data_en.yml` 두 파일로 한/영 페이지(`/`, `/en/`)를 제공한다.

**Architecture:** online-cv 테마 파일을 레포에 통째로 복사(fork 대신 파일 이식 — 히스토리 유지). 모든 include의 `site.data.data` 참조를 `site.data[page.data_file]`로 바꿔 페이지 front matter가 데이터 파일을 고르게 한다. 테마 수정은 skills(태그 목록)와 projects(이미지·기간·역할·불릿) 두 곳뿐.

**Tech Stack:** Jekyll (GitHub Pages 기본 빌드, 플러그인 없음), Liquid, YAML, 로컬 검증은 docker(`jekyll/builder:4.0`).

## Global Constraints

- 저장소: `/home/sm/git/resume` (origin: https://github.com/sm-kim1/sm-kim1.github.io), 브랜치 `main`
- 테마 원본: https://github.com/sharu725/online-cv (master, 파일 복사만; 서브모듈·remote_theme 금지)
- GitHub Pages 기본 빌드로 동작해야 함 → `plugins:` 추가 금지, `.github/workflows` 추가 금지
- 스킬 섹션에 숙련도 % 숫자를 지어내지 않는다 (`level` 필드 대신 `items` 목록)
- 데이터 내용은 `_old/index.html`에서 옮긴다 — 사실을 새로 만들지 않는다
- 고유명사(ACEWORKS, ACELAB, SUGV, ROS2, Jetson 등)는 영문판에서도 원문 유지
- 로컬 빌드 검증 명령(모든 태스크 공통):
  `docker run --rm -v "$PWD:/srv/jekyll" jekyll/builder:4.0 jekyll build --trace`
  성공 기준: exit 0, `_site/` 생성
- 커밋 메시지 끝에 `Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>`

---

### Task 1: 테마 이식 + 기존 파일 대피

**Files:**
- Move: `index.html`, `styles.css` → `_old/` (임시 보관, Task 7에서 삭제)
- Create: 테마에서 복사 — `_config.yml`(덮어씀), `_data/data.yml`, `_includes/`, `_layouts/`, `_sass/`, `assets/css/`, `assets/js/`, `assets/plugins/`, `assets/images/`, `index.html`, `print.html`, `Gemfile`, `docker-compose.yml`, `.gitignore`
- 복사 제외: 테마의 `CNAME`, `.github/`, `README.md`, `LICENSE.md`는 LICENSE만 `THEME-LICENSE.md`로 가져옴 (MIT — 고지 유지 필요)

**Interfaces:**
- Produces: 빌드 가능한 Jekyll 사이트 (테마 데모 내용 그대로), `_old/index.html` (Task 5의 내용 원본)

- [ ] **Step 1: 기존 파일 대피**

```bash
cd /home/sm/git/resume
mkdir _old
git mv index.html styles.css _old/
```

(`_`로 시작하는 디렉토리는 Jekyll 출력에서 제외된다.)

- [ ] **Step 2: 테마 clone 후 파일 복사**

```bash
SCRATCH=/tmp/claude-1000/-home-sm-git-resume/05417d43-b363-4f2d-90e6-17e24071c4a3/scratchpad
[ -d "$SCRATCH/cv" ] || git clone --depth 1 https://github.com/sharu725/online-cv.git "$SCRATCH/cv"
cd /home/sm/git/resume
cp -r "$SCRATCH/cv/_data" "$SCRATCH/cv/_includes" "$SCRATCH/cv/_layouts" "$SCRATCH/cv/_sass" .
cp -r "$SCRATCH/cv/assets/css" "$SCRATCH/cv/assets/js" "$SCRATCH/cv/assets/plugins" "$SCRATCH/cv/assets/images" assets/
cp "$SCRATCH/cv/_config.yml" "$SCRATCH/cv/index.html" "$SCRATCH/cv/print.html" "$SCRATCH/cv/Gemfile" "$SCRATCH/cv/docker-compose.yml" "$SCRATCH/cv/.gitignore" .
cp "$SCRATCH/cv/LICENSE.md" THEME-LICENSE.md
```

- [ ] **Step 3: _config.yml 수정**

`title`을 `Sangmin Kim — Platform Engineer`로, Google Analytics ID(`ga_tracker` 또는 유사 키)를 빈 값으로. skin은 기본 `blue` 유지. `baseurl`은 빈 값/주석 유지 (루트 도메인 레포이므로).

- [ ] **Step 4: 빌드 검증**

```bash
docker run --rm -v "$PWD:/srv/jekyll" jekyll/builder:4.0 jekyll build --trace
grep -q "sidebar-wrapper" _site/index.html && echo OK
```

Expected: exit 0, `OK` 출력 (테마 데모 데이터로 렌더됨).

- [ ] **Step 5: Commit**

```bash
git add -A
git commit -m "feat: online-cv 테마 이식, 기존 페이지 _old/로 대피"
```

---

### Task 2: 다국어 배관 — 데이터 파일을 페이지가 선택

**Files:**
- Modify: `_includes/*.html` 중 `site.data.data` 참조 14개 파일, `index.html`, `print.html`, `_layouts/default.html`, `_includes/sidebar.html`
- Rename: `_data/data.yml` → `_data/data_ko.yml`
- Create: `en/index.html`

**Interfaces:**
- Consumes: Task 1의 테마 파일
- Produces: `page.data_file` front matter 규약 — 값은 `_data/` 아래 파일명(확장자 제외). 모든 include가 `site.data[page.data_file]`을 읽음. `page.lang` (`ko`|`en`).

- [ ] **Step 1: 참조 일괄 치환 + 데이터 파일 이름 변경**

```bash
cd /home/sm/git/resume
grep -rl 'site\.data\.data' _includes _layouts index.html print.html | xargs sed -i 's/site\.data\.data/site.data[page.data_file]/g'
git mv _data/data.yml _data/data_ko.yml
grep -rn 'site\.data\.data' . --include='*.html' | grep -v _site && echo "잔여 있음 — 실패" || echo OK
```

- [ ] **Step 2: index.html / print.html front matter 지정**

`index.html` front matter를 다음으로 교체 (본문 include 목록은 그대로):

```yaml
---
layout: default
data_file: data_ko
lang: ko
---
```

`print.html` front matter:

```yaml
---
layout: print
permalink: /print
data_file: data_ko
lang: ko
---
```

- [ ] **Step 3: en/index.html 생성**

`index.html`을 복사한 뒤 front matter만 교체:

```yaml
---
layout: default
data_file: data_en
lang: en
permalink: /en/
---
```

임시로 `_data/data_en.yml`도 만들어 둔다 (빌드가 깨지지 않도록):

```bash
cp _data/data_ko.yml _data/data_en.yml
```

(진짜 영문 내용은 Task 6에서 채움.)

- [ ] **Step 4: html lang 속성**

`_layouts/default.html`(그리고 `_layouts/print.html`에 있으면 거기도)의 `lang="en"`을 전부 치환:

```bash
sed -i 's/html lang="en"/html lang="{{ page.lang | default: \x27en\x27 }}"/g' _layouts/default.html _layouts/print.html
grep -n 'html lang' _layouts/*.html
```

Expected: 모든 `<html>` 태그가 `{{ page.lang | default: 'en' }}` 사용.

- [ ] **Step 5: 사이드바에 언어 토글 링크**

`_includes/sidebar.html`의 `</div><!--//profile-container-->` 바로 뒤에 추가:

```liquid
<div class="lang-switch" style="text-align:center; margin-bottom:15px;">
  {% if page.lang == 'ko' %}
  <a href="{{ site.baseurl }}/en/">English</a>
  {% else %}
  <a href="{{ site.baseurl }}/">한국어</a>
  {% endif %}
</div>
```

- [ ] **Step 6: 빌드 검증 — 두 페이지 렌더**

```bash
docker run --rm -v "$PWD:/srv/jekyll" jekyll/builder:4.0 jekyll build --trace
grep -q 'lang="ko"' _site/index.html && grep -q 'lang="en"' _site/en/index.html && grep -q '/en/' _site/index.html && echo OK
```

Expected: `OK`.

- [ ] **Step 7: Commit**

```bash
git add -A
git commit -m "feat: page front matter로 데이터 파일 선택하는 한/영 페이지 배관"
```

---

### Task 3: skills.html — % 막대 대신 태그 목록 지원

**Files:**
- Modify: `_includes/skills.html`

**Interfaces:**
- Consumes: `site.data[page.data_file].skills.toolset[*]`
- Produces: toolset 항목 스키마 확장 — `level`(기존, 선택) 또는 `items`(신규, 문자열 배열). 둘 다 없으면 이름만 출력.

- [ ] **Step 1: 분기 추가**

`_includes/skills.html`의 `{% for skill in skills.toolset %}` 루프 안, level-bar 블록을 다음으로 교체:

```liquid
{% if skill.level %}
{% assign skill_level = 'width: ' | append: skill.level %}
<div class="level-bar">
  <div class="level-bar-inner" style="{{skill_level}}"></div>
</div>
<!--//level-bar-->
{% elsif skill.items %}
<p class="skill-tags" style="margin-bottom:0; color:#666;">{{ skill.items | join: " · " }}</p>
{% endif %}
```

- [ ] **Step 2: 검증 — 임시 items 항목 주입 후 빌드**

`_data/data_ko.yml`의 `skills.toolset` 맨 앞에 임시 항목 추가:

```yaml
  - name: TEMP-TEST
    items: [AAA, BBB]
```

```bash
docker run --rm -v "$PWD:/srv/jekyll" jekyll/builder:4.0 jekyll build --trace
grep -q 'AAA · BBB' _site/index.html && echo OK
```

Expected: `OK`. 확인 후 임시 항목 제거.

- [ ] **Step 3: Commit**

```bash
git add _includes/skills.html
git commit -m "feat: skills에 level 없이 items 태그 목록 렌더 지원"
```

---

### Task 4: projects.html — 이미지·기간·역할·불릿 지원

**Files:**
- Modify: `_includes/projects.html`

**Interfaces:**
- Consumes: `site.data[page.data_file].projects.assignments[*]`
- Produces: assignment 스키마 확장 — 기존 `title`/`link`/`tagline`에 더해 선택 필드 `period`(문자열), `role`(문자열), `image`(레포 루트 기준 경로), `details`(마크다운 문자열). 없으면 출력 안 함 — 테마 원본 데이터와 호환.

- [ ] **Step 1: 항목 렌더 확장**

`_includes/projects.html`의 `{% for project in projects.assignments %}` 루프 본문을 다음으로 교체:

```liquid
    <div class="item">

      <span class="project-title">
        {% if project.link %}
        <a href="{{ project.link }}" target="_blank">{{ project.title }}</a>
        {% else %}
        {{ project.title }}
        {% endif %}
      </span>

      {% if project.period or project.role %}
      <div class="project-meta" style="color:#97AAC3; font-size:0.85em;">
        {{ project.period }}{% if project.period and project.role %} · {% endif %}{{ project.role }}
      </div>
      {% endif %}

      {% if project.tagline %}
      <span class="project-tagline">{{ project.tagline }}</span>
      {% endif %}

      {% if project.image %}
      <img src="{{ site.baseurl }}/{{ project.image }}" alt="{{ project.title }}" style="max-width:100%; margin:10px 0; border-radius:4px;" loading="lazy" />
      {% endif %}

      {% if project.details %}
      <div class="project-details">
        {{ project.details | markdownify }}
      </div>
      {% endif %}

    </div><!--//item-->
```

(원본과 달리 tagline 앞의 `- ` 구분자는 제거 — 필드가 늘어나 줄바꿈 레이아웃이 됨.)

- [ ] **Step 2: 검증 — 임시 항목 주입 후 빌드**

`_data/data_ko.yml`의 `projects.assignments` 맨 앞에 임시 추가:

```yaml
  - title: TEMP-PROJ
    period: 2024.01 — 2024.12
    role: 테스트
    image: assets/profile.jpeg
    details: |
      - bullet-one
      - bullet-two
```

```bash
docker run --rm -v "$PWD:/srv/jekyll" jekyll/builder:4.0 jekyll build --trace
grep -q 'bullet-one' _site/index.html && grep -q 'assets/profile.jpeg' _site/index.html && echo OK
```

Expected: `OK`. 확인 후 임시 항목 제거.

- [ ] **Step 3: Commit**

```bash
git add _includes/projects.html
git commit -m "feat: projects에 period/role/image/details 선택 필드 지원"
```

---

### Task 5: data_ko.yml — 기존 내용 이식

**Files:**
- Modify: `_data/data_ko.yml` (전체 교체)
- Move: `assets/profile.jpeg` → `assets/images/profile.jpeg`

**Interfaces:**
- Consumes: `_old/index.html`(내용 원본), Task 3·4의 스키마
- Produces: 완성된 한국어 데이터. Task 6이 이 파일을 번역 원본으로 사용.

- [ ] **Step 1: 아바타 이동**

```bash
git mv assets/profile.jpeg assets/images/profile.jpeg
```

(sidebar.html이 `assets/images/` 경로를 하드코딩하므로.)

- [ ] **Step 2: `_old/index.html` 정독 후 data_ko.yml 작성**

`_old/index.html`을 처음부터 끝까지 읽고 아래 골격에 채운다. **원문에 없는 사실(숙련도 %, 날짜, 성과 수치)을 만들지 않는다. 문구는 원문 그대로 옮긴다.**

```yaml
sidebar:
  position: left
  about: false          # about은 career-profile로 감
  education: false      # education은 본문 섹션으로
  name: Sangmin Kim
  tagline: Platform Engineer
  avatar: profile.jpeg
  email: (원문의 연락처)
  github: sm-kim1
  # 원문에 있는 연락 수단만 넣는다. 없는 SNS 키는 쓰지 않는다.

career-profile:
  title: About
  summary: |
    (_old/index.html의 About 문단 그대로)

education:
  title: 학력
  info:
    - degree: (원문 학위)
      university: 숭실대학교
      time: (원문 기간)

experiences:
  title: 경력
  info:
    - role: Senior Research Engineer
      time: 2023.11 — 현재
      company: ACEWORKS Korea
      details: |
        (원문 불릿을 마크다운 "- " 목록으로)
    - role: Research Engineer
      time: 2021.07 — 2023.10
      company: ACELAB
      details: |
        (원문 불릿)

projects:
  title: 대표 프로젝트
  assignments:
    # 원문 프로젝트 10건 전부, 원문 순서대로
    - title: (원문 제목)
      period: (원문 기간)
      role: (원문 role 블록)
      image: assets/diagram-01-component-manager.svg   # 해당 프로젝트의 원문 이미지 경로
      tagline: (원문 project-desc)
      details: |
        - (원문 project-list 항목들)

publications:
  title: 특허
  papers:
    # 원문 특허 3건
    - title: (원문 특허명)
      authors: (원문 출원인/발명자 표기)
      conference: (원문 출원번호·연도 표기)

skills:
  title: 기술 스택
  toolset:
    # 원문 Core Ability 분류 그대로, level 없이 items로
    - name: Language
      items: [C, C++, Python, Shell]
    - name: (원문 분류명)
      items: [(원문 항목들)]

footer: >
  © 2026 Sangmin Kim. Powered by <a href="https://github.com/sharu725/online-cv" target="_blank" rel="nofollow">online-cv</a> theme.
```

`certifications`, `oss`, `recommendations`, `interests`, `languages` 키는 원문에 해당 내용이 없으므로 **아예 넣지 않는다** (include가 `{% if %}`로 스킵).

- [ ] **Step 3: 빌드 + 내용 검증**

```bash
docker run --rm -v "$PWD:/srv/jekyll" jekyll/builder:4.0 jekyll build --trace
c=$(grep -o 'project-title' _site/index.html | wc -l); echo "projects: $c"   # 10이어야 함
grep -c 'diagram-' _site/index.html    # 4 (SVG 4개)
grep -q 'ACEWORKS' _site/index.html && grep -q '특허' _site/index.html && echo OK
grep -o '[0-9]\+%' _site/index.html | head   # 스킬 % 숫자가 안 나와야 함 (빈 출력)
```

Expected: projects 10, diagram 4, `OK`, % 없음.

- [ ] **Step 4: 시각 확인 (사용자 체크포인트)**

```bash
docker compose up -d
```

`http://localhost:4000` 을 사용자가 열어 레이아웃·내용 확인. 피드백 반영 후 진행.

- [ ] **Step 5: Commit**

```bash
git add -A
git commit -m "feat: 기존 포트폴리오 내용을 data_ko.yml로 이식"
```

---

### Task 6: data_en.yml — 영문 초벌 번역

**Files:**
- Modify: `_data/data_en.yml` (Task 2에서 만든 복사본을 실제 번역으로 교체)

**Interfaces:**
- Consumes: `_data/data_ko.yml` (번역 원본)
- Produces: 키 구조가 data_ko.yml과 동일한 영문 데이터

- [ ] **Step 1: 번역 작성**

`data_ko.yml`과 키 구조·항목 수 동일하게, 값만 영문으로. 규칙:
- 고유명사(ACEWORKS, ACELAB, SUGV, ROS2, Jetson, Yocto, CAN 등) 원문 유지
- 섹션 제목: 학력→Education, 경력→Experience, 대표 프로젝트→Projects, 특허→Patents, 기술 스택→Skills
- `현재`→`Present`
- image/period/링크 등 비언어 필드는 그대로 복사
- 초벌 번역임을 사용자에게 알리고 검수 요청

- [ ] **Step 2: 구조 일치 검증**

```bash
python3 - <<'EOF'
import yaml
ko = yaml.safe_load(open('_data/data_ko.yml'))
en = yaml.safe_load(open('_data/data_en.yml'))
def keys(d, p=''):
    if isinstance(d, dict):
        return {k2 for k, v in d.items() for k2 in keys(v, f'{p}.{k}')} | {f'{p}.{k}' for k in d}
    if isinstance(d, list):
        return {f'{p}[{len(d)}]'} | {k for v in d for k in keys(v, p+'[]')}
    return set()
diff = keys(ko) ^ keys(en)
print('OK' if not diff else f'MISMATCH: {sorted(diff)}')
EOF
```

Expected: `OK` (키 구조·배열 길이 동일). `yaml` 모듈이 없으면 `pip3 install --user pyyaml` 후 재실행.

- [ ] **Step 3: 빌드 검증**

```bash
docker run --rm -v "$PWD:/srv/jekyll" jekyll/builder:4.0 jekyll build --trace
grep -q 'Patents' _site/en/index.html && grep -q 'Present' _site/en/index.html && echo OK
```

- [ ] **Step 4: Commit**

```bash
git add _data/data_en.yml
git commit -m "feat: 영문 데이터 초벌 번역 (data_en.yml)"
```

---

### Task 7: 정리 + README + 배포

**Files:**
- Delete: `_old/`
- Modify: `README.md`

**Interfaces:**
- Consumes: 전 태스크 완료 상태
- Produces: 배포된 사이트

- [ ] **Step 1: 대피 파일 삭제**

```bash
git rm -r _old
```

- [ ] **Step 2: README 갱신**

`README.md`를 다음 내용으로 교체:

```markdown
# sm-kim1.github.io

포트폴리오 · [sharu725/online-cv](https://github.com/sharu725/online-cv) 테마 기반.

## 내용 수정

- 한국어: `_data/data_ko.yml`
- English: `_data/data_en.yml`

두 파일은 키 구조가 같아야 한다. 프로젝트 추가 = `projects.assignments`에 항목 하나 추가.

## 로컬 미리보기

```bash
docker compose up
# http://localhost:4000 (한국어), /en/ (영문)
```

## 배포

`main`에 push하면 GitHub Pages가 자동 빌드한다.
```

- [ ] **Step 3: 최종 빌드 검증**

```bash
docker run --rm -v "$PWD:/srv/jekyll" jekyll/builder:4.0 jekyll build --trace && echo BUILD-OK
```

- [ ] **Step 4: Commit + Push**

```bash
git add -A
git commit -m "chore: 이전 페이지 잔재 정리, README 갱신"
git push origin main
```

- [ ] **Step 5: 배포 확인**

push 후 1~2분 뒤:

```bash
curl -s -o /dev/null -w '%{http_code}\n' https://sm-kim1.github.io/
curl -s https://sm-kim1.github.io/en/ | grep -c 'Patents'
```

Expected: `200`, `1` 이상. 실패 시 레포 Settings → Pages에서 Source가 `main` 브랜치인지 확인.
