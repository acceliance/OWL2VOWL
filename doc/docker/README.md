# Docker — OWL2VOWL

## Full stack (WebVOWL + converter)

OWL2VOWL is built **into** the WebVOWL image. Clone **WebVOWL** only; the Dockerfile clones this repo from GitHub during `docker build`:

```bash
git clone https://github.com/VisualDataWeb/WebVOWL.git
cd WebVOWL
docker compose build && docker compose up -d
```

See `WebVOWL/docker/README.md` (build args `OWL2VOWL_GIT_REF`, `OWL2VOWL_GIT_URL`).

## Standalone converter image (this repo)

Optional JAR/WAR-only container (no WebVOWL UI):

```bash
cd OWL2VOWL
docker build -t owl2vowl:local .
docker run --rm -p 8080:8080 owl2vowl:local
```

Uses `OWL2VOWL/Dockerfile` (`maven:3.9.16-eclipse-temurin-8-noble` → `eclipse-temurin:8-jre-noble`). Runs as user **`owl2vowl`** (non-root) with `HEALTHCHECK` on `/serverTimeStamp`.

### CI / GHCR

| Workflow | Trigger | Image |
|----------|---------|-------|
| `.github/workflows/docker-ci.yml` | PR + `master` | Build + smoke test |
| `.github/workflows/docker-release.yml` | Tag `v*` | `ghcr.io/visualdataweb/owl2vowl` |

## Build context

`.dockerignore` excludes `ontologies/` from the standalone image build context.
