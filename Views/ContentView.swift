import SwiftUI

public struct ContentView: View {
    @StateObject private var viewModel = StepViewModel()
    @State private var showAddModal = false
    @State private var selectedTab = 0
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            TabView(selection: $selectedTab) {
                DashboardView(viewModel: viewModel, showAddModal: $showAddModal)
                    .tabItem {
                        Label("儀表板", systemImage: "chart.bar.fill")
                    }
                    .tag(0)
                
                HistoryView(viewModel: viewModel)
                    .tabItem {
                        Label("同步紀錄", systemImage: "clock.fill")
                    }
                    .tag(1)
            }
            .tint(Color.blue)
            .navigationTitle(navigationTitleForTab(selectedTab))
            .sheet(isPresented: $showAddModal) {
                AddStepModalView(viewModel: viewModel)
            }
            .alert(isPresented: $viewModel.showAlert) {
                Alert(
                    title: Text("提示"),
                    message: Text(viewModel.alertMessage ?? ""),
                    dismissButton: .default(Text("確 認"))
                )
            }
        }
    }
    
    private func navigationTitleForTab(_ tab: Int) -> String {
        switch tab {
        case 0: return "步數與健康管理"
        case 1: return "同步紀錄"
        default: return "Step Tracker"
        }
    }
}

#Preview {
    ContentView()
}
