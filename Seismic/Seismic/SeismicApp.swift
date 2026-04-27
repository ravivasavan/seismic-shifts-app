import SwiftUI

@main
struct SeismicApp: App {
    @State private var launchComplete = false

    var body: some Scene {
        WindowGroup {
            ZStack {
                Theme.paper.ignoresSafeArea()

                if launchComplete {
                    SeismicView()
                        .transition(.opacity)
                } else {
                    LaunchView {
                         withAnimation(.easeOut(duration: 0.45)) {
                            launchComplete = true
                        }
                    }
                    .transition(.opacity)
                }
            }
            .ignoresSafeArea()
            .statusBar(hidden: true)
            .persistentSystemOverlays(.hidden)
            .onAppear {
                UIApplication.shared.isIdleTimerDisabled = true
            }
        }
    }
}
