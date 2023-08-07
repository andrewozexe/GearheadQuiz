import Foundation
import Firebase

class DatabaseManager : ObservableObject {
    
    private let db = Database.database().reference()
    @Published var randomQuestion: Question? = nil
    private var usedQuestionIDs: [String] = []
    
    // Create
    // Create
    func create(question: Question) {
        // Convert the array of options to a dictionary
        var optionsDict: [String: String] = [:]
        for (index, option) in question.options.enumerated() {
            optionsDict["option\(index + 1)"] = option
        }
        
        db.child("questions").child(question.id).setValue([
            "questionText": question.questionText,
            "options": optionsDict,
            "correctOptionIndex": question.correctOptionIndex
        ] as [String : Any])
    }
    
    
    // Read
    func read(questionID: String, completion: @escaping (Question?) -> Void) {
        db.child("questions").child(questionID).observeSingleEvent(of: .value) { snapshot in
            guard let value = snapshot.value as? [String: Any],
                  let questionText = value["questionText"] as? String,
                  let optionsDict = value["options"] as? [String: String],
                  let correctOptionIndex = value["correctOptionIndex"] as? Int else {
                completion(nil)
                return
            }
            
            // Sort the keys of the dictionary
            let sortedKeys = optionsDict.keys.sorted()
            
            // Create the options array based on the sorted keys
            var options: [String] = []
            for key in sortedKeys {
                if let option = optionsDict[key] {
                    options.append(option)
                }
            }
            
            let question = Question(id: questionID, questionText: questionText, options: options, correctOptionIndex: correctOptionIndex)
            completion(question)
        }
    }
    // Update
    func update(questionID: String, newQuestion: Question) {
        db.child("questions").child(questionID).setValue([
            "questionText": newQuestion.questionText,
            "options": newQuestion.options,
            "correctOptionIndex": newQuestion.correctOptionIndex
        ] as [String : Any])
    }
    // Delete
    func delete(questionID: String) {
        db.child("questions").child(questionID).removeValue()
    }
    
    func countQuestions(completion: @escaping (Int) -> Void) {
        db.child("questions").observeSingleEvent(of: .value, with: { (snapshot) in
            let count = Int(snapshot.childrenCount)
            completion(count)
        }) { (error) in
            print("Erro ao recuperar o número de perguntas: \(error.localizedDescription)")
        }
    }
    
    func randomString(max: Int) -> String {
        var randomNumber: Int
        repeat {
            randomNumber = Int.random(in: 1..<max)
        } while usedQuestionIDs.contains(String(randomNumber))
        return String(randomNumber)
    }
    
    func randomQuestion(completion: @escaping (Question?) -> Void) {
        countQuestions { count in
            let randomID = self.randomString(max: count)
            self.usedQuestionIDs.append(randomID)
            self.read(questionID: randomID, completion: completion)
        }
    }
    
    func fetchNewRandomQuestion() {
        randomQuestion { newQuestion in
            self.randomQuestion = newQuestion
        }
    }
    
    func fetchQuestion(id: Int, completion: @escaping (Question?) -> Void) {
        let idString = String(id)
        read(questionID: idString, completion: completion)
    }
    func savePlayerScore(playerScore: PlayerScore) {
        db.child("scores").childByAutoId().setValue([
            "playerName": playerScore.playerName,
            "score": playerScore.score,
            "time": playerScore.time
        ] as [String : Any])
    }
    
    func getPlayerScores(completion: @escaping ([PlayerScore]) -> Void) {
        db.child("scores").observeSingleEvent(of: .value) { snapshot in
            var playerScores: [PlayerScore] = []
            
            for child in snapshot.children {
                if let childSnapshot = child as? DataSnapshot,
                   let value = childSnapshot.value as? [String: Any],
                   let playerName = value["playerName"] as? String,
                   let score = value["score"] as? Int,
                   let time = value["time"] as? Int {
                    let playerScore = PlayerScore(playerName: playerName, score: score, time: time)
                    playerScores.append(playerScore)
                }
            }
            playerScores.sort { $0.score > $1.score || ($0.score == $1.score && $0.time < $1.time) }
            completion(playerScores)
        }
    }

}





