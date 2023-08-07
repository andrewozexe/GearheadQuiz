import Foundation

struct Question: Codable, Equatable {
    let id: String
    let questionText: String
    var options: [String]
    let correctOptionIndex: Int

    enum CodingKeys: String, CodingKey {
        case id
        case questionText = "question_text"
        case options
        case correctOptionIndex = "correct_option_index"
    }

    var optionsWithIndices: [(String, Int)] {
        return Array(zip(options, options.indices))
    }
    
    var shuffledOptionsWithIndices: [(String, Int)] {
        return optionsWithIndices.shuffled()
    }
    
    static func == (lhs: Question, rhs: Question) -> Bool {
        return lhs.id == rhs.id
    }
}
