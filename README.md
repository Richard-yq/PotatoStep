# 🥔 PotatoStep - iOS 步數同步與健康管理 App

<p align="center">
  <img src="Assets.xcassets/AppIcon.appiconset/icon-1024.png" width="160" height="160" alt="PotatoStep App Icon" style="border-radius: 32px; shadow: 0 8px 16px rgba(0,0,0,0.15);" />
</p>

<p align="center">
  <b>極簡、極速、自然平滑的 iOS 步數寫入與 Apple Health 同步工具</b>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/iOS-16.0%2B-blue?style=for-the-badge&logo=apple" alt="iOS 16.0+" />
  <img src="https://img.shields.io/badge/Swift-5.9-orange?style=for-the-badge&logo=swift" alt="Swift 5.9" />
  <img src="https://img.shields.io/badge/SwiftUI-Framework-red?style=for-the-badge&logo=swift" alt="SwiftUI" />
  <img src="https://img.shields.io/badge/HealthKit-Supported-brightgreen?style=for-the-badge&logo=apple" alt="HealthKit" />
  <img src="https://img.shields.io/badge/License-MIT-green?style=for-the-badge" alt="License MIT" />
</p>

---

## 🌟 專案簡介 (Overview)

**PotatoStep** 是一款專為 iOS 打造的原生應用程式（基於 SwiftUI + HealthKit 框架）。介面採用最新的 **iOS 18 & Apple Fitness+** 霓虹玻璃質感設計。

讓使用者能靈活將步數寫入 iOS 系統內建的 **Apple Health（健康）**，支援一鍵極速補登與自訂時間區間平滑分攤演算法。

---

## 🔥 核心特色 (Key Features)

- ⚡️ **極速一鍵同步 (Quick Sync)**：
  提供 `+1,000`（散步）、`+3,000`（健走）、`+5,000`（進階）、`+10,000`（萬步衝刺）一鍵快速膠囊按鈕，瞬間同步數據。

- 🌊 **平滑分攤演算法 (Realistic Distribution Algorithm)**：
  自訂寫入大量步數時，系統會自動將總步數均勻切分為數個微小時間片，並加入 ±10% 的自然波動，使 Apple Health 的步數與熱量曲線展現如同真實散步的自然趨勢。

- 📱 **iOS 18 全螢幕滿版介面 (Full Edge-to-Edge Design)**：
  完美適應 iPhone 16 Pro、動態島 (Dynamic Island) 與各大滿版機型，告別黑邊限制。

- 📜 **本地同步日誌 (Sync History Logs)**：
  使用 UserDefaults 本地化持久保存歷次成功寫入 Apple Health 的詳細時間與步數數據。

- 🛡️ **原生隱私安全 (Native HealthKit Integration)**：
  完整支援原生 HealthKit 權限管理與 `PotatoStep.entitlements` 系統數位認證。

---

## 📁 專案檔案結構 (Directory Layout)

```
IOS-step-app/
├── PotatoStep.xcodeproj         # Xcode 官方 App 專案檔 (專案設定與 Target)
├── PotatoStep.entitlements      # HealthKit 數位權限認證檔
├── Info.plist                  # 隱私權說明 (NSHealthShare/NSHealthUpdate) 與全螢幕宣佈 (UILaunchScreen)
├── Package.swift               # Swift Package Manager 配置
├── StepTrackerApp.swift        # SwiftUI App 程式進入點
├── Models/
│   └── StepRecord.swift        # 步數歷史日誌數據模型 (Codable)
├── Services/
│   └── HealthKitManager.swift  # HKHealthStore 初始化、權限請求與平滑分攤寫入核心
├── ViewModels/
│   └── StepViewModel.swift     # MVVM 狀態管理、步數/距離/熱量轉換與 UserDefaults 持久化
├── Views/
│   ├── ContentView.swift       # 雙頁面 Tab 導覽與 Alert 彈窗
│   ├── DashboardView.swift     # 霓虹環形進度條、三欄數據卡片與極速同步膠囊按鈕
│   ├── AddStepModalView.swift  # 自訂步數、起止時間選擇器與分攤模式 Modal
│   └── HistoryView.swift      # 歷史同步紀錄日誌列表
└── Assets.xcassets/            # 官方 AppIcon 圖標庫與內頁 AppLogo
```

---

## 🚀 如何在 Xcode 開啟與執行 (Quick Start)

### 1. 複製專案與開啟 Xcode

在 Mac 終端機 (Terminal) 中執行以下指令：

```bash
git clone https://github.com/Richard-yq/Today-steps.git
cd Today-steps
open PotatoStep.xcodeproj
```

### 2. 設定開發者簽署 (Signing & Capabilities)

1. 在 Xcode 左側選單最上方點擊 **PotatoStep** 藍色圖示。
2. 中間欄位選取 **TARGETS ➔ PotatoStep**。
3. 切換至 **Signing & Capabilities** 頁籤。
4. 在 **Team** 下拉選單中，選擇您的個人 Apple ID 帳號。

### 3. 部署至實體 iPhone

1. 使用傳輸線將 iPhone 連接至 Mac。
2. 在 Xcode 最上方目標選單選擇您的 **iPhone**。
3. 按下快捷鍵 **`Cmd + R`**（或點擊左上角播放鈕 **▶**）即可安裝！

---

## 📲 在 iPhone 上開啟 HealthKit 寫入權限

首次打開 App 寫入步數時，請確保已開啟健康權限：

1. 開啟 iPhone 的 **「設定 (Settings)」➔「健康 (Health)」➔「資料存取權與裝置」**。
2. 點選 **「PotatoStep」**。
3. 點擊 **「開啟全部」** 或確保 **「步數 (Steps)」** 寫入與讀取的開關皆切換為 **綠色開啟狀態**。
4. 回到 PotatoStep 點擊一鍵同步，開啟內建「健康」App 即可看到成功寫入的最新數據！

---

## 🤝 如何分享給朋友 (How to Share)

1. **直接用 Mac 幫朋友安裝**：
   將朋友的 iPhone 接上 Mac，在 Xcode 上方選取朋友的手機按 `Cmd + R` 免費安裝。
2. **分享 GitHub 原始碼**：
   將本倉庫連結 `https://github.com/Richard-yq/Today-steps.git` 分享給擁有 Mac/Xcode 的朋友。
3. **Apple TestFlight 邀請**：
   加入 Apple Developer Program 付費開發者帳號後，上傳至 App Store Connect 即可產生 TestFlight 公開邀請連結。

---

## 🛠️ 開發環境需求 (Requirements)

- **iOS Deployment Target**: iOS 16.0+
- **Xcode Version**: Xcode 15.0+
- **Swift Version**: Swift 5.9+
- **Frameworks**: SwiftUI, HealthKit, Combine

---

## 📄 授權條款 (License)

本專案採用 **MIT License** 授權。詳細資訊請參閱 LICENSE 檔案。
