import SwiftUI

struct FinalView: View {
    var score: Int
    var lostByTime: Bool
    @Binding var gameEnded : Bool
    @Binding var playerName : String
    @Binding var start : Bool
    
    var body: some View {
        VStack(spacing: 12) {
            Text("Game Over")
                .bold()
                .foregroundColor(.red)
                .font(.largeTitle)
                .padding()
            
            Text("Você acertou \(score) perguntas!")
                .font(.title)
                .bold()
            
            
            if lostByTime {
                Text("O tempo acabou!")
                    .bold()
            } else {
                Text("Suas vidas abacaram!")
                    .bold()
            }
            
            Button(action: {
                gameEnded = false
                start = false
                playerName = ""
            }, label: {
                Text("Jogar novamente")
                    .font(.title)
                    .padding(10)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            })
        }
    }
}

//struct GameOverView_Previews: PreviewProvider {
//    static var previews: some View {
//        FinalView(score: 10, lostByTime: false, gameEnded: )
//    }
//}
