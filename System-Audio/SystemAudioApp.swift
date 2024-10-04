
import SwiftUI

let appString = "System-Audio"
let appSubsystem = "org.qsmally." + appString

@main
struct System_AudioApp: App {

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .windowStyle(HiddenTitleBarWindowStyle())
        .windowResizability(.contentSize)
        .commandsRemoved()
        .commands { AppCommands() }
    }
}
