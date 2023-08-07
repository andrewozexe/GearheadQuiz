import Foundation
import SwiftUI


struct MainView: View {
    @State private var selectedTab = 0
    @State var start = false

    var body: some View {
        TabView(selection: $selectedTab) {
            ContentView()
            .tabItem {
                Image(systemName: "gamecontroller")
                Text("Game")
            }
            .tag(1)

            RankingView()
                .tabItem {
                    Image(systemName: "list.number")
                    Text("Ranking")
                }
                .tag(2)
        }
    }
}


