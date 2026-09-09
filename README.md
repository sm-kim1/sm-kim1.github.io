# sm-kim1.github.io

포트폴리오. 자체 제작 미니멀 Jekyll 테마 (Pretendard, 흰 배경 + 파랑 accent, 다크모드 자동).

## 구조

- 랜딩: `index.html` (정적, `layout: default`). 케이스: `case-*.md` (`layout: case`). 경력기술서: `resume.html`(`/resume/`, 웹) + `print.html`(`/print/`, A4 인쇄용). 데이터는 `_data/data_ko.yml`
- 레이아웃: `_layouts/default.html` (네비, 푸터, lightbox 공용) -> `_layouts/case.html`
- 스타일: `_sass/portfolio.scss` 단일 파일. 색, 폰트는 `:root` 토큰
- 다이어그램: `assets/diagram-*.svg` - 공통 스타일(제목 블록, 점 패턴 배경, 그림자 카드, 상태 알약), viewBox 1600x900

## Windows 최초 설치

Windows Git과 [RubyInstaller Ruby+Devkit](https://rubyinstaller.org/downloads/)을 설치한다. 검증 환경은 Ruby 3.3.12 (x64 UCRT), Bundler 2.3.25다. 설치 시 MSYS2 개발 도구도 준비한다. [Jekyll Windows 안내](https://jekyllrb.com/docs/installation/windows/)를 참고한다.

```powershell
winget install --id Git.Git --exact
winget install --id RubyInstallerTeam.RubyWithDevKit.3.3 --exact
# 설치 후 새 PowerShell을 연다.
ruby --version
ridk version
# 개발 도구가 없을 때: ridk install 3
gem install bundler -v 2.3.25 --no-document
cd C:\dev\git\sm-kim1.github.io
bundle config set --local path vendor/bundle
bundle install
bundle exec jekyll build
```

의존성은 프로젝트의 `vendor/bundle`에 설치한다. `.bundle/config`는 로컬에서 재생성하며 커밋하지 않는다. `Gemfile.lock`의 기존 버전과 Linux 플랫폼을 유지한다. 다른 Windows 아키텍처를 쓸 때는 `ruby -e 'puts Gem::Platform.local'`로 실제 플랫폼을 확인하고 `bundle lock --add-platform <플랫폼>`으로 추가한다.

## 로컬 미리보기

```powershell
bundle exec jekyll serve --host 127.0.0.1 --port 4000 --force_polling
# http://127.0.0.1:4000
```

4000 포트가 사용 중이면 기존 프로세스를 종료하지 말고 `--port 4001` 등으로 변경한다. Windows 프로젝트에서 실행한 Ruby 서버인지 확인한다. `_config.yml`을 바꾸면 서버를 재시작한다.

GitHub Pages와 같은 `github-pages` 232 / Jekyll 3.10.0을 사용한다. 배포 전에는 `/`, `/resume/`, `/print/`, 세 케이스 경로와 이미지, 데스크톱·모바일 화면을 확인한다.

## 배포

`main`에 push하면 GitHub Pages가 자동 빌드한다.

## 인쇄

`/print/`는 A4 4페이지 경력기술서다. Jekyll 서버를 실행한 상태에서 Windows Chrome 또는 Edge로 PDF를 만든다.

```powershell
powershell -ExecutionPolicy Bypass -File scripts/make-pdf.ps1
powershell -ExecutionPolicy Bypass -File scripts/make-pdf.ps1 /print/ portfolio_sangmin.pdf
# 다른 미리보기 포트를 쓸 때
powershell -ExecutionPolicy Bypass -File scripts/make-pdf.ps1 -BaseUrl http://127.0.0.1:4001
```

출력 파일의 상대 경로는 저장소 루트 기준이다. `-BrowserPath`로 브라우저 실행 파일을 지정할 수 있다. 스크립트는 매번 TEMP 아래에 별도 프로필과 새 PDF를 만들고 정상 생성을 확인한 뒤 출력 파일을 갱신한다. 실패하면 기존 PDF를 보존한다. 생성 후 A4 4페이지와 마지막 특허·주의 문구까지 확인한다. 기존 `make-pdf.sh`는 과거 WSL 환경용으로 남겨 둔다.

개인 문서, PDF와 백업은 커밋하지 않는다. `docs/`, `scripts/`, 에이전트 지침과 PDF는 Jekyll 산출물에서도 제외한다. Codex 작업 규칙은 `AGENTS.md`에 있다.
