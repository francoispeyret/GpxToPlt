## What's New in 1.1.0

### Batch Conversion
- **Select multiple GPX files at once** via the file picker or drag & drop
- Each file is parsed and validated independently, with a live status indicator per file
- Duplicate files are automatically ignored if dropped twice

### Custom Output Folder
- Choose a **dedicated output folder** for all converted files — no more save-panel per file
- Defaults to the source folder of the first file loaded
- The output folder can be cleared at any time to revert to per-source behaviour

### Filename Preservation
- Converted files keep their **original name**, only the extension changes (`.gpx` → `.plt`)
- No dialog box, no renaming — files are written directly to the output folder

### UI Improvements
- File list with per-file status: pending, loading, converting, done, or failed
- Individual file removal without resetting the whole queue
- Conversion button shows the exact number of ready files (`Convert 5 file(s)`)
- Summary badge at the end: full success (green) or partial (orange with count)
- Interface adapts to the number of loaded files

### Bug Fixes
- Fixed missing `AccentColor` asset in the asset catalog
- Fixed `foregroundStyle(.accentColor)` compiler error on strict ShapeStyle contexts
