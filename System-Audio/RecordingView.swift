
import SwiftUI

@MainActor
struct RecordingView: View {

    let recorder: ProcessTapRecorder

    @State private var lastRecordingURL: URL?

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                RecordingIndicator(appIcon: recorder.process.icon, isRecording: recorder.isRecording)
                Text(recorder.isRecording ? "Recording from \(recorder.process.name)" : "Ready for \(recorder.process.name)")
                    .font(.headline)
                    .contentTransition(.identity)
            }

            HStack {
                Button(recorder.isRecording ? "Stop" : "Start") {
                    if recorder.isRecording {
                        recorder.stop()
                    } else {
                        do {
                            try recorder.start()
                        } catch { NSAlert(error: error).runModal() }
                    }
                }
                .padding(.trailing, 10)

                if let lastRecordingURL {
                    FileProxyView(url: lastRecordingURL)
                        .transition(.scale.combined(with: .opacity))
                }
            }
        }
        .animation(.smooth, value: recorder.isRecording)
        .animation(.smooth, value: lastRecordingURL)
        .onChange(of: recorder.isRecording) { _, newValue in
            if !newValue { lastRecordingURL = recorder.fileURL }
        }
    }
}
