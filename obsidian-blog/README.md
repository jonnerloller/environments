# Obsidian → Blog Starter (Quartz-friendly)

This setup lets you:
- write in Obsidian (`~/Obsidian/valhalla/Publishing`)
- sync selected markdown into this repo
- publish with one script (`scripts/publish.sh`)

## Current rules
- Includes: `Publishing/Essays`, `Publishing/Notes`
- Excludes: `Publishing/Private`, `Publishing/Templates`, `Publishing/Inbox`
- Publishes only files with frontmatter line: `status: published`

## Scripts
- `scripts/sync.sh` — copy filtered content into `obsidian-blog/site/content`
- `scripts/publish.sh` — sync + git add/commit/push

## Quick start
```bash
cd ~/repo/environments/obsidian-blog/scripts
chmod +x *.sh
./publish.sh
```

## Next step (hosting)
1. Create a separate Quartz repo OR keep Quartz in this repo under `obsidian-blog/site`.
2. Connect repo to Cloudflare Pages.
3. Build command: Quartz build command.
4. Output directory: Quartz public output.
5. Add Cloudflare Web Analytics snippet.

If you want, we can scaffold full Quartz in `obsidian-blog/site` next.
