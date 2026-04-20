import SwiftUI
import Speech
import AVFoundation

struct DictationButton: View {
    @Binding var text: String

    // Public customization
    var title: String = "Dictate"
    var cornerRadius: CGFloat = 12

    // Internal state
    @State private var isRecording = false
    @State private var speechRecognizer = SFSpeechRecognizer()
    @State private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    @State private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()

    var body: some View {
        Button(action: toggleRecording) {
            HStack(spacing: 8) {
                Image(systemName: isRecording ? "mic.fill" : "mic")
                    .symbolEffect(.pulse.byLayer)
                Text(isRecording ? "Listening…" : title)
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .padding(.horizontal)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(isRecording ? Color.red.opacity(0.2) : Color.accentColor.opacity(0.15))
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(isRecording ? Color.red : Color.accentColor, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .disabled(!isSpeechAvailable)
        .task {
            // Pre-warm authorization on appearance
            _ = await requestSpeechAuthorizationIfNeeded()
        }
        .onDisappear {
            stopRecordingIfNeeded()
        }
    }

    private var isSpeechAvailable: Bool {
        speechRecognizer?.isAvailable ?? false
    }

    private func toggleRecording() {
        if isRecording {
            stopRecordingIfNeeded()
        } else {
            Task { await startRecording() }
        }
    }

    private func requestSpeechAuthorizationIfNeeded() async -> Bool {
        let status = SFSpeechRecognizer.authorizationStatus()
        if status == .authorized { return true }
        return await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { newStatus in
                continuation.resume(returning: newStatus == .authorized)
            }
        }
    }

    private func startRecording() async {
        // Request permissions
        guard await requestSpeechAuthorizationIfNeeded() else { return }
        switch AVAudioSession.sharedInstance().recordPermission {
        case .granted: break
        case .denied: return
        case .undetermined:
            let granted = await withCheckedContinuation { (continuation: CheckedContinuation<Bool, Never>) in
                AVAudioSession.sharedInstance().requestRecordPermission { ok in
                    continuation.resume(returning: ok)
                }
            }
            guard granted else { return }
        @unknown default: break
        }

        // Stop any existing task
        stopRecordingIfNeeded()

        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            return
        }

        let request = SFSpeechAudioBufferRecognitionRequest()
        request.shouldReportPartialResults = true
        self.recognitionRequest = request

        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.removeTap(onBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            request.append(buffer)
        }

        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            stopRecordingIfNeeded()
            return
        }

        isRecording = true

        recognitionTask = speechRecognizer?.recognitionTask(with: request) { result, error in
            if let result = result {
                // Update text with partial results
                self.text = result.bestTranscription.formattedString
            }
            if error != nil || (result?.isFinal ?? false) {
                stopRecordingIfNeeded()
            }
        }
    }

    private func stopRecordingIfNeeded() {
        guard isRecording || recognitionTask != nil else { return }
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        recognitionTask = nil
        recognitionRequest = nil
        isRecording = false
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }
}

#Preview {
    @Previewable @State var text = ""
    VStack(spacing: 16) {
        Text(text).padding().background(.thinMaterial).clipShape(RoundedRectangle(cornerRadius: 12))
        DictationButton(text: $text)
    }
    .padding()
}
