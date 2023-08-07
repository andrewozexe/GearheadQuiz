import Foundation

struct PlayerScore : Comparable{
    let playerName: String
    let score: Int
    let time: Int
    
    
    static func < (lhs: PlayerScore, rhs: PlayerScore) -> Bool {
        if lhs.score != rhs.score {
            return lhs.score < rhs.score
        } else {
            return lhs.time < rhs.time
        }
    }

    static func == (lhs: PlayerScore, rhs: PlayerScore) -> Bool {
        return lhs.playerName == rhs.playerName
    }
    
}


