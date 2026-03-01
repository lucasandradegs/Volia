import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0

    var body: some View {
        if #available(iOS 18.0, *) {
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
                    ProfileView()
                }
            }
        } else {
            TabView(selection: $selectedTab) {
                Text("Tela Início")
                    .font(.title2)
                    .tabItem { Label("Início", systemImage: "house.fill") }
                    .tag(0)

                Text("Tela Treinos")
                    .font(.title2)
                    .tabItem { Label("Treinos", systemImage: "dumbbell.fill") }
                    .tag(1)

                Text("Tela Progresso")
                    .font(.title2)
                    .tabItem { Label("Progresso", systemImage: "chart.line.uptrend.xyaxis") }
                    .tag(2)

                ProfileView()
                    .tabItem { Label("Perfil", systemImage: "person.fill") }
                    .tag(3)
            }
        }
    }
}

#Preview {
    MainTabView()
}
