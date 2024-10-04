
import SwiftUI

@MainActor
struct ContentView: View {

    @State private var permission = AudioRecordingPermission()

    var body: some View {
        VStack {
            switch permission.status {
                case .unknown, .denied:
                    Text("System Audio permissions")
                        .bold()
                        .font(.title2)
                    Button("Open System Settings") {
                        NSWorkspace.shared.openSystemSettings()
                    }
                case .authorized:
                    ProcessSelectionView()
                        .frame(alignment: .topLeading)
            }
        }
        .frame(width: 500, height: 200, alignment: .center)
        .padding()
        .onAppear(perform: setup)
    }

    private func setup() {
        if permission.status != .authorized {
            permission.request()
        }
    }
}

extension NSWorkspace {
    func openSystemSettings() {
        guard let url = urlForApplication(withBundleIdentifier: "com.apple.systempreferences") else {
            assertionFailure("System Settings missing")
            return
        }

        openApplication(at: url, configuration: .init())
    }
}

#if DEBUG
#Preview {
    ContentView()
}
#endif
