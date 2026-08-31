# This fork (`LightSaber42/skills`)

Fork of [mattpocock/skills](https://github.com/mattpocock/skills). Matt's `README.md` is his install story. This file is the fork's: how to take his updates without losing local edits.

Do not also install the official `mattpocock-skills` Claude plugin. That loads his copies next to these and you get every skill twice.

Custom skills that are not from Matt (`ionian-forecast`, Telegram bridge, and so on) live in [LightSaber42/codex-skills](https://github.com/LightSaber42/codex-skills), not here.

## Branches

| Branch | What it is |
| --- | --- |
| `main` | Clean mirror of `upstream/main` (Matt). Do not commit local edits here. |
| `personal` | Local edits on top of `main`. GitHub default branch. `npx skills add LightSaber42/skills` and `npx skills update` read this. |

Remotes: `origin` is this fork, `upstream` is `mattpocock/skills`.

## Update from Matt

From this clone:

```bash
./scripts/sync-from-upstream.sh
```

That fetches Matt, fast-forwards `main`, rebases `personal`, pushes both, then runs `npx --yes skills@latest update -g -y` so the copies under `~/.agents/skills` match `personal`.

Useful flags:

```bash
./scripts/sync-from-upstream.sh --dry-run
./scripts/sync-from-upstream.sh --no-push
./scripts/sync-from-upstream.sh --skip-install
```

If the rebase stops on a conflict, fix the files, `git add`, `git rebase --continue`, then re-run the script (or push `personal` with `--force-with-lease` and run `npx --yes skills@latest update -g -y` yourself).

## Edit a skill

1. Change files on `personal` in this clone.
2. Commit and `git push origin personal`.
3. `npx --yes skills@latest update -g -y`

Prefer adding a new skill directory, or a thin wrapper, over rewriting Matt's `SKILL.md` files. The less you touch his files, the less the rebase hurts.
