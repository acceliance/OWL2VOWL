# Docker — OWL2VOWL

## Full stack (WebVOWL + converter)

OWL2VOWL is built **into** the WebVOWL image. Clone both repositories as **siblings** and run from **WebVOWL**:

```text
workspace/
  WebVOWL/
  OWL2VOWL/    ← this repo
```

```bash
cd ../WebVOWL
docker compose build
docker compose up -d
```

Documentation and ADR: `WebVOWL/docker/README.md`, `WebVOWL/docs/adr/0001-docker-local-development.md`.

Compose references this repo via `additional_contexts.owl2vowl: ../OWL2VOWL`.

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

`.dockerignore` excludes `ontologies/` (large sample files) from Docker context when this directory is used as an additional context from WebVOWL.
