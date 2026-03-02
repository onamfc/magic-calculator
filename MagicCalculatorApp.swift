import SwiftUI

@main
struct MagicCalculatorApp: App {
    var body: some Scene {
        WindowGroup {
            CalculatorView()
                .preferredColorScheme(.dark)
                .persistentSystemOverlays(.hidden)
        }
    }
}
