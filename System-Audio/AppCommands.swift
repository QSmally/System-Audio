
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
            Button("Foo") {
                print("bar")
            }
        }
    }
}
