# <img src="Sources/Holdr/Resources/Assets.xcassets/Logo.imageset/logo.png" width="40" height="40" alt="Holdr Logo" /> Holdr
> **Formerly PastePalClone**

[![Build Status](https://github.com/heavens7above/Holdr/.github/workflows/build.yml/badge.svg)](https://github.com/heavens7above/Holdr/.github/workflows/build.yml)
![Platform](https://img.shields.io/badge/platform-macOS-lightgrey)
![Swift](https://img.shields.io/badge/Swift-5.9-orange)
![License](https://img.shields.io/badge/license-MIT-blue)

**Made and Dev by Sam**

Holdr is a modern, native macOS clipboard manager built purely with SwiftUI. It seamlessly integrates with your workflow to save, organize, and sync your clipboard history across devices.

---

## 📥 Download

[**Download Latest Holdr.dmg**](https://github.com/heavens7above/Holdr/raw/main/release/Holdr.dmg)

*(Mirror: [Releases Page](https://github.com/heavens7above/Holdr/releases))*


---

## 🚀 Key Features

*   **📋 Infinite History**: Never lose a copied item again. Automatically saves text, links, and images.
*   **☁️ iCloud Sync**: Your clipboard follows you. Syncs mostly instantly across all your Mac devices via iCloud Drive.
*   **🧠 Smart Categorization**: Automatically detects `Text`, `Links`, and `Images`, and can even filter by the Source App.
*   **⚡ Native Performance**: Built with AppKit and SwiftUI for zero-overhead performance and a native macOS feel.
*   **🔒 Private by Design**: Your data stays on your device and your iCloud. No external servers.

---

## 📸 Screenshots

| History View | Smart Filters |
|:---:|:---:|
| *Manage your clips with ease* | *Filter by app or content type* |

---

## 🛠️ Installation

### Option 1: Download Binary
1.  Go to the [Releases](https://github.com/username/Holdr/releases) page.
2.  Download the latest `Holdr.dmg`.
3.  Drag `Holdr.app` to your Applications folder.

### Option 2: Build from Source
```bash
git clone https://github.com/username/Holdr.git
cd Holdr
./scripts/setup_dev.sh
./scripts/build_release.sh
```
The app will be available in the `build/` directory.

---

## 🏗️ Project Structure

Holdr follows a modular architecture for maintainability and scale.

<details>
<summary>📂 <b>View Directory Structure</b></summary>
<br>

- **`Sources/Holdr/App`**: Application entry point and lifecycle management.
- **`Sources/Holdr/Views`**: SwiftUI views and UI components.
- **`Sources/Holdr/Services`**: Core business logic (`ClipboardMonitor`, `AppDiscovery`).
- **`Sources/Holdr/Models`**: Data models and persistence layers.
- **`Sources/Holdr/Resources`**: Asset catalogs and localization files.

</details>

---

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guide](Docs/Contributing.md) for details on how to get started.

1.  Fork the Project
2.  Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3.  Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4.  Push to the Branch (`git push origin feature/AmazingFeature`)
5.  Open a Pull Request

---

## 📚 Documentation

For detailed technical documentation, please refer to the `Docs/` directory:
- [Architecture Overview](Docs/Architecture.md)
- [API Reference](Docs/API.md)

---

## ❓ FAQ & Troubleshooting

<details>
<summary><b>App crashes on launch?</b></summary>
The app loads history from iCloud. On first launch, it might take a moment to initialize. If it persists, check your Internet connection or iCloud Drive status.
</details>

<details>
<summary><b>Clips not saving?</b></summary>
Ensure iCloud Drive is enabled and you have granted the app permission to access the `Documents` folder if prompted. Check System Settings > Privacy & Security > Files and Folders.
</details>

---

PEACE OUT
