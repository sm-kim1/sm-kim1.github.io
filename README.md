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
