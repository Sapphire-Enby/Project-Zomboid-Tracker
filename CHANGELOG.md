# Changelog

## [Unreleased]

### Added
- `datascrape.lua` - `getGameDateTime()` function: reads in-game date/time via `getGameTime()` singleton, formats as `"Jul 9, 14:30"` for chart X-axis labels.
- `datascrape.lua` - `getSaveName()` function: returns save folder name via `getWorld():getWorld()`, falls back to `getServerName()` for multiplayer, then `"unknown"`.
- `playerTest.lua` - Builds a `metadata` table with `gameDate` and `saveName` on each event, passes it through to `JsonWriter.toFile()`.
- `JsonWriter.lua` - Accepts optional `metadata` parameter in `encode()` and `toFile()`, writes a top-level `"metadata"` object (gameDate, saveName) as the first entry in `playerdata.json` before player records.
- `zomboid-tracker.html` - `getDisplayName()` helper strips `saveName::` prefix and shows character names as `"PlayerName (saveName)"` in the UI.
- `zomboid-tracker.html` - Character keys in localStorage are now namespaced as `saveName::username` to prevent collisions across different saves.

### Changed
- `playerTest.lua` - `writeRecordsToJson()` now accepts and passes a `metadata` parameter to `JsonWriter.toFile()`.
- `playerTest.lua` - `onEvent()` constructs metadata table from `datascrape.getGameDateTime()` and `datascrape.getSaveName()` before writing records.
- `zomboid-tracker.html` - `updateHistory()` extracts `metadata.gameDate` and `metadata.saveName` from incoming JSON; uses game date as history entry timestamp instead of `new Date().toISOString()`.
- `zomboid-tracker.html` - Chart labels use `entry.timestamp` directly instead of wrapping with `new Date().toLocaleDateString()`.
- `zomboid-tracker.html` - X-axis label changed from "Date" to "Game Date".
- `zomboid-tracker.html` - Stat cards and comparison mode labels use `getDisplayName()` for cleaner display.

### Fixed
- `datascrape.lua` - Added `@diagnostic` suppress for `null` global (Java nil equivalent) with explanatory comment on the perk validation check.
