import SwiftUI

@main
struct TheGridBlackoutCityApp: App {
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var viewModel = GameViewModel()

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .environmentObject(viewModel)
                .preferredColorScheme(.dark)
                .onChange(of: scenePhase) { _, newPhase in
                    if newPhase != .active {
                        viewModel.saveForScenePhaseChange()
                    }
                }
        }
    }
}
