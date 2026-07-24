import Foundation
import HealthKit

public class HealthKitManager: ObservableObject {
    public static let shared = HealthKitManager()
    
    private let healthStore = HKHealthStore()
    @Published public var isAuthorized: Bool = false
    @Published public var authorizationError: String? = nil
    
    private init() {}
    
    /// 檢查系統是否支援 HealthKit
    public var isHealthKitAvailable: Bool {
        return HKHealthStore.isHealthDataAvailable()
    }
    
    /// 請求 HealthKit 步數的讀取與寫入權限
    public func requestAuthorization(completion: @escaping (Bool, Error?) -> Void) {
        guard isHealthKitAvailable else {
            let error = NSError(domain: "HealthKitManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "HealthKit 在此裝置不可用"])
            DispatchQueue.main.async {
                self.isAuthorized = false
                self.authorizationError = error.localizedDescription
            }
            completion(false, error)
            return
        }
        
        guard let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
            let error = NSError(domain: "HealthKitManager", code: 2, userInfo: [NSLocalizedDescriptionKey: "無法存取步數類型數據"])
            completion(false, error)
            return
        }
        
        let typesToShare: Set<HKSampleType> = [stepType]
        let typesToRead: Set<HKObjectType> = [stepType]
        
        healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead) { success, error in
            DispatchQueue.main.async {
                self.isAuthorized = success
                if let error = error {
                    self.authorizationError = error.localizedDescription
                }
            }
            completion(success, error)
        }
    }
    
    /// 讀取今日發生的累積總步數
    public func fetchTodayStepCount(completion: @escaping (Double, Error?) -> Void) {
        guard let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
            completion(0, nil)
            return
        }
        
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: stepType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
            guard let result = result, let sum = result.sumQuantity() else {
                completion(0, error)
                return
            }
            let steps = sum.doubleValue(for: HKUnit.count())
            completion(steps, nil)
        }
        
        healthStore.execute(query)
    }
    
    /// 單次直接寫入特定數量的步數至 HealthKit
    public func writeSteps(count: Double, startDate: Date, endDate: Date, completion: @escaping (Bool, Error?) -> Void) {
        guard let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
            let error = NSError(domain: "HealthKitManager", code: 3, userInfo: [NSLocalizedDescriptionKey: "步數類型不可用"])
            completion(false, error)
            return
        }
        
        let quantity = HKQuantity(unit: HKUnit.count(), doubleValue: count)
        let sample = HKQuantitySample(type: stepType, quantity: quantity, start: startDate, end: endDate)
        
        healthStore.save(sample) { success, error in
            completion(success, error)
        }
    }
    
    /// 平滑分攤寫入：將總步數均勻或微幅隨機分開在指定的時間區間內寫入多筆 Sample
    public func writeStepsDistributed(totalCount: Double, startDate: Date, endDate: Date, intervalsCount: Int = 6, completion: @escaping (Bool, Error?) -> Void) {
        guard let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
            completion(false, nil)
            return
        }
        
        let totalDuration = endDate.timeIntervalSince(startDate)
        guard totalDuration > 0, intervalsCount > 0 else {
            writeSteps(count: totalCount, startDate: startDate, endDate: endDate, completion: completion)
            return
        }
        
        let intervalDuration = totalDuration / Double(intervalsCount)
        let baseStepsPerInterval = totalCount / Double(intervalsCount)
        
        var samples: [HKQuantitySample] = []
        var currentStart = startDate
        
        for i in 0..<intervalsCount {
            let currentEnd = (i == intervalsCount - 1) ? endDate : currentStart.addingTimeInterval(intervalDuration)
            
            // 增加微小微調隨機波動（約 ±10%），讓趨勢圖更自然真實
            let variation = Double.random(in: 0.9...1.1)
            var intervalSteps = (i == intervalsCount - 1) ? (totalCount - samples.reduce(0) { $0 + $1.quantity.doubleValue(for: .count()) }) : (baseStepsPerInterval * variation)
            intervalSteps = max(1, intervalSteps)
            
            let quantity = HKQuantity(unit: HKUnit.count(), doubleValue: intervalSteps)
            let sample = HKQuantitySample(type: stepType, quantity: quantity, start: currentStart, end: currentEnd)
            samples.append(sample)
            
            currentStart = currentEnd
        }
        
        healthStore.save(samples) { success, error in
            completion(success, error)
        }
    }
}
