# Project instructions

## Environment and validation

- Use Windows native Git, Ruby, Bundler and PowerShell. Install Ruby+Devkit and keep gems in `vendor/bundle` with `bundle config set --local path vendor/bundle`.
- Preserve the versions in `Gemfile.lock` and existing Linux platforms. Add the actual Windows platform reported by `ruby -e 'puts Gem::Platform.local'`; do not upgrade dependencies as an incidental change.
- Run `bundle exec jekyll build` after source changes. Preview with `bundle exec jekyll serve --host 127.0.0.1 --port 4000 --force_polling`. If the port is occupied, use another port without terminating unrelated processes.
- Generate PDFs with `powershell -ExecutionPolicy Bypass -File scripts/make-pdf.ps1`. The target is four A4 pages. After content or print-style changes, check every page for clipping and confirm the final patent and disclaimer remain visible.
- Check `/`, `/resume/`, `/print/`, and all three `/case/` pages, including desktop/mobile layouts and images.
- Keep UTF-8 without BOM and LF line endings for source files.

## Source structure

- `index.html` contains the landing-page copy. `_data/data_ko.yml` contains the detailed career data rendered by `resume.html` and `print.html`.
- When dates or metrics change, check both sources, the three `case-*.md` files, and `assets/diagram-*.svg` for consistency.
- Shared layouts are in `_layouts/`; styles are in `_sass/portfolio.scss`. Preserve the existing design during environment maintenance.

## Repository and publication rules

- Push only when the user explicitly requests it. Never force push.
- Preserve separate branch work; do not merge unrelated restored work without user direction.
- This is a public repository. Do not commit personal handoffs, job-search notes, profile drafts, PDFs, backups, credentials, or local tool settings. Maintain both Git ignore rules and Jekyll build exclusions.
- `HANDOFF.md`, `CLAUDE.md`, `docs/*.md`, and PDFs are local material. `AGENTS.md`, `scripts/`, and all `docs/` must be excluded from the built site.
- Do not introduce board manufacturer names, product code names, customer names, security-project details, or invented performance metrics. Use plain declarative prose.
- Check the repository-local Git author before committing.

## Local migration context

When present, `docs/windows-migration.md` records the active Windows setup and restored work. `docs/handoff.md` is the migration checklist. Older WSL/Claude/Orca directions in local historical notes do not define the current execution environment.
