import Foundation

class AppState: ObservableObject {
    @Published var gameEnded: Bool = false
    @Published var key: UUID = UUID()
}
