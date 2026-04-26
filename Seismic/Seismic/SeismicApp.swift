import SwiftUI

@main
struct SeismicApp: App {
    var body: some Scene {
        WindowGroup {
            SeismicView()
                .ignoresSafeArea()
                .statusBar(hidden: true)
                .persistentSystemOverlays(.hidden)
                .onAppear {
                    UIApplication.shared.isIdleTimerDisabled = true
                }
        }
    }
}
