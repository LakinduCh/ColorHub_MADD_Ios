# Color Hub (iOS)

Turn any photo into a colour palette. Color Hub finds the main colours in a picture, lets you pick your own colours by tapping the photo, tells you what is in the picture, and saves everything to a searchable library.

> SE4041 Mobile Application Design and Development, Assignment 02, Part A

**Author:** _Your Name_ (_Your Student ID_)
**Platform:** iOS 17.0 or later (SwiftUI)
**Repository:** https://github.com/LakinduCh/ColorHub_MADD_Ios

---

## Purpose and target audience

**Problem:** designers, students and hobbyists often see a colour scheme they love in a photo (a sunset, a room, a poster) but have no quick way to turn it into usable hex codes.

**Solution:** Color Hub extracts a palette from any photo in seconds, lets the user fine-tune it by hand, and stores palettes for later use.

**Target audience:** UI/graphic designers, art and design students, interior decorators and anyone who needs colour inspiration from real-world images.

---

## Features

- **Photo picker** using `PhotosPicker`.
- **Automatic palette extraction** with a custom k-means clustering algorithm (`ColorExtractor`).
- **Manual colour picking:** tap the photo to pick exact colours (up to 8). Tap a picked colour to remove it.
- **Auto-fill toggle:** mix your picked colours with automatic ones, or build a 100% manual palette.
- **Image tagging (machine learning):** Apple's Vision framework (`VNClassifyImageRequest`) labels what is in the photo, for example "sunset" or "plant".
- **Library:** all saved palettes in an adaptive grid with search by name or tag, and delete through a context menu.
- **Copy hex codes:** long-press a swatch to copy its hex code, with a toast message and haptic feedback.
- **Dark Mode** and **Dynamic Type** support.
- **Runs on iPhone and Mac:** platform differences are handled in `PlatformTypes.swift`.

---

## Requirements mapping

| Assignment requirement | Where it is in the app |
|---|---|
| 3+ navigable screens | Capture, Result, Library, Palette Detail |
| Navigation | `NavigationStack`, `navigationDestination`, `TabView` |
| Advanced UI | Spring animations, transitions, `SpatialTapGesture`, context menu, adaptive `LazyVGrid` |
| Custom SwiftUI modifier | `CardStyle` and `CopyToast` (in `CardStyle.swift`) |
| Data persistence | SwiftData (`SavedPalette` model) |
| Emerging technology | Vision framework image classification (machine learning) |
| Visual design | Custom colour theme in `AppTheme`, adaptive light/dark colours |
| Accessibility | Dark Mode, Dynamic Type, accessibility labels |

---

## Tech stack

- **Language:** Swift 5+
- **UI:** SwiftUI
- **Persistence:** SwiftData
- **Machine learning:** Vision (`VNClassifyImageRequest`)
- **Photos:** PhotosUI
- **Architecture:** SwiftUI views with small services (`ColorExtractor`, `ImageTagger`) and shared theme and helper files

---

## Project structure

```
Color hub/
├── ColorHubApp.swift          App entry point, TabView, SwiftData container
├── Components/
│   ├── CardStyle.swift        Custom modifiers: CardStyle, CopyToast, copyHex()
│   └── PaletteStrip.swift     Row of colour swatches
├── Models/
│   └── SavedPalette.swift     SwiftData model for saved palettes
├── Services/
│   ├── ColorExtractor.swift   K-means colour extraction and pixel picking
│   └── ImageTagger.swift      Vision image classification
├── Theme/
│   ├── AppTheme.swift         Colours, spacing, corner radius
│   └── PlatformTypes.swift    iOS/macOS compatibility helpers
└── Views/
    ├── CaptureView.swift      Screen 1: choose photo, pick colours
    ├── ResultView.swift       Screen 2: palette, tags, save
    └── LibraryView.swift      Screen 3: saved palettes, search, detail
```

---

## How to build and run

### Requirements
- A Mac with **Xcode 16 or later**
- iOS Simulator (iPhone) or a physical iPhone on **iOS 17.0 or later**

### Steps
1. Clone the repository:
   ```
   git clone https://github.com/LakinduCh/ColorHub_MADD_Ios.git
   ```
2. Open `Color hub.xcodeproj` in Xcode.
3. Select the **Color hub** target, open the **General** tab and check:
   - **Supported Destinations** includes **iPhone**
   - **Minimum Deployments** for iOS is **17.0** (or lower than your simulator version)
4. Choose an iPhone simulator from the device menu at the top.
5. Press **⌘R** to build and run.

### Using the simulator
- Drag an image file onto the simulator window to add it to Photos, or use the sample photos already there.

### Troubleshooting
| Problem | Fix |
|---|---|
| "OS version lower than deployment target" | Lower **Minimum Deployments** to 17.0, or install a newer simulator runtime |
| Build errors mentioning `UIKit` on Mac | Run on an iPhone simulator, or keep `PlatformTypes.swift` in the project |
| Old build errors remain | **Product > Clean Build Folder** (⇧⌘K), then build again |

---

## How to use the app

1. **Capture tab:** tap **Choose a photo** and pick an image.
2. Tap the photo to pick colours. Each tap adds a swatch. Tap a swatch to remove it.
3. Use **Also fill with automatic colours** to mix in detected colours or turn it off for a fully manual palette.
4. Tap **Extract palette**.
5. **Result screen:** review the palette and the tags, long-press a swatch to copy its hex code, name the palette and tap **Save to Library**.
6. **Library tab:** browse saved palettes, search by name or tag, tap one to open it, or long-press a card to delete it.

---

## Testing

- **Unit tests:** colour extraction and hex conversion logic (_add results here_).
- **UI tests:** capture to result to save flow (_add results here_).
- **User acceptance testing:** feedback from test users (_add results here_).

---

## Third-party resources and AI use

- No third-party libraries are used; only Apple frameworks (SwiftUI, SwiftData, Vision, PhotosUI).
- AI assistance (Claude) was used during development. Prompts, responses and how they helped are documented in the report.

---

## Screenshots

_Add screenshots here (Capture, Result, Library, Dark Mode)._

---

## License

Created for academic purposes (SLIIT, SE4041).
