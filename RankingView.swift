import Foundation
import SwiftUI

struct RankingView: View {
    @ObservedObject var databaseManager = DatabaseManager()
    @State var playerScores: [PlayerScore] = []

    var body: some View {
        List(playerScores, id: \.playerName) { playerScore in
            VStack(alignment: .leading) {
                Text(playerScore.playerName)
                Text("Score: \(playerScore.score)")
                Text("Time: \(playerScore.time)")
            }
        }
        .onAppear {
            databaseManager.getPlayerScores { scores in
                self.playerScores = scores.sorted { $0.score > $1.score || ($0.score == $1.score && $0.time < $1.time) }
            }
        }
    }
}

