import Foundation

class TimeCounter: ObservableObject {
    @Published var timeElapsed = 0

    private var timer: Timer?
    private var callback: ((Int) -> Void)?

    func start(callback: @escaping (Int) -> Void) {
        self.callback = callback
        timer?.invalidate() // Cancela o timer existente
        timeElapsed = 0

        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            self.timeElapsed += 1
            self.callback?(self.timeElapsed)
        }
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }
}
