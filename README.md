# ⚡ PIXELDROP

> **Premium Cross-Platform File Transfer Platform (Android APK + Windows EXE)**
> Dark Pixel Theme (`#080808` & `#FF6338`), 5-Minute Expiring QR Pairing, In-App Auto-Updates (Zero Browser Required), and Local Wi-Fi P2P.

---

## 🚀 លក្ខណៈពិសេសចម្បង (Key Features)

1. **In-App Auto Update (មិនបាច់បើក Web Browser):**
   - **Windows:** ទាញយក និងដំឡើង update ដោយផ្ទាល់ក្នុងកម្មវិធីតាមរយៈ Tauri Updater Plugin រួច Restart ភ្លាមៗ។
   - **Android:** ទាញយកឯកសារ `.apk` ផ្ទាល់ក្នុង App ជាមួយ Progress Bar រួចហៅ System Package Installer មកសួរដំឡើងភ្លាមៗ។
2. **Auto-Detect Release ពី GitHub:**
   - រាល់ពេលអ្នក Push កំណែថ្មីទៅកាន់ `https://github.com/MEYYYNASH/TRANSFERAPP.git` (ឧទាហរណ៍ Tag `v1.0.1`):
     - GitHub Actions នឹង Build ទាំង `PIXELDROP.apk` និង `PIXELDROP-Setup.exe` ដោយស្វ័យប្រវត្តិ។
     - បង្កើត `latest.json` Manifest។
     - កម្មវិធីលើទូរស័ព្ទ និងកុំព្យូទ័រនឹងលោត **Notification** ប្រាប់ថាមានកំណែថ្មីភ្លាមៗ!
3. **QR Pairing សុវត្ថិភាពខ្ពស់ (៥ នាទី):**
   - បង្កើត QR Token មួយដង និងលេខកូដសម្ងាត់ ៦ ខ្ទង់ ដែលមានសុពលភាពត្រឹម ៥ នាទី។
4. **ផ្ទាំងបង្ហាញបែប Dynamic Island (Floating Transfer Pill):**
   - បង្ហាញភាគរយផ្ទេរ ល្បឿន និងឈ្មោះឯកសារយ៉ាងរលូន។
5. **Local LAN & Cloud Relay Fallback:**
   - ផ្ទេរផ្ទាល់តាម Wi-Fi ក្នុងផ្ទះ (ល្បឿនលឿន មិនអស់ Internet) ឬតាមរយៈ Cloudflare R2 / Supabase ប្រសិនបើនៅឆ្ងាយពីគ្នា។

---

## 📁 រចនាសម្ព័ន្ធគម្រោង (Project Architecture)

```text
TRANSFERAPP/
├── .github/
│   └── workflows/
│       └── release.yml        # CI/CD: Auto-build Android APK & Windows EXE on tag push
├── apps/
│   ├── android/               # Flutter + Dart App (PIXELDROP.apk)
│   │   ├── lib/
│   │   │   ├── screens/       # Dashboard, QR Pairing, Update Center
│   │   │   ├── services/      # In-App APK Downloader & Installer
│   │   │   ├── theme/         # Pixel Dark Theme (#080808, #FF6338)
│   │   │   └── widgets/       # Dynamic Island Pill
│   │   └── pubspec.yaml
│   └── windows/               # Tauri 2 + React + TypeScript (PIXELDROP-Setup.exe)
│       ├── src/
│       │   ├── services/      # In-App GitHub Updater & Notifications
│       │   ├── App.tsx        # Dashboard, Drag-Drop, QR Pairing, Updates
│       │   └── main.tsx
│       ├── src-tauri/         # Rust Tauri Backend with Tray & Updater
│       └── package.json
├── packages/
│   ├── design-tokens/         # 24px Pixel Art SVG Icons & Color Palette
│   └── api-contracts/         # Shared Types (Pairing, Transfers, Manifests)
├── backend/
│   ├── api/                   # Lightweight Pairing & Verify API
│   └── database/              # PostgreSQL / Supabase Schema & Migrations
└── README.md
```

---

## 🛠️ របៀប Push កំណែថ្មីទៅ GitHub ដើម្បីឱ្យ App ធ្វើបច្ចុប្បន្នភាពស្វ័យប្រវត្តិ

រាល់ពេលដែលអ្នកចង់បញ្ចេញកំណែថ្មី (ឧទាហរណ៍ `v1.0.1`)៖

```bash
# ១. Commit កូដរបស់អ្នក
git add .
git commit -m "Release v1.0.1: Feature update and improvements"

# ២. បង្កើត Tag និង Push ទៅ GitHub
git tag v1.0.1
git push origin main --tags
```

**អ្វីដែលនឹងកើតឡើងបន្ទាប់មក៖**
1. **GitHub Actions** នឹងដំណើរការ Build `PIXELDROP.apk` និង `PIXELDROP-Setup.exe` ដោយស្វ័យប្រវត្តិ។
2. វានឹងបង្កើត GitHub Release ជាមួយឯកសារ `latest.json`។
3. **App របស់ User** (ទាំងលើ Android និង Windows) នឹងទទួលបាន Notification ហើយអាចចុច **[UPDATE NOW (IN-APP)]** ដើម្បីទាញយក និងដំឡើងភ្លាមៗ ដោយមិនបាច់បើក Web Browser ឡើយ!

---

## 💻 របៀប Run និង Test ក្នុងម៉ាស៊ីនផ្ទាល់ (Local Development)

### Windows App (Tauri 2 + React):
```bash
cd apps/windows
npm install
npm run dev        # Run web preview
npm run tauri dev  # Run native Windows app with Rust backend
```

### Android App (Flutter):
```bash
cd apps/android
flutter pub get
flutter run
```

### Backend API:
```bash
cd backend/api
node index.ts
```
