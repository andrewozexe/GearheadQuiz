import SwiftUI
import CoreHaptics
import AVFoundation


struct ContentView: View {
    
    private let feedbackGenerator = UINotificationFeedbackGenerator()
    var audioPlayer: AVAudioPlayer?
    @State var playerName = ""
    @ObservedObject var databaseManager = DatabaseManager()
    @StateObject var timeCounter = TimeCounter()
    @State private var randomQuestion: Question? = nil
    @State private var shuffledOptions: [(String, Int)] = []
    @State var contador = 0
    @State var vidas = 1
    @State var lostByTime = false
    @State private var selectedOption: String? = nil
    @State private var isCorrect: Bool = false
    @State private var gameEnded = false
    @State var showFeedback = false
    @State var start = false
    @State var timesUp = 60
    
    
    var body: some View {
        if start {
            if !gameEnded {
                VStack{
                    VStack{
                        Text("Tempo restante: \(timesUp - timeCounter.timeElapsed)")
                            .padding()
                        HStack(spacing: 10){
                            Text("Acertos: \(contador)")
                            Text("Vidas: \(vidas)")
                        }
                        
                    }.padding(.top)
                    Spacer()
                    HStack{
                        if showFeedback{
                            if isCorrect {
                                Text(" +2s ")
                                    .foregroundColor(.green)
                                    .bold()
                                    .font(.system(size: 35))
                            } else {
                                Text(" X ")
                                    .foregroundColor(.red)
                                    .bold()
                                    .font(.system(size: 35))
                            }
                        } else {
                            Text("  ")
                                .foregroundColor(.red)
                                .bold()
                                .font(.system(size: 35))
                        }
                    }.padding(.bottom, 10)
                        .padding(.top, 15)
                    VStack{
                        if let question = databaseManager.randomQuestion {
                            Text(question.questionText)
                                .font(.system(size: 20))
                                .bold()
                                .padding(5)
                            ForEach(shuffledOptions, id: \.0) { option in
                                Button(action: {
                                    let correctOption = question.options[question.correctOptionIndex]
                                    if option.0 == correctOption {
                                        isCorrect = true
                                        contador += 1
                                        timeCounter.timeElapsed -= 2
                                        timesUp += 2
                                        feedbackGenerator.notificationOccurred(.success)
                                        selectedOption = option.0
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                                            databaseManager.randomQuestion = nil
                                            databaseManager.fetchNewRandomQuestion()
                                        }
                                        showFeedback = true
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                            showFeedback = false
                                        }
                                    } else {
                                        isCorrect = false
                                        vidas -= 1
                                        feedbackGenerator.notificationOccurred(.error)
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                                            databaseManager.randomQuestion = nil
                                            databaseManager.fetchNewRandomQuestion()
                                        }
                                        selectedOption = option.0
                                        if vidas == 0 {
                                            gameEnded = true
                                        }
                                        showFeedback = true
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                            showFeedback = false
                                        }
                                    }
                                }) {
                                    Text(option.0)
                                        .bold()
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(selectedOption == option.0 ? (isCorrect ? Color.green : Color.red) : Color.blue)
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                }
                            }
                        } else {
                            loadingView()
                        }
                    }
                    .padding()
                    Spacer()
                    
                    Button(action: {
                        databaseManager.fetchNewRandomQuestion()
                        timeCounter.timeElapsed += 3
                        
                    }) {
                        Text("Buscar nova pergunta (-3s)")
                        
                    }.padding(.bottom)
                }
                .onAppear(perform: {
                    databaseManager.randomQuestion = nil
                    databaseManager.fetchNewRandomQuestion()
                    timeCounter.start { timeElapsed in
                        if timeElapsed >= timesUp {
                            gameEnded = true
                        }
                    }
                    resetGame()
                    
                })
                .onChange(of: databaseManager.randomQuestion) { newQuestion in
                    if let newQuestion = newQuestion {
                        shuffledOptions = newQuestion.shuffledOptionsWithIndices
                        showFeedback = false
                    }
                }
            } else {
                FinalView(score: contador, lostByTime: lostByTime, gameEnded: $gameEnded, playerName: $playerName, start: $start)
                    .onAppear {
                        databaseManager.savePlayerScore(playerScore: PlayerScore(playerName: playerName, score: contador, time: timeCounter.timeElapsed))

                    }
            }
        } else {
            VStack {
                TextField("Enter your name", text: $playerName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                Button("Start Game") {
                    start = true
                    playerName = playerName
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
        }
    }
    
    mutating func playSound(sound: String, type: String) {
        if let path = Bundle.main.path(forResource: sound, ofType: type) {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
                audioPlayer?.play()
            } catch {
                print("Could not find and play the sound file.")
            }
        }
    }
    func loadingView() -> some View {
           VStack {
               Text("Carregando pergunta...")
                   .font(.system(size: 20))
                   .bold()
                   .padding(5)
               ForEach(0..<4) { _ in
                   Text("...")
                       .bold()
                       .frame(maxWidth: .infinity)
                       .padding()
                       .background(Color.blue)
                       .foregroundColor(.white)
                       .cornerRadius(10)
               }
           }
       }
    func resetGame() {
        contador = 0
        vidas = 5
        lostByTime = false
    }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView(playerName: "André")
//    }
//}
