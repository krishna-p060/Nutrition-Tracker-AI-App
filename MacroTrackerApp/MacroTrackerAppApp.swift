

import SwiftUI
import SwiftData

@main
struct MacroTrackerAppApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Macro.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            MacroView()
        }
        .modelContainer(sharedModelContainer)
    }
//    var body: some Scene {
//        WindowGroup {
//            ContentView()
//        }
//    }
}
