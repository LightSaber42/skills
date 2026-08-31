#!/usr/bin/env bash
# Pull Matt's latest into this fork, replay local commits, refresh global installs.
#
#   ./scripts/sync-from-upstream.sh
#   ./scripts/sync-from-upstream.sh --dry-run
#   ./scripts/sync-from-upstream.sh --no-push
#   ./scripts/sync-from-upstream.sh --skip-install
#
# See FORK.md for the branch model. Do not edit Matt's README.md for fork notes.

set -euo pipefail

REPO="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO"

DRY_RUN=0
NO_PUSH=0
SKIP_INSTALL=0

usage() {
  cat <<'EOF'
Pull Matt's latest into this fork, replay local commits, refresh global installs.

  ./scripts/sync-from-upstream.sh
  ./scripts/sync-from-upstream.sh --dry-run
  ./scripts/sync-from-upstream.sh --no-push
  ./scripts/sync-from-upstream.sh --skip-install

See FORK.md for the branch model.
EOF
  exit "${1:-0}"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run) DRY_RUN=1 ;;
    --no-push) NO_PUSH=1 ;;
    --skip-install) SKIP_INSTALL=1 ;;
    -h | --help) usage 0 ;;
    *)
      echo "unknown argument: $1" >&2
      usage 1
      ;;
  esac
  shift
done

log() { printf '%s\n' "$*"; }

FORK_SKILLS=(
  ask-matt code-review codebase-design diagnosing-bugs domain-modeling
  grill-me grill-with-docs grilling handoff implement improve-codebase-architecture
  prototype research resolving-merge-conflicts setup-matt-pocock-skills tdd teach
  to-questionnaire to-spec to-tickets triage wait-what wayfinder wizard writing-for-agents
)

# ~/.codex is a symlink onto the HC volume. Symlinks from there to
# ~/.agents/skills (on /) look like missing SKILL.md files to Codex.
copy_fork_skills_into_codex() {
  local agents="${HOME}/.agents/skills"
  local codex="${HOME}/.codex/skills"
  if [[ ! -d "$agents" ]]; then
    echo "missing ${agents}" >&2
    return 1
  fi
  mkdir -p "$codex"
  local name src dest
  for name in "${FORK_SKILLS[@]}"; do
    src="${agents}/${name}"
    dest="${codex}/${name}"
    if [[ ! -d "$src" ]]; then
      log "skip ${name}: not in ${agents}"
      continue
    fi
    rm -rf "$dest"
    cp -a "$src" "$dest"
    log "copied ${name} -> ${dest}"
  done
}
run() {
  if [[ "$DRY_RUN" -eq 1 ]]; then
    printf '[dry-run] %s\n' "$*"
    return 0
  fi
  "$@"
}

require_clean() {
  if [[ "$DRY_RUN" -eq 1 ]]; then
    return 0
  fi
  if [[ -n "$(git status --porcelain)" ]]; then
    echo "working tree is dirty. commit or stash, then re-run." >&2
    git status -sb >&2
    exit 1
  fi
}

ensure_remotes() {
  if ! git remote get-url origin >/dev/null 2>&1; then
    echo "missing origin remote (expected git@github.com:LightSaber42/skills.git)" >&2
    exit 1
  fi
  if ! git remote get-url upstream >/dev/null 2>&1; then
    log "adding upstream -> git@github.com:mattpocock/skills.git"
    run git remote add upstream git@github.com:mattpocock/skills.git
  fi
}

ORIGINAL_BRANCH="$(git rev-parse --abbrev-ref HEAD)"
restore_branch() {
  if [[ "$DRY_RUN" -eq 1 ]]; then
    return 0
  fi
  if git rev-parse --abbrev-ref HEAD >/dev/null 2>&1; then
    local now
    now="$(git rev-parse --abbrev-ref HEAD)"
    if [[ "$now" == HEAD ]]; then
      return 0
    fi
    if [[ "$now" != "$ORIGINAL_BRANCH" ]] && git show-ref --verify --quiet "refs/heads/$ORIGINAL_BRANCH"; then
      git checkout "$ORIGINAL_BRANCH"
    fi
  fi
}

if [[ "$DRY_RUN" -eq 0 ]]; then
  trap restore_branch EXIT
fi

require_clean
ensure_remotes

log "fetching origin and upstream"
run git fetch origin
run git fetch upstream

if ! git show-ref --verify --quiet refs/heads/main; then
  echo "local branch main is missing" >&2
  exit 1
fi
if ! git show-ref --verify --quiet refs/heads/personal; then
  echo "local branch personal is missing" >&2
  exit 1
fi

log "fast-forwarding main from upstream/main"
run git checkout main
if [[ "$DRY_RUN" -eq 1 ]]; then
  log "[dry-run] git merge --ff-only upstream/main"
else
  git merge --ff-only upstream/main
fi
if [[ "$NO_PUSH" -eq 0 ]]; then
  run git push origin main
else
  log "skipping push of main (--no-push)"
fi

log "rebasing personal onto main"
run git checkout personal
if [[ "$DRY_RUN" -eq 1 ]]; then
  log "[dry-run] git rebase main"
else
  if ! git rebase main; then
    echo "rebase conflicted. fix files, then:" >&2
    echo "  git add -u && git rebase --continue" >&2
    echo "  git push --force-with-lease origin personal" >&2
    echo "  npx --yes skills@latest update -g -y" >&2
    trap - EXIT
    exit 1
  fi
fi
if [[ "$NO_PUSH" -eq 0 ]]; then
  run git push --force-with-lease origin personal
else
  log "skipping push of personal (--no-push)"
fi

if [[ "$SKIP_INSTALL" -eq 1 ]]; then
  log "skipping npx skills update (--skip-install)"
else
  log "refreshing global installs from LightSaber42/skills"
  run npx --yes skills@latest update -g -y
  log "copying fork skills onto the Codex volume (no cross-disk symlinks)"
  if [[ "$DRY_RUN" -eq 1 ]]; then
    log "[dry-run] copy_fork_skills_into_codex"
  else
    copy_fork_skills_into_codex
  fi
fi

log "done. local agents now track origin/personal."
