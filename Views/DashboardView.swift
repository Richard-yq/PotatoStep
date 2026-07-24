import SwiftUI

public struct DashboardView: View {
    @ObservedObject var viewModel: StepViewModel
    @Binding var showAddModal: Bool
    @State private var showResetConfirm: Bool = false
    
    // 馬鈴薯跑步動畫控制
    @State private var runWobble: Bool = false
    @State private var rippleScale: CGFloat = 1.0
    @State private var rippleOpacity: Double = 0.0
    
    public init(viewModel: StepViewModel, showAddModal: Binding<Bool>) {
        self.viewModel = viewModel
        self._showAddModal = showAddModal
    }
    
    @ViewBuilder
    private var logoImage: some View {
        #if SWIFT_PACKAGE
        Image("AppLogo", bundle: .module)
            .resizable()
            .aspectRatio(contentMode: .fill)
        #else
        Image("AppLogo")
            .resizable()
            .aspectRatio(contentMode: .fill)
        #endif
    }
    
    public var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                // 1. iOS 18 風格霓虹擬真主儀表板 (Neon Fitness Ring Card)
                ZStack {
                    // 背景動態網格漸層
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.08, green: 0.11, blue: 0.18),
                                    Color(red: 0.13, green: 0.17, blue: 0.28)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 28, style: .continuous)
                                .stroke(
                                    LinearGradient(
                                        colors: viewModel.isPotatoRunning ? [.cyan, .purple, .pink] : [.white.opacity(0.2), .clear, .white.opacity(0.05)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: viewModel.isPotatoRunning ? 2.5 : 1.5
                                )
                        )
                        .shadow(color: viewModel.isPotatoRunning ? Color.cyan.opacity(0.5) : Color(red: 0.1, green: 0.4, blue: 0.9).opacity(0.25), radius: viewModel.isPotatoRunning ? 24 : 20, x: 0, y: 10)
                    
                    VStack(spacing: 24) {
                        // 標題與馬鈴薯跑步 Avatar / 重新整理/重置
                        HStack(alignment: .center) {
                            ZStack(alignment: .bottomTrailing) {
                                logoImage
                                    .frame(width: 48, height: 48)
                                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                                            .stroke(viewModel.isPotatoRunning ? Color.cyan : Color.white.opacity(0.3), lineWidth: viewModel.isPotatoRunning ? 2 : 1)
                                    )
                                    .rotationEffect(.degrees(viewModel.isPotatoRunning ? (runWobble ? 14 : -14) : 0))
                                    .offset(y: viewModel.isPotatoRunning ? (runWobble ? -4 : 4) : 0)
                                    .shadow(color: viewModel.isPotatoRunning ? Color.cyan.opacity(0.6) : Color.black.opacity(0.2), radius: 6, x: 0, y: 3)
                                
                                // 跑步煙塵/汗水小圖標
                                if viewModel.isPotatoRunning {
                                    Text("💨")
                                        .font(.system(size: 14))
                                        .offset(x: 10, y: 4)
                                        .transition(.scale.combined(with: .opacity))
                                }
                            }
                            
                            VStack(alignment: .leading, spacing: 2) {
                                HStack(spacing: 6) {
                                    Text("TODAY'S STEPS")
                                        .font(.system(size: 12, weight: .black, design: .rounded))
                                        .foregroundColor(Color(red: 0.0, green: 0.85, blue: 1.0)) // 青綠霓虹
                                        .tracking(1.5)
                                    
                                    if viewModel.isPotatoRunning {
                                        Text("🏃 奔跑中!")
                                            .font(.system(size: 10, weight: .bold, design: .rounded))
                                            .foregroundColor(.white)
                                            .padding(.horizontal, 6)
                                            .padding(.vertical, 2)
                                            .background(Color.cyan)
                                            .cornerRadius(8)
                                            .transition(.scale)
                                    }
                                }
                                
                                HStack(alignment: .firstTextBaseline, spacing: 4) {
                                    Text("\(viewModel.todaySteps.formatted())")
                                        .font(.system(size: 38, weight: .heavy, design: .rounded))
                                        .foregroundColor(.white)
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.55)
                                        .layoutPriority(1)
                                    Text("步")
                                        .font(.system(size: 15, weight: .bold, design: .rounded))
                                        .foregroundColor(.white.opacity(0.7))
                                }
                            }
                            Spacer()
                            
                            HStack(spacing: 10) {
                                // 重置按鈕
                                Button(action: {
                                    showResetConfirm = true
                                }) {
                                    ZStack {
                                        Circle()
                                            .fill(Color.red.opacity(0.2))
                                            .frame(width: 40, height: 40)
                                        Image(systemName: "trash.fill")
                                            .font(.system(size: 16, weight: .bold))
                                            .foregroundColor(.red)
                                    }
                                }
                                
                                // 重新整理按鈕
                                Button(action: {
                                    viewModel.refreshTodaySteps()
                                }) {
                                    ZStack {
                                        Circle()
                                            .fill(Color.white.opacity(0.12))
                                            .frame(width: 40, height: 40)
                                        Image(systemName: "arrow.triangle.2.circlepath")
                                            .font(.system(size: 16, weight: .bold))
                                            .foregroundColor(.white)
                                            .rotationEffect(.degrees(viewModel.isSyncing ? 360 : 0))
                                            .animation(viewModel.isSyncing ? Animation.linear(duration: 1).repeatForever(autoreverses: false) : .default, value: viewModel.isSyncing)
                                    }
                                }
                            }
                        }
                        
                        // 霓虹進度環 (Electric Cyan-Purple Ring + 馬鈴薯跑步特效)
                        ZStack {
                            // 衝刺時的擴散漣漪圈
                            Circle()
                                .stroke(Color.cyan.opacity(rippleOpacity), lineWidth: 3)
                                .scaleEffect(rippleScale)
                                .frame(width: 180, height: 180)
                            
                            Circle()
                                .stroke(Color.white.opacity(0.08), lineWidth: 20)
                                .frame(width: 180, height: 180)
                            
                            Circle()
                                .trim(from: 0.0, to: CGFloat(viewModel.progressRatio))
                                .stroke(
                                    AngularGradient(
                                        gradient: Gradient(colors: [
                                            Color(red: 0.0, green: 0.95, blue: 0.8),  // Electric Cyan
                                            Color(red: 0.35, green: 0.3, blue: 0.95), // Neon Violet
                                            Color(red: 0.95, green: 0.2, blue: 0.6),  // Bright Pink
                                            Color(red: 0.0, green: 0.95, blue: 0.8)
                                        ]),
                                        center: .center,
                                        startAngle: .degrees(-90),
                                        endAngle: .degrees(270)
                                    ),
                                    style: StrokeStyle(lineWidth: 20, lineCap: .round)
                                )
                                .rotationEffect(.degrees(-90))
                                .frame(width: 180, height: 180)
                                .shadow(color: viewModel.isPotatoRunning ? Color.cyan : Color(red: 0.0, green: 0.95, blue: 0.8).opacity(0.5), radius: viewModel.isPotatoRunning ? 20 : 12, x: 0, y: 0)
                                .animation(.spring(response: 0.8, dampingFraction: 0.7), value: viewModel.progressRatio)
                            
                            // 中心數字與跑步氣泡 Toast
                            VStack(spacing: 4) {
                                if viewModel.isPotatoRunning {
                                    HStack(spacing: 4) {
                                        Text("🥔💨")
                                        Text("+\(viewModel.lastAddedSteps.formatted()) 步")
                                            .font(.system(size: 14, weight: .black, design: .rounded))
                                            .foregroundColor(.cyan)
                                    }
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 4)
                                    .background(Color.black.opacity(0.6))
                                    .cornerRadius(12)
                                    .transition(.scale.combined(with: .opacity))
                                }
                                
                                Text("\(Int(viewModel.progressRatio * 100))%")
                                    .font(.system(size: 34, weight: .black, design: .rounded))
                                    .foregroundColor(.white)
                                Text("目標 \(viewModel.dailyGoal.formatted()) 步")
                                    .font(.system(size: 13, weight: .bold, design: .rounded))
                                    .foregroundColor(.white.opacity(0.6))
                            }
                        }
                        .padding(.vertical, 6)
                        
                        // 三欄式數據玻璃卡片
                        HStack(spacing: 12) {
                            ModernStatCard(
                                icon: "figure.walk",
                                value: String(format: "%.2f", viewModel.estimatedDistanceKm),
                                unit: "km",
                                title: "移動距離",
                                color: Color(red: 0.0, green: 0.85, blue: 1.0)
                            )
                            
                            ModernStatCard(
                                icon: "flame.fill",
                                value: String(format: "%.0f", viewModel.estimatedCalories),
                                unit: "kcal",
                                title: "消耗熱量",
                                color: Color(red: 1.0, green: 0.4, blue: 0.2)
                            )
                            
                            ModernStatCard(
                                icon: "bolt.fill",
                                value: String(format: "%.0f", Double(viewModel.todaySteps) * 0.012),
                                unit: "分",
                                title: "活躍時間",
                                color: Color(red: 0.95, green: 0.8, blue: 0.0)
                            )
                        }
                    }
                    .padding(24)
                }
                .padding(.horizontal)
                
                // 2. 快速同步區塊 (Quick Sync Pills)
                VStack(alignment: .leading, spacing: 14) {
                    HStack {
                        Text("極速寫入步數")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                        Spacer()
                        Text("一鍵同步至 Apple Health")
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ModernQuickPill(title: "+1,000", subtitle: "輕量散步", icon: "plus.circle.fill", gradient: [Color.blue, Color.cyan]) {
                                viewModel.quickAddSteps(count: 1000)
                            }
                            ModernQuickPill(title: "+3,000", subtitle: "日常健走", icon: "bolt.circle.fill", gradient: [Color.purple, Color.blue]) {
                                viewModel.quickAddSteps(count: 3000)
                            }
                            ModernQuickPill(title: "+5,000", subtitle: "進階運動", icon: "flame.circle.fill", gradient: [Color.orange, Color.red]) {
                                viewModel.quickAddSteps(count: 5000)
                            }
                            ModernQuickPill(title: "+10,000", subtitle: "萬步衝刺", icon: "trophy.circle.fill", gradient: [Color(red: 0.95, green: 0.2, blue: 0.6), Color.purple]) {
                                viewModel.quickAddSteps(count: 10000)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
                // 3. 自訂時段與分攤按鈕
                Button(action: {
                    showAddModal = true
                }) {
                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(Color.white.opacity(0.2))
                                .frame(width: 36, height: 36)
                            Image(systemName: "slider.horizontal.3")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                        }
                        
                        Text("自訂時間區間 ‧ 平滑分攤步數")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Image(systemName: "arrow.right")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding(.vertical, 14)
                    .padding(.horizontal, 20)
                    .background(
                        LinearGradient(
                            colors: [Color.blue, Color(red: 0.35, green: 0.3, blue: 0.95)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(20)
                    .shadow(color: Color.blue.opacity(0.35), radius: 12, x: 0, y: 6)
                }
                .padding(.horizontal)
                
                // 4. HealthKit 權限玻璃警示條 (移至頁面最下方)
                if !viewModel.isAuthorized {
                    Button(action: {
                        viewModel.requestAuthorization()
                    }) {
                        HStack(spacing: 14) {
                            ZStack {
                                Circle()
                                    .fill(LinearGradient(colors: [.red, .orange], startPoint: .topLeading, endPoint: .bottomTrailing))
                                    .frame(width: 44, height: 44)
                                Image(systemName: "heart.fill")
                                    .font(.title3)
                                    .foregroundColor(.white)
                            }
                            
                            VStack(alignment: .leading, spacing: 3) {
                                Text("連結 Apple Health (健康)")
                                    .font(.system(size: 16, weight: .bold, design: .rounded))
                                    .foregroundColor(.primary)
                                Text("點擊授權讀取與同步步數權限")
                                    .font(.system(size: 13, weight: .medium, design: .rounded))
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.secondary)
                        }
                        .padding(14)
                        .background(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                #if canImport(UIKit)
                                .fill(Color(uiColor: .secondarySystemGroupedBackground))
                                #else
                                .fill(Color.gray.opacity(0.12))
                                #endif
                                .shadow(color: Color.black.opacity(0.06), radius: 10, x: 0, y: 4)
                        )
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
        .onChange(of: viewModel.isPotatoRunning) { isRunning in
            if isRunning {
                // 觸發馬鈴薯跑步搖擺與環形漣漪動畫
                withAnimation(Animation.easeInOut(duration: 0.15).repeatForever(autoreverses: true)) {
                    runWobble = true
                }
                
                rippleScale = 1.0
                rippleOpacity = 0.8
                withAnimation(Animation.easeOut(duration: 1.2).repeatForever(autoreverses: false)) {
                    rippleScale = 1.35
                    rippleOpacity = 0.0
                }
            } else {
                runWobble = false
                rippleScale = 1.0
                rippleOpacity = 0.0
            }
        }
        .confirmationDialog("重置今日步數", isPresented: $showResetConfirm, titleVisibility: .visible) {
            Button("確定清除今日新增步數", role: .destructive) {
                viewModel.resetTodaySteps()
            }
            Button("取消", role: .cancel) {}
        } message: {
            Text("此操作將會從 Apple Health 與紀錄中刪除今日由 PotatoStep 新增的步數。")
        }
        #if canImport(UIKit)
        .background(Color(.systemGroupedBackground))
        #endif
    }
}

struct ModernStatCard: View {
    let icon: String
    let value: String
    let unit: String
    let title: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(color)
            
            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text(value)
                    .font(.system(size: 17, weight: .heavy, design: .rounded))
                    .foregroundColor(.white)
                Text(unit)
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundColor(.white.opacity(0.6))
            }
            
            Text(title)
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.5))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color.white.opacity(0.07))
        .cornerRadius(16)
    }
}

struct ModernQuickPill: View {
    let title: String
    let subtitle: String
    let icon: String
    let gradient: [Color]
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundStyle(LinearGradient(colors: gradient, startPoint: .topLeading, endPoint: .bottomTrailing))
                    Spacer()
                    Image(systemName: "plus")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.secondary)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 20, weight: .heavy, design: .rounded))
                        .foregroundColor(.primary)
                    Text(subtitle)
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundColor(.secondary)
                }
            }
            .padding(16)
            .frame(width: 135)
            .background(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    #if canImport(UIKit)
                    .fill(Color(uiColor: .secondarySystemGroupedBackground))
                    #else
                    .fill(Color.gray.opacity(0.12))
                    #endif
                    .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
            )
        }
    }
}

#Preview {
    DashboardView(viewModel: StepViewModel(), showAddModal: .constant(false))
}
