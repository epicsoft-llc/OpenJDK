# AGENTS.md — OpenJDK Docker images

Guidance for coding agents working in this repository. User documentation lives in [`README.md`](README.md).

Dockerfiles for the `epicsoft/openjdk` JDK and JRE images — Java 11, 17, 21 and 25 on Alpine, plus a Debian headless
pair for Java 25. There is no application code, no local build script, no test suite and no linter; everything is
built by GitLab CI.

| | |
|---|---|
| Images | Docker Hub `epicsoft/openjdk` (`$DOCKER_REGISTRY`) and the GitLab container registry (`$CI_REGISTRY_IMAGE`) |
| Tags | `jdk<x.y.z>` / `jre<x.y.z>` from the build jobs, floating tags from the release jobs (see below) |
| Platforms | `linux/amd64`, `linux/arm64` — `BUILD_PLATFORMS` in the root `.gitlab-ci.yml` |
| Repository | developed on `gitlab.com/epicsoft-networks/openjdk`, mirrored to `github.com/epicsoft-llc/openjdk` |

## Rules

- **Public repository, MIT.** No internals in any file: no internal hosts, runner or server names, no credentials, no
  names of internal repositories or consuming projects, no infrastructure details. Before finishing a change, search
  every published file (`git ls-files` plus new files) for such terms.
- **Everything in English** — Dockerfiles, comments, README, CHANGELOG, commit messages.
- **Do not name the AI tool** in files, commit messages or trailers, or merge request texts.
- **Never commit, push, merge, rebase or tag** — changes stay in the working tree. Proposed commit messages follow
  Conventional Commits (`feat:`, `fix:`, `ci:`, `docs:`, `refactor:`, `revert:`).
- **`README.md` is part of the release.** `uploadReadme` syncs it to the Docker Hub description, so every link in it
  stays absolute — a relative link breaks on Docker Hub. The trailing two spaces on lines under `## Versions` are hard
  line breaks; `.editorconfig` disables trailing-whitespace trimming for `*.md`.
- **Every change gets a `CHANGELOG.md` line** under `## [Unreleased]`. When it reaches `main`, that section is renamed
  to the date, `## YYYY-MM-DD` — the project has no version of its own.
- **Keep this file current** — update it after every CI change, new image variant or new rule.

## Layout

```
openjdk<major>/<full.version>/
    jdk.Dockerfile                  # FROM docker:<v>-dind → build image (adds jq)
    jre.Dockerfile                  # FROM alpine:<v>      → runtime image
    jdk.debian-headless.Dockerfile  # FROM debian:<v>-slim → Java 25 only
    jre.debian-headless.Dockerfile  # FROM debian:<v>-slim → Java 25 only
    .gitlab-ci.yml                  # jdk<major> / jre<major> build jobs + OPENJDK<major>_IMAGE_TAG
.gitlab-ci.yml                      # includes only the current version of each major; release jobs
```

Old version directories are kept as history but are no longer built: the root `.gitlab-ci.yml` `include:` list names
exactly one directory per major version.

## Version pinning

Every Dockerfile pins three things, and they must stay consistent:

- **Base image.** `FROM docker:<version>-dind` / `FROM alpine:<version>` — the JDK and the JRE image of the same Java
  version use the same Alpine release, so the `docker:*-dind` tag must be the one built on that Alpine version.
  `ENV ALPINE_VERSION` / `ENV DOCKER_VERSION` are repeated as labels and must match the actual base image.
