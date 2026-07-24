# 步數增加與健康打卡 iOS App (StepSync & Habit Tracker)

一款支援將自訂步數同步至 iOS 系統原生 **Apple Health (健康)** 的原生 SwiftUI 應用程式，結合步數補登、平滑演算法分攤與每日習慣打卡功能。

---

## 🌟 主要特色與功能

1. **Apple Health (HealthKit) 數據同步**：
   - 原生整合 `HKHealthStore`，寫入與讀取 `HKQuantityTypeIdentifierStepCount` 步數數據。
   - **一鍵快速補登**：支援一鍵新增 +1,000 / +3,000 / +5,000 / +10,000 步。

2. **平滑分攤演算法 (Realistic Distribution)**：
   - 避免直接單點寫入大量步數造成健康圖表出現不自然的突刺。
   - 可指定時間區間（例如過去 1 小時內），系統會自動將總步數切割為數個微小時間片，並加入輕微隨機波動（±10%），讓健康 App 的熱量與步數曲線呈現如同真實散步的自然趨勢。

3. **習慣清單打卡 (Habit Tracker & Streaks)**：
   - 每日步數目標與習慣打卡（如晨間漫步 2,000 步、午餐後散步 3,000 步、萬步挑戰）。
   - 紀錄連續打卡天數（Streaks 🔥），提升走路與運動動力。

4. **同步日誌 (Sync Logs)**：
   - 本地紀錄每一次成功寫入 Apple Health 的步數異動與時間點。

---

## 📁 專案結構說明

```
IOS-step-app/
├── Info.plist               # HealthKit 權限說明文字 (NSHealthUpdate / NSHealthShare)
├── Package.swift            # Swift Package Manager 配置
├── StepTrackerApp.swift     # SwiftUI App 程式入口點
├── Models/
│   └── StepRecord.swift     # 步數紀錄與習慣資料模型
├── Services/
│   └── HealthKitManager.swift # HealthKit 授權、讀取與平滑分攤寫入核心服務
├── ViewModels/
│   └── StepViewModel.swift  # MVVM 狀態管理、步數轉換與 UserDefaults 持久化
└── Views/
    ├── ContentView.swift    # 底部分頁 Tab 導覽列與全局 Alert
    ├── DashboardView.swift  # 環形進度儀表板、數據卡片與一鍵同步膠囊按鈕
    ├── AddStepModalView.swift # 自訂步數、時間範圍與寫入模式選單
    ├── HabitListView.swift  # 每日習慣打卡與連勝卡片
    └── HistoryView.swift   # 歷史同步紀錄列表
```

---

## 🚀 如何在 Xcode 中開啟與執行

1. **開啟專案**：
   在 Terminal 中執行以下指令直接開啟 Xcode：
   ```bash
   cd /Users/yq/Documents/side-project/IOS-step-app
   xed .
   ```
   或直接在 Xcode 選單選擇 `File -> Open` 並挑選 `IOS-step-app` 資料夾。

2. **啟用 HealthKit Capability (權限設置)**：
   - 在 Xcode 左側選單點擊專案 Target。
   - 切換至 **Signing & Capabilities** 頁籤。
   - 點擊 **+ Capability**，搜尋並新增 **HealthKit**。

3. **執行測試 (iOS 模擬器 / 實機)**：
   - 選擇 **iOS Simulator (例如 iPhone 16 Pro)** 或連接 **實體 iPhone**。
   - 按下 `Cmd + R` 執行 App。
   - 首次啟動時點擊「授權 Apple Health」，選擇勾選「步數 (Steps)」寫入與讀取權限。
   - 完成後即可開始測試一鍵同步與打卡！

---

## 🛠️ 開發環境與技術棧

- **OS Target**: iOS 16.0+
- **Language**: Swift 5.9+ / SwiftUI
- **Frameworks**: HealthKit, Combine
- **Architecture**: MVVM
