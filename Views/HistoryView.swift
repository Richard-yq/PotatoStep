import SwiftUI

public struct HistoryView: View {
    @ObservedObject var viewModel: StepViewModel
    
    public init(viewModel: StepViewModel) {
        self.viewModel = viewModel
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        return formatter
    }
    
    public var body: some View {
        Group {
            if viewModel.historyLogs.isEmpty {
                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(LinearGradient(colors: [.blue.opacity(0.15), .purple.opacity(0.15)], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 84, height: 84)
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.system(size: 38, weight: .bold))
                            .foregroundColor(.blue)
                    }
                    Text("尚無同步紀錄")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    Text("當您在主頁極速寫入或自訂同步時，詳細紀錄會出現在這裡")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    Section(header: Text("近期同步紀錄").font(.system(.subheadline, design: .rounded)).fontWeight(.bold)) {
                        ForEach(viewModel.historyLogs) { record in
                            HStack(spacing: 14) {
                                ZStack {
                                    Circle()
                                        .fill(Color.green.opacity(0.15))
                                        .frame(width: 40, height: 40)
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.title3)
                                        .foregroundColor(.green)
                                }
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("+\(record.count.formatted()) 步")
                                        .font(.system(size: 18, weight: .bold, design: .rounded))
                                        .foregroundColor(.primary)
                                    Text("\(dateFormatter.string(from: record.startDate)) ~ \(dateFormatter.string(from: record.endDate))")
                                        .font(.system(size: 12, weight: .medium, design: .rounded))
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                Text("已同步")
                                    .font(.system(size: 12, weight: .bold, design: .rounded))
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 4)
                                    .background(Color.green.opacity(0.12))
                                    .foregroundColor(.green)
                                    .cornerRadius(10)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
                #if os(iOS)
                .listStyle(.insetGrouped)
                #else
                .listStyle(.automatic)
                #endif
            }
        }
    }
}

#Preview {
    HistoryView(viewModel: StepViewModel())
}