- **Java package.** `apk add openjdk<major>-jdk=<x.y.z>_p<N>-r<M>` — the exact revision from
  [pkgs.alpinelinux.org](https://pkgs.alpinelinux.org/packages). The `_pN-rM` suffix differs per Java version and per
  Alpine release; it cannot be guessed and must be verified for the chosen Alpine tag and for **both** `x86_64` and
  `aarch64` (the `arch=` selector on that page). An arch-only rebuild would break the build for that arch alone.
- **`ENV JAVA_VERSION`** — the plain `x.y.z`, also used as the image tag (`jdk25.0.4`, `jre25.0.4`).

Everything else in the `apk add` / `apt-get install` line is unpinned.

The Debian pair pins the same way against a different archive:

- `FROM debian:<x.y>-slim` with `ENV DEBIAN_VERSION`, repeated as the `debian_version` label (instead of
  `ALPINE_VERSION`; there is no `DOCKER_VERSION`).
- `apt-get install openjdk-25-{jdk,jre}-headless=<version>` — the exact Debian revision from
  [packages.debian.org](https://packages.debian.org). It may resolve from **`<release>-security`** rather than the
  plain release; `debian:<v>-slim` enables both, so checking the stable page alone can give a false negative. The
  revision must exist for `amd64` and `arm64`; the quickest check is a `curl -I` against
  `security.debian.org/debian-security/pool/updates/main/o/openjdk-25/<pkg>_<version>_<arch>.deb`.

## Debian variant (Java 25 only)

A glibc pair on `debian:<v>-slim` for native libraries that do not run on musl. It exists only for the current Java 25
directory; 11, 17 and 21 stay Alpine-only unless asked. Deliberate differences from the Alpine images — do not "fix"
them:

- **Headless packages.** Debian's non-headless packages pull GTK3, Mesa and LLVM as hard dependencies (~210 MB the
  Alpine image does not have). Headless AWT still renders fonts, images and PDFs; only GUI windows are gone.
- **Font and sound libraries are listed explicitly.** `fontconfig`, `libfreetype6`, `libharfbuzz0b` and
  `libasound2t64` are only *Recommends* of the headless packages, so `--no-install-recommends` drops them and every
  font operation dies with `UnsatisfiedLinkError: libharfbuzz.so.0`. The build still succeeds — this only shows at
  runtime. `libcups2t64` is intentionally **not** installed: the Alpine image has no CUPS either.
- **No Docker CLI, no DinD.** The official `docker` images are Alpine-only; the Debian JDK is a plain build image.
- **`java --version` may report a respin** such as `25.0.4.1` while the tag says `25.0.4`. Accepted — `JAVA_VERSION`
  stays the plain `x.y.z`.
- **`jq` is older** on Debian than on Alpine. Accepted.

## Adding a new Java patch release

1. Copy the previous version directory of that major to `openjdk<major>/<new.version>/`.
2. In `jdk.Dockerfile` and `jre.Dockerfile` bump `FROM`, `DOCKER_VERSION`, `ALPINE_VERSION`, `JAVA_VERSION` and the
   pinned `openjdk<major>-{jdk,jre}=` revision. For Java 25 also `{jdk,jre}.debian-headless.Dockerfile`: `FROM`,
   `DEBIAN_VERSION`, `JAVA_VERSION` and the pinned `openjdk-25-{jdk,jre}-headless=` revision.
3. In the directory's `.gitlab-ci.yml` bump `OPENJDK<major>_IMAGE_TAG` — the only version literal there,
   `OPENJDK<major>_PATH` derives from it.
4. In the root `.gitlab-ci.yml` point the `include:` entry at the new directory.
5. In `README.md` update the tag list under `## Versions` and the path in the local check example.
6. Add the release to `CHANGELOG.md`.

A new *major* also needs a `release<major>` job in the root `.gitlab-ci.yml`, and `releaseLatest`'s `LATEST_TAG` must
be repointed if the new major becomes the default.

## Multi-platform builds

Every image is a manifest list for the platforms in `BUILD_PLATFORMS`. Build jobs use `docker buildx build --push` on
the **built-in `default` builder**. Do not add a `docker-container` builder: in `docker:dind` the daemon address and
TLS paths come from environment variables, and buildx refuses to create an instance from those without a
`docker context`.

Nothing is cross-compiled — the images only install prebuilt distro packages — so the non-native half is built under
**QEMU emulation**. Its binfmt handlers must be registered in the runner host's kernel; that is host-wide state CI
cannot set up, which is why `default: tags` pins the pipeline to a runner that has them. Without them the arm64 half
dies with `exec /bin/sh: exec format error`. The `docker buildx inspect --bootstrap` line at the top of every build job
surfaces exactly that: if its `Platforms:` output stops listing `linux/arm64`, the fix is on the runner host, not in
this repository.

A multi-platform build cannot be `--load`ed into the local daemon, so the version checks run *after* the push, once
per platform (`docker run --platform …`). The exact-version tags are therefore pushed before they are verified —
acceptable, because a failing check fails the build stage and the release jobs never promote anything.

`BUILDX_NO_DEFAULT_ATTESTATIONS: "1"` keeps buildx from attaching provenance and SBOM attestations, which would show
up as `unknown/unknown` entries in the manifest list and on the Docker Hub tag page.

## Tagging

Build jobs push `jdk<x.y.z>` / `jre<x.y.z>`. The `release<major>` jobs copy those to `jdk<major>` and
`jdk<major>-latest` (same for `jre`) in both registries. `releaseLatest` copies the current `LATEST_TAG` (Java 25) to
`jdk`, `jdk-latest`, `jre`, `jre-latest` and `latest` — **`latest` is the JRE**, not the JDK.

The Debian pair adds a parallel set with a `-debian-headless` suffix: `jdk25.0.4-debian-headless` from the build job,
`jdk25-debian-headless` (+ `-latest`) from `release25`, `jdk-debian-headless` (+ `-latest`) from `releaseLatest`; same
for `jre`. The bare `latest` stays the Alpine JRE. The suffix carries `headless` so a future non-headless variant can
take plain `-debian`.

Re-tagging runs through `docker buildx imagetools create -t <new> … <source>`, one call per image, which copies the
manifest list inside the registry without pulling layers. It must **not** go back to `docker pull` + `docker tag` +
`docker push`: that resolves the manifest list to the runner's own platform and silently publishes a single-platform
floating tag.

All release-stage jobs (`release<major>`, `releaseLatest`, `uploadReadme`) extend `.releaseOnMain` and run only on the
default branch. Build jobs run on every branch but push exact-version tags only, nothing floating.

## Checking a change locally

CI has no test stage; the build jobs are the verification (`java --version` and the OS release file, plus
`jq --version` for JDK images and `docker --version` for the Alpine JDK, once per platform). A single-platform build from the repository
root catches a wrong pin:

```sh
docker build --pull --no-cache -t openjdk-check -f openjdk25/25.0.4/jre.Dockerfile . \
  --build-arg BUILD_DATE=$(date -u +'%Y-%m-%dT%H:%M:%SZ')
docker run --rm openjdk-check java --version
docker run --rm openjdk-check cat /etc/alpine-release
```

A wrong apk pin fails with `unable to select packages`, a wrong apt pin with `Version '...' for '...' was not found`.
For the other architecture (needs QEMU binfmt on the machine — `docker run --privileged --rm tonistiigi/binfmt
--install arm64`, Docker Desktop brings it along):

```sh
docker buildx build . --platform linux/arm64 --pull --no-cache --load \
  -f openjdk25/25.0.4/jre.Dockerfile -t openjdk-check-arm64 \
  --build-arg BUILD_DATE=$(date -u +'%Y-%m-%dT%H:%M:%SZ')
docker run --rm --platform linux/arm64 openjdk-check-arm64 java --version
```

For the Debian images check `cat /etc/debian_version` instead. A green build is not enough there — the font stack only
fails at runtime, so also render something with the JDK image:

```sh
FONTS='System.out.println(java.awt.GraphicsEnvironment.getLocalGraphicsEnvironment().getAvailableFontFamilyNames().length)'
echo "$FONTS" | docker run --rm -i openjdk-check jshell -q -
```

It must print `16`, the same as the Alpine image. `jshell` only exists in the JDK images; the JRE images install the
identical font packages, so checking the JDK covers both.
