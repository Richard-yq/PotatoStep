import Foundation
import Combine
import SwiftUI

public class StepViewModel: ObservableObject {
    @Published public var todaySteps: Int = 0
    @Published public var dailyGoal: Int = 10000
    @Published public var isAuthorized: Bool = false
    @Published public var isSyncing: Bool = false
    @Published public var alertMessage: String? = nil
    @Published public var showAlert: Bool = false
    
    @Published public var historyLogs: [StepRecord] = []
    
    private let healthKitManager = HealthKitManager.shared
    private var cancellables = Set<AnyCancellable>()
    private let historyStorageKey = "StepApp_HistoryLogs"
    
    public init() {
        loadHistoryFromStorage()
        checkAuthorizationAndRefresh()
    }
    
    public var progressRatio: Double {
        guard dailyGoal > 0 else { return 0 }
        return min(Double(todaySteps) / Double(dailyGoal), 1.0)
    }
    
    public var estimatedDistanceKm: Double {
        // 平均 1 步約 0.00075 公里 (0.75 公尺)
        return Double(todaySteps) * 0.00075
    }
    
    public var estimatedCalories: Double {
        // 平均 1 步約 0.04 大卡
        return Double(todaySteps) * 0.04
    }
    
    public func requestAuthorization() {
        healthKitManager.requestAuthorization { [weak self] success, error in
            DispatchQueue.main.async {
                self?.isAuthorized = success
                if success {
                    self?.refreshTodaySteps()
                } else if let error = error {
                    self?.alertMessage = "HealthKit 授權失敗: \(error.localizedDescription)"
                    self?.showAlert = true
                }
            }
        }
    }
    
    public func checkAuthorizationAndRefresh() {
        refreshTodaySteps()
    }
    
    public func refreshTodaySteps() {
        isSyncing = true
        healthKitManager.fetchTodayStepCount { [weak self] steps, error in
            DispatchQueue.main.async {
                self?.isSyncing = false
                if let error = error {
                    print("Fetch steps error: \(error.localizedDescription)")
                } else {
                    self?.todaySteps = Int(steps)
                }
            }
        }
    }
    
    /// 快速新增步數 (例如 +1,000, +3,000, +5,000)
    public func quickAddSteps(count: Int) {
        let now = Date()
        let startDate = now.addingTimeInterval(-1800) // 預設為過去 30 分鐘內
        addStepsWithDetails(count: count, startDate: startDate, endDate: now, isDistributed: true)
    }
    
    /// 寫入步數至 Apple Health 並更新紀錄
    public func addStepsWithDetails(count: Int, startDate: Date, endDate: Date, isDistributed: Bool) {
        guard count > 0 else { return }
        isSyncing = true
        
        let completionHandler: (Bool, Error?) -> Void = { [weak self] success, error in
            DispatchQueue.main.async {
                self?.isSyncing = false
                if success {
                    let record = StepRecord(count: count, startDate: startDate, endDate: endDate, isManualSync: true)
                    self?.historyLogs.insert(record, at: 0)
                    self?.saveHistoryToStorage()
                    self?.refreshTodaySteps()
                    
                    self?.alertMessage = "成功寫入 \(count.formatted()) 步至 Apple Health！"
                    self?.showAlert = true
                } else {
                    self?.alertMessage = "寫入失敗：\(error?.localizedDescription ?? "未知錯誤")。請確認 HealthKit 寫入權限是否已開啟。"
                    self?.showAlert = true
                }
            }
        }
        
        if isDistributed {
            healthKitManager.writeStepsDistributed(totalCount: Double(count), startDate: startDate, endDate: endDate, intervalsCount: 6, completion: completionHandler)
        } else {
            healthKitManager.writeSteps(count: Double(count), startDate: startDate, endDate: endDate, completion: completionHandler)
        }
    }
    
    private func saveHistoryToStorage() {
        if let encoded = try? JSONEncoder().encode(historyLogs) {
            UserDefaults.standard.set(encoded, forKey: historyStorageKey)
        }
    }
    
    private func loadHistoryFromStorage() {
        if let data = UserDefaults.standard.data(forKey: historyStorageKey),
           let decoded = try? JSONDecoder().decode([StepRecord].self, from: data) {
            self.historyLogs = decoded
        }
    }
}
