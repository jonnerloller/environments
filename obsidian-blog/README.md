# Obsidian → Blog Starter (Quartz-friendly)

This setup lets you:
- write in Obsidian (`~/Obsidian/valhalla/Publishing`)
- clone your target Quartz repo into a temp folder
- sync selected markdown into that temp clone
- commit + push, then delete the temp folder automatically

## Current rules
- Includes: `Publishing/Essays`, `Publishing/Notes`
- Excludes: `Publishing/Private`, `Publishing/Templates`, `Publishing/Inbox`
- Publishes only files with frontmatter line: `status: published`

## Scripts
- `scripts/sync.sh <dest>` — copy filtered content into any destination content dir
- `scripts/publish.sh` — temp-clone target repo, sync into `content/`, commit + push, cleanup

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
