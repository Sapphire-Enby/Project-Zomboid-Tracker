# Changelog

## [Unreleased]

### Added
- `Project-Zomboid-Tracker/` - Lua files reorganised into a proper Build 41 mod structure with `mod.info`, `poster.png`, and `media/lua/server|shared/` layout so the mod can be installed directly.
- `web/README.md` - Documents the symlink setup required to point the web server's `output/` folder at the mod's output directory in the Zomboid save location.

### Changed
- `web/server.py` - `FLAG_FILE` and `DATA_FILE` paths updated from root directory to `output/` subdirectory, aligning with the symlink-based file handoff from the mod.
- `web/server.py` - Renamed flag file from `update.flag` to `updated.flag` to match the filename written by the Lua mod.
- `web/server.py` - Fixed crash in `log_message()` caused by empty `args` on `favicon.ico` requests; added guard before checking `args[0]`.
- `web/zomboid-tracker.html` - Removed single-player JSON format detection. The old format (flat object with top-level `username` key) is no longer supported; the frontend now only processes the multiplayer format (top-level keys are player names). Format detection logic simplified accordingly.
- `docs/web_description.md` - Updated expected `playerdata.json` format section to document only the multiplayer format.
- `Project-Zomboid-Tracker/media/lua/shared/JsonWriter.lua` - Added `return JsonWriter` at end of file for proper Lua module export.
- `Project-Zomboid-Tracker/media/lua/shared/datascrape.lua` - Added `perk ~= null` guard to perk iteration to prevent errors from Java null perk entries.

### Removed
- `lua/server/playerTest.lua` - Superseded by `Project-Zomboid-Tracker/media/lua/server/playerTest.lua` in the proper mod structure.
- `lua/shared/JsonWriter.lua` - Superseded by `Project-Zomboid-Tracker/media/lua/shared/JsonWriter.lua`.
- `lua/shared/datascrape.lua` - Superseded by `Project-Zomboid-Tracker/media/lua/shared/datascrape.lua`.
