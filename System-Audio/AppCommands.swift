
import SwiftUI

struct AppCommands: Commands {

    var body: some Commands {
        CommandMenu("Application") {
            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
            .keyboardShortcut("q", modifiers: .command)
        }

        CommandMenu("Recordings") {
            Button("See previous recordings") {
                NSWorkspace.shared.open(URL.applicationSupport)
            }

            Button("Clear previous recordings") {
                let files = try? FileManager.default.contentsOfDirectory(at: URL.applicationSupport, includingPropertiesForKeys: nil)
                for file in files ?? [] {
                    try? FileManager.default.trashItem(at: file, resultingItemURL: nil)
                }
            }
        }
    }
}
