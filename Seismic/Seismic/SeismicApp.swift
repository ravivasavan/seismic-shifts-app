import SwiftUI

@main
struct SeismicApp: App {
    @StateObject private var audio = AudioMonitor()
    @StateObject private var buffer = TraceBuffer(width: 2732)

    var body: some Scene {
        WindowGroup {
            TraceView(buffer: buffer)
                .ignoresSafeArea()
                .statusBar(hidden: true)
                .persistentSystemOverlays(.hidden)
                .onAppear {
                    UIApplication.shared.isIdleTimerDisabled = true
                    try? audio.start()
                }
                .onReceive(audio.$currentEnergy) { value in
                    buffer.ingest(value)
                }
        }
    }
}
