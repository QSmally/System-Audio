
import SwiftUI

@MainActor
struct ProcessSelectionView: View {

    @State private var processController = AudioProcessController()
    @State private var presentSelector = false

    @State private var tap: ProcessTap?
    @State private var recorder: ProcessTapRecorder?
    @State private var processSelected: AudioProcess?

    var body: some View {
        HStack {
            Button(action: {
                presentSelector.toggle()
            }) {
                VStack {
                    icon
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 64, height: 64)
                    Text(processSelected?.name ?? "Select...")
                }
                .frame(width: 80, height: 100)
                .padding()
            }
            .popover(isPresented: $presentSelector) {
                ScrollView {
                    ForEach(processController.processes) { process in
                        Button(action: {
                            processSelected = process
                            presentSelector = false
                        }) {
                            HStack {
                                Image(nsImage: process.icon)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 32, height: 32)
                                Text(process.name)
                                Spacer()
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .padding()
                }
                .frame(minWidth: 85, maxHeight: 200)
                .presentationCompactAdaptation(.popover)
            }
            .disabled(recorder?.isRecording == true)
            .padding(.horizontal)

            Divider()

            if let tap {
                if let errorMessage = tap.errorMessage {
                    Text(errorMessage)
                        .font(.headline)
                        .foregroundStyle(.red)
                } else if let recorder {
                    RecordingView(recorder: recorder)
                        .onChange(of: recorder.isRecording) { wasRecording, isRecording in
                            if wasRecording, !isRecording {
                                createRecorder()
                            }
                        }
                }
            }

            Spacer()
        }
        .task { processController.activate() }
        .onChange(of: processSelected) { oldValue, newValue in
            guard newValue != oldValue else { return }

            if let newValue {
                setupRecording(for: newValue)
            } else if oldValue == tap?.process {
                teardownTap()
            }
        }
    }

    var icon: Image {
        if let icon = processSelected?.icon {
            Image(nsImage: icon)
        } else {
            Image(systemName: "camera.metering.unknown")
        }
    }

    private func setupRecording(for process: AudioProcess) {
        let newTap = ProcessTap(process: process)
        self.tap = newTap
        newTap.activate()

        createRecorder()
    }

    private func createRecorder() {
        guard let tap else { return }

        let filename = "\(tap.process.name)-\(Int(Date.now.timeIntervalSinceReferenceDate))"
        let audioFileURL = URL.applicationSupport.appendingPathComponent(filename, conformingTo: .wav)
        let newRecorder = ProcessTapRecorder(fileURL: audioFileURL, tap: tap)

        self.recorder = newRecorder
    }

    private func teardownTap() {
        tap = nil
    }
}

extension URL {
    static var applicationSupport: URL {
        do {
            let appSupport = try FileManager.default.url(
                for: .applicationSupportDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: false)
            let application = appSupport.appending(
                path: appString,
                directoryHint: .isDirectory)
            if !FileManager.default.fileExists(atPath: application.path) {
                try FileManager.default.createDirectory(at: application, withIntermediateDirectories: true)
            }

            return application
        } catch {
            assertionFailure("Application Support missing: \(error)")
            return FileManager.default.temporaryDirectory
        }
    }
}
