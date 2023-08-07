import Foundation
import SwiftUI

var tam : CGFloat = 45

struct Clock: View {
    var counter: Int
    var countTo: Int
    
    var body: some View {
        VStack {
            Text(counterToMinutes())
                .bold()
                .font(.system(size: 12))
        }
    }
    
    func counterToMinutes() -> String {
        let currentTime = countTo - counter
        let seconds = currentTime % 60
        return "\(seconds < 10 ? "0" : "")\(seconds)"
    }
}


var timer = Timer
    .publish(every: 1, on: .main, in: .common)
    .autoconnect()

struct ProgressTrack: View {
    var body: some View {
        Circle()
            .fill(Color.clear)
            .frame(width: tam, height: tam)
            .overlay(
                Circle().stroke(Color.clear, lineWidth: 4)
        )
    }
}

struct ProgressBar: View {
    var counter: Int
    var countTo: Int
    
    var body: some View {
        Circle()
            .fill(Color.clear)
            .frame(width: tam, height: tam)
            .overlay(
                Circle().trim(from:0, to: progress())
                    .stroke(
                        style: StrokeStyle(
                            lineWidth: 5,
                            lineCap: .round,
                            lineJoin:.round
                        )
                    )
                    .foregroundColor(
                        (completed() ? Color.red : Color.green)
                    ).animation(
                    .easeInOut(duration: 0.2), value: progress()
                    )
                    .rotationEffect(.degrees(-90))
            )
    }
    
    func completed() -> Bool {
        return progress() == 1
    }
    
    func progress() -> CGFloat {
        return (CGFloat(counter) / CGFloat(countTo))
    }
}

struct TimerView: View {
    @Binding var counter: Int
    let countTo: Int
    let onEnding: () -> Void

    var timer = Timer
        .publish(every: 1, on: .main, in: .common)
        .autoconnect()

    var body: some View {
        VStack{
            ZStack{
                ProgressTrack()
                ProgressBar(counter: counter, countTo: countTo)
                Clock(counter: counter, countTo: countTo)
            }
        }.onReceive(timer) { time in
            if (self.counter < self.countTo) {
                self.counter += 1
            }else{
                counter = countTo
                timer.upstream.connect().cancel()
                onEnding()
            }
        }
    }
}
