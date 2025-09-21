import SwiftUI
import Combine

/// Lightweight countdown text that updates at 60s when far from end,
/// and at 1s granularity in the last hour.
struct CountdownText: View {
    let endDate: Date

    @State private var now = Date()
    @Environment(\.scenePhase) private var scenePhase

    private var remaining: TimeInterval { max(0, endDate.timeIntervalSince(now)) }
    // Update every 60s normally, switch to 1s updates in last 10 minutes
    private var tick: TimeInterval { remaining > 600 ? 60 : 1 }

    var body: some View {
        Text(format(remaining: remaining))
            .onReceive(timerPublisher(interval: tick)) { date in
                now = date
            }
            .onChange(of: scenePhase) { _, phase in
                if phase != .active { now = Date() }
            }
            .monospacedDigit()
    }

    private func timerPublisher(interval: TimeInterval) -> Publishers.Autoconnect<Timer.TimerPublisher> {
        Timer.publish(every: interval, on: .main, in: .common).autoconnect()
    }

    private func format(remaining: TimeInterval) -> String {
        let seconds = Int(remaining)
        if seconds <= 0 { return "종료" }
        let d = seconds / 86_400
        let h = (seconds % 86_400) / 3600
        let m = (seconds % 3600) / 60
        let s = seconds % 60
        if d > 0 { return "\(d)일 \(h)시간 \(m)분" }
        if h > 0 { return "\(h)시간 \(m)분" }
        // Under 10 minutes:
        if seconds <= 600 {
            if seconds < 60 {
                return "\(s)초"
            } else {
                return String(format: "%d분 %02d초", m, s)
            }
        }
        return "\(m)분"
    }
}

#Preview { CountdownText(endDate: Date().addingTimeInterval(4000)) }
