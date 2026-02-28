import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Início", systemImage: "house.fill", value: 0) {
                Text("Tela Início")
                    .font(.title2)
            }

            Tab("Treinos", systemImage: "dumbbell.fill", value: 1) {
                Text("Tela Treinos")
                    .font(.title2)
            }

            Tab("Progresso", systemImage: "chart.line.uptrend.xyaxis", value: 2) {
                Text("Tela Progresso")
                    .font(.title2)
            }

            Tab("Perfil", systemImage: "person.fill", value: 3) {
                Text("Tela Perfil")
                    .font(.title2)
            }
        }
    }
}

#Preview {
    MainTabView()
}
