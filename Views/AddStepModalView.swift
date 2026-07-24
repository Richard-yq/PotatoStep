import SwiftUI

public struct AddStepModalView: View {
    @ObservedObject var viewModel: StepViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var stepText: String = "3000"
    @State private var startDate: Date = Date().addingTimeInterval(-3600)
    @State private var endDate: Date = Date()
    @State private var isDistributed: Bool = true
    
    public init(viewModel: StepViewModel) {
        self.viewModel = viewModel
    }
    
    private var parsedStepCount: Int {
        let clean = stepText.filter { $0.isNumber }
        return Int(clean) ?? 0
    }
    
    public var body: some View {
        NavigationView {
            Form {
                Section(header: Text("步數設定").font(.system(.subheadline, design: .rounded)).fontWeight(.bold)) {
                    HStack {
                        Image(systemName: "figure.walk.circle.fill")
                            .foregroundStyle(LinearGradient(colors: [.blue, .cyan], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .font(.title)
                        
                        let textfield = TextField("請輸入欲寫入的步數", text: $stepText)
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                        #if os(iOS)
                        textfield.keyboardType(.numberPad)
                        #else
                        textfield
                        #endif
                    }
                    
                    if parsedStepCount > 200000 {
                        Text("⚠️ 單次寫入上限為 200,000 步")
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundColor(.orange)
                    }
                    
                    HStack(spacing: 8) {
                        Button("+1,000") { addStepCount(1000) }
                            .buttonStyle(.bordered)
                            .tint(.blue)
                        Button("+3,000") { addStepCount(3000) }
                            .buttonStyle(.bordered)
                            .tint(.blue)
                        Button("+5,000") { addStepCount(5000) }
                            .buttonStyle(.borderedProminent)
                            .tint(.blue)
                    }
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .padding(.vertical, 4)
                }
                
                Section(header: Text("時間區間 (Apple Health)").font(.system(.subheadline, design: .rounded)).fontWeight(.bold)) {
                    DatePicker("開始時間", selection: $startDate, in: ...endDate)
                        .font(.system(.body, design: .rounded))
                        .onChange(of: startDate) { newStart in
                            if newStart >= endDate {
                                endDate = newStart.addingTimeInterval(600)
                            }
                        }
                    
                    DatePicker("結束時間", selection: $endDate, in: startDate...Date())
                        .font(.system(.body, design: .rounded))
                        .onChange(of: endDate) { newEnd in
                            if newEnd <= startDate {
                                startDate = newEnd.addingTimeInterval(-600)
                            }
                        }
                }
                
                Section(
                    header: Text("分攤演算法").font(.system(.subheadline, design: .rounded)).fontWeight(.bold),
                    footer: Text("平滑分攤會將總步數切分為數個微小時間片，並加入輕微隨機波動，使 Health 圖表呈現如真實健走的自然曲線。")
                        .font(.system(.caption, design: .rounded))
                ) {
                    Toggle(isOn: $isDistributed) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("平滑分攤 (推薦)")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                            Text("自然散佈於指定時間區間內")
                                .font(.system(size: 13, weight: .medium, design: .rounded))
                                .foregroundColor(.secondary)
                        }
                    }
                    .tint(.blue)
                }
            }
            .navigationTitle("自訂同步步數")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                    .font(.system(.body, design: .rounded))
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("確認寫入") {
                        let count = min(parsedStepCount, 200000)
                        if count > 0 {
                            viewModel.addStepsWithDetails(count: count, startDate: startDate, endDate: endDate, isDistributed: isDistributed)
                            dismiss()
                        }
                    }
                    .disabled(parsedStepCount <= 0)
                    .font(.system(.body, design: .rounded))
                    .fontWeight(.bold)
                }
            }
        }
    }
    
    private func addStepCount(_ delta: Int) {
        let current = parsedStepCount
        stepText = "\(current + delta)"
    }
}

#Preview {
    AddStepModalView(viewModel: StepViewModel())
}
