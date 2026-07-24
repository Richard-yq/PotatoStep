import Foundation

public struct StepRecord: Identifiable, Codable {
    public let id: UUID
    public let count: Int
    public let startDate: Date
    public let endDate: Date
    public let isManualSync: Bool
    
    public init(id: UUID = UUID(), count: Int, startDate: Date, endDate: Date, isManualSync: Bool = true) {
        self.id = id
        self.count = count
        self.startDate = startDate
        self.endDate = endDate
        self.isManualSync = isManualSync
    }
}
