<div align="center">

<img src="appLogo.png" alt="Libre Edu Logo" width="120" height="120" />

# Libre Edu

**A modern, open-source educational streaming and offline learning app built with Flutter.**

[![Flutter Build & Release](https://github.com/chandranshB/libre_edu/actions/workflows/flutter-build.yml/badge.svg)](https://github.com/chandranshB/libre_edu/actions/workflows/flutter-build.yml)
[![Latest Release](https://img.shields.io/github/v/release/chandranshB/libre_edu?label=Latest%20Release&color=6f42c1)](https://github.com/chandranshB/libre_edu/releases/latest)
[![Live Web App](https://img.shields.io/badge/Live%20Web%20App-Demo-2ea44f?logo=googlechrome)](https://chandranshb.github.io/libre_edu/)
[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.12%2B-0175C2?logo=dart)](https://dart.dev)
[![Platform Support](https://img.shields.io/badge/Platforms-Android%20%7C%20Windows%20%7C%20Linux%20%7C%20macOS%20%7C%20Web-orange)](#-cross-platform-downloads)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

<br/>

### ⬇️ Direct Download Latest Release (All Platforms)

<p align="center">
  <a href="https://github.com/chandranshB/libre_edu/releases/latest/download/libre_edu-android.apk">
    <img src="https://img.shields.io/badge/Android-Download%20APK-3DDC84?style=for-the-badge&logo=android&logoColor=white" alt="Download Android APK" />
  </a>
  &nbsp;
  <a href="https://github.com/chandranshB/libre_edu/releases/latest/download/libre_edu-windows.zip">
    <img src="https://img.shields.io/badge/Windows-Download%20ZIP-0078D6?style=for-the-badge&logo=windows&logoColor=white" alt="Download Windows ZIP" />
  </a>
  &nbsp;
  <a href="https://github.com/chandranshB/libre_edu/releases/latest/download/libre_edu-linux.zip">
    <img src="https://img.shields.io/badge/Linux-Download%20ZIP-FCC624?style=for-the-badge&logo=linux&logoColor=black" alt="Download Linux ZIP" />
  </a>
  &nbsp;
  <a href="https://github.com/chandranshB/libre_edu/releases/latest/download/libre_edu-macos.zip">
    <img src="https://img.shields.io/badge/macOS-Download%20ZIP-000000?style=for-the-badge&logo=apple&logoColor=white" alt="Download macOS ZIP" />
  </a>
  &nbsp;
  <a href="https://chandranshb.github.io/libre_edu/">
    <img src="https://img.shields.io/badge/Web%20App-Launch%20in%20Browser-4285F4?style=for-the-badge&logo=googlechrome&logoColor=white" alt="Launch Web App" />
  </a>
</p>

[**All Releases & Notes**](https://github.com/chandranshB/libre_edu/releases) • [**Features**](#-features) • [**Installation Guide**](#-installation--running-guide) • [**CI/CD Pipeline**](#-cicd-pipeline--automated-releases) • [**Development**](#-getting-started)

</div>

---

## 📖 Overview

**Libre Edu** is an open-source, cross-platform educational platform engineered to provide a seamless video streaming and offline learning experience. It combines high-performance HLS multi-bitrate video playback, background and floating miniplayer capabilities, local video downloads with FFmpeg processing, and an embedded PDF reader for course materials.

Whether studying on an Android mobile device, a desktop workstation (Windows, Linux, macOS), or directly through a web browser, Libre Edu delivers an intuitive, distraction-free environment.

---

## 📦 Cross-Platform Downloads

Every commit to `main` and all official releases automatically build, verify, and publish binaries for all supported platforms. 

You can always download the latest compiled builds directly using the links below:

| Platform | Download Link | File Type | Compatibility & Details |
| :--- | :--- | :--- | :--- |
| 📱 **Android** | [**`libre_edu-android.apk`**](https://github.com/chandranshB/libre_edu/releases/latest/download/libre_edu-android.apk) | APK | Android 5.0+ (ARM64, ARMv7, x86_64) |
| 🪟 **Windows** | [**`libre_edu-windows.zip`**](https://github.com/chandranshB/libre_edu/releases/latest/download/libre_edu-windows.zip) | Portable ZIP | Windows 10 & 11 (64-bit) |
| 🐧 **Linux** | [**`libre_edu-linux.zip`**](https://github.com/chandranshB/libre_edu/releases/latest/download/libre_edu-linux.zip) | Executable Bundle | Ubuntu, Debian, Fedora, Arch (x64) |
| 🍎 **macOS** | [**`libre_edu-macos.zip`**](https://github.com/chandranshB/libre_edu/releases/latest/download/libre_edu-macos.zip) | App Archive | macOS 11+ (Intel & Apple Silicon) |
| 🌐 **Web** | [**`Launch Live Web App`**](https://chandranshb.github.io/libre_edu/) *(or [Web ZIP](https://github.com/chandranshB/libre_edu/releases/latest/download/libre_edu-web.zip))* | Hosted App / ZIP | Any modern web browser |
| 🔒 **Integrity** | [**`SHA256SUMS.txt`**](https://github.com/chandranshB/libre_edu/releases/latest/download/SHA256SUMS.txt) | Checksums | SHA-256 verification hashes |

> 💡 *To browse all previous releases, version changelogs, and release history, visit the [GitHub Releases](https://github.com/chandranshB/libre_edu/releases) page.*

---

## 📥 Installation & Running Guide

### 📱 Android
1. Click [**Download Android APK**](https://github.com/chandranshB/libre_edu/releases/latest/download/libre_edu-android.apk) on your device.
2. Tap the downloaded `.apk` file in your notification bar or Downloads folder.
3. If prompted by Android, enable **Allow from this source** (or "Install Unknown Apps") in your device settings.
4. Tap **Install** and open **Libre Edu**.

### 🪟 Windows
1. Download [**`libre_edu-windows.zip`**](https://github.com/chandranshB/libre_edu/releases/latest/download/libre_edu-windows.zip).
2. Right-click the `.zip` file and select **Extract All...** to extract to a folder.
3. Open the extracted folder and double-click `libre_edu.exe` to run the app.
   > *Note:* If Windows SmartScreen displays "Windows protected your PC", click **More info** → **Run anyway**.

### 🐧 Linux
1. Download [**`libre_edu-linux.zip`**](https://github.com/chandranshB/libre_edu/releases/latest/download/libre_edu-linux.zip).
2. Install required multimedia and GTK dependencies if not already present:
   ```bash
   # Ubuntu / Debian / Linux Mint
   sudo apt update && sudo apt install -y libgtk-3-0 libmpv-dev libmpv2
   
   # Fedora / RHEL
   sudo dnf install -y gtk3 mpv-libs
   
   # Arch Linux
   sudo pacman -S --needed gtk3 mpv
   ```
3. Extract and run:
   ```bash
   unzip libre_edu-linux.zip -d libre_edu-linux
   chmod +x libre_edu-linux/libre_edu
   ./libre_edu-linux/libre_edu
   ```

### 🍎 macOS
1. Download [**`libre_edu-macos.zip`**](https://github.com/chandranshB/libre_edu/releases/latest/download/libre_edu-macos.zip).
2. Double-click the `.zip` file to extract `libre_edu.app`.
3. Drag `libre_edu.app` into your `/Applications` folder.
4. If macOS Gatekeeper prevents opening because it is from an unidentified developer:
   - Either **Right-click (Control-click)** the app → click **Open** → then click **Open** in the dialog.
   - Or run the following in Terminal to clear the quarantine attribute:
     ```bash
     xattr -cr /Applications/libre_edu.app
     ```

### 🌐 Web
- **No download needed!**
- Simply visit [**chandranshb.github.io/libre_edu**](https://chandranshb.github.io/libre_edu/) in any modern desktop or mobile browser.

---

## 🔒 Checksum Verification

Every release includes a `SHA256SUMS.txt` file containing cryptographic checksums for every build artifact. You can verify that your download has not been corrupted or altered:

```bash
# Linux / macOS
curl -sL https://github.com/chandranshB/libre_edu/releases/latest/download/SHA256SUMS.txt -o SHA256SUMS.txt
sha256sum --ignore-missing -c SHA256SUMS.txt

# Windows (PowerShell)
Get-FileHash libre_edu-windows.zip -Algorithm SHA256
```

---

## ✨ Features

- 📺 **HLS Video Streaming (`.m3u8`)**
  - Smooth multi-quality adaptive streaming powered by [`media_kit`](https://pub.dev/packages/media_kit).
  - Manual video quality selector (1080p, 720p, 480p, 360p, 240p) with custom m3u8 playlist parsing.
  - Playback speed controls, seek intervals, volume, and fullscreen support.
- 🎛️ **Global Floating Miniplayer**
  - Continue watching or listening to lectures in a draggable floating miniplayer while exploring courses and reading documents.
  - Video progress tracking stored locally to resume playback right where you left off.
- ⬇️ **Offline Video Downloads**
  - In-app lecture download manager with real-time download progress.
  - HLS segment downloading and stitching with FFmpeg integration.
  - Dedicated Offline Downloads screen for offline study sessions without internet access.
- 📚 **Structured Course Hierarchy**
  - Deep hierarchical categorization: Batches → Subjects → Chapters → Video Lessons.
  - Detailed course overview including instructor details, brochures, and syllabus summaries.
- 📑 **In-App PDF Viewer**
  - Integrated PDF reading experience with [`syncfusion_flutter_pdfviewer`](https://pub.dev/packages/syncfusion_flutter_pdfviewer).
  - Zoom, pan, and page navigation for lecture notes, study slides, and course handouts.
- 🎨 **Adaptive Material 3 UI**
  - Deep-purple aesthetic with responsive grid and list layouts.
  - Automatic system theme switching between Light and Dark mode.

---

## ⚙️ CI/CD Pipeline & Automated Releases

Libre Edu features an automated GitHub Actions CI/CD workflow ([`.github/workflows/flutter-build.yml`](.github/workflows/flutter-build.yml)) that builds, verifies, packages, and publishes releases across all platforms.

```mermaid
flowchart LR
    A[Push to main / Tag v* / Workflow Dispatch] --> B[GitHub Actions Runner Matrix]
    subgraph Build Matrix
      B --> C1[Android Build]
      B --> C2[Windows Build]
      B --> C3[Linux Build]
      B --> C4[macOS Build]
      B --> C5[Web Build]
    end
    C5 --> D[Deploy to GitHub Pages]
    C1 & C2 & C3 & C4 & C5 --> E[Release Job]
    E --> F[Generate SHA-256 Hashes]
    E --> G[Update Tag & Release Notes]
    E --> H[Publish to GitHub Releases]
```

### 1. Automated Rolling Releases (`latest`)
- **Trigger**: Every push or merge to the `main` or `master` branch.
- **Action**: All 5 platforms are compiled in parallel. Once all builds pass, the release job downloads all artifacts, calculates SHA-256 hashes, force-updates the `latest` git tag, and refreshes the [Latest Release](https://github.com/chandranshB/libre_edu/releases/tag/latest).
- **Result**: You and your users can always download fresh binaries without waiting for manual release tagging!

### 2. Official Versioned Releases (`v*.*.*`)
- **Trigger**: Pushing a version tag like `v1.0.0` or `v0.2.0`.
- **Action**: Automatically generates a permanent GitHub Release with release notes generated from your commits, all platform assets attached, and marks it as the official release.

```bash
# Example: Creating an official release
git tag -a v1.0.0 -m "Release v1.0.0"
git push origin v1.0.0
```

### 3. On-Demand Releases (`workflow_dispatch`)
- Run releases manually at any time from the **GitHub Actions** tab:
  1. Go to **Actions** → **Flutter Build & Release All Platforms**.
  2. Click **Run workflow**.
  3. (Optional) Provide a specific release tag (e.g. `v1.0.1`) or leave empty to update the `latest` rolling release.
  4. (Optional) Check the pre-release box if publishing a beta or preview build.

### 4. Automated Web Deployment (GitHub Pages)
- When the `main` branch builds, the production Web build is automatically deployed to [GitHub Pages](https://chandranshb.github.io/libre_edu/).

---

## 🛠️ Architecture & Tech Stack

| Component | Technology | Description |
| :--- | :--- | :--- |
| **Framework** | [Flutter](https://flutter.dev) | Cross-platform UI toolkit |
| **Language** | [Dart](https://dart.dev) | Object-oriented client-optimized language |
| **State Management** | [`flutter_riverpod`](https://riverpod.dev) | Reactive caching and state management |
| **Routing** | [`go_router`](https://pub.dev/packages/go_router) | Declarative routing with nested shell navigation |
| **Media Playback** | [`media_kit`](https://pub.dev/packages/media_kit) | Hardware-accelerated cross-platform video player |
| **Document Viewer** | [`syncfusion_flutter_pdfviewer`](https://pub.dev/packages/syncfusion_flutter_pdfviewer) | PDF viewer widget |
| **Local Persistence**| [`shared_preferences`](https://pub.dev/packages/shared_preferences) | Stores playback progress and settings |
| **Offline Media** | [`ffmpeg_kit_extended_flutter`](https://pub.dev/packages/ffmpeg_kit_extended_flutter) | Media manipulation and stream stitching |

---

## 💻 Getting Started

### Prerequisites

Ensure you have installed:
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (`>= 3.22.0`)
- [Dart SDK](https://dart.dev/get-dart)
- Platform toolchains for your target OS:
  - **Android**: Android Studio & Android SDK
  - **Windows**: Visual Studio 2022 with "Desktop development with C++"
  - **Linux**: `clang`, `cmake`, `ninja-build`, `pkg-config`, `libgtk-3-dev`, `libmpv-dev`, `liblzma-dev`
  - **macOS**: Xcode & Command Line Tools
  - **Web**: Google Chrome / modern browser

### Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/chandranshB/libre_edu.git
   cd libre_edu
   ```

2. **Install Flutter dependencies**:
   ```bash
   flutter pub get
   ```

3. **Run the application**:
   ```bash
   # Run in Web browser
   flutter run -d chrome

   # Run on Windows
   flutter run -d windows

   # Run on Linux
   flutter run -d linux

   # Run on macOS
   flutter run -d macos

   # Run on connected Android device
   flutter run -d android
   ```

### Building for Release Locally

```bash
# Android APK
flutter build apk --release

# Windows Desktop
flutter build windows --release

# Linux Desktop
flutter build linux --release

# macOS Desktop
flutter build macos --release

# Web
flutter build web --release
```

---

## 🤝 Contributing

Contributions, feature requests, and suggestions are welcome!

1. Fork the Project.
2. Create your Feature Branch (`git checkout -b feature/amazing-feature`).
3. Commit your Changes (`git commit -m 'Add some amazing feature'`).
4. Push to the Branch (`git push origin feature/amazing-feature`).
5. Open a Pull Request.

---

## 📄 License

This project is open-source under the [MIT License](LICENSE).
