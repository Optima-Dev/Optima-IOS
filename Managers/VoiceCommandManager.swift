import Foundation
import Speech
import AVFoundation
import UIKit

class VoiceCommandManager: NSObject, SFSpeechRecognizerDelegate {

    static let shared = VoiceCommandManager()

    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()

    private override init() {
        super.init()
        speechRecognizer?.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(stopListening), name: UIApplication.willResignActiveNotification, object: nil)
    }

    func startListening(in viewController: UIViewController) {
        guard isUserSeeker(from: viewController) else {
            return
        }

        SFSpeechRecognizer.requestAuthorization { authStatus in
            if authStatus == .authorized {
                self.startRecording(in: viewController)
            }
        }
    }

    @objc func stopListening() {
        audioEngine.stop()
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
    }

    private func startRecording(in viewController: UIViewController) {
        stopListening()

        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let request = recognitionRequest else { return }

        let inputNode = audioEngine.inputNode
        let format = inputNode.outputFormat(forBus: 0)
        inputNode.removeTap(onBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { buffer, _ in
            request.append(buffer)
        }

        audioEngine.prepare()
        try? audioEngine.start()

        recognitionTask = speechRecognizer?.recognitionTask(with: request) { result, error in
            if let result = result {
                let command = result.bestTranscription.formattedString.lowercased()
                self.handleCommand(command, in: viewController)
            }

            if error != nil || (result?.isFinal ?? false) {
                self.stopListening()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    self.startListening(in: viewController)
                }
            }
        }
    }

    private func handleCommand(_ command: String, in viewController: UIViewController) {
        switch command {
        case let str where str.contains("open my vision"):
            presentViewController(withIdentifier: "MyVisionViewController", from: viewController)
        case let str where str.contains("open my people"):
            presentViewController(withIdentifier: "MyPeopleViewController", from: viewController)
        case let str where str.contains("open support"):
            presentViewController(withIdentifier: "SupportSeekerViewController", from: viewController)
        case let str where str.contains("open settings"):
            presentViewController(withIdentifier: "SettingForBlindViewController", from: viewController)
        case let str where str.contains("take a picture"):
            (viewController as? MyVisionViewController)?.captureImage()
        case let str where str.contains("repeat"):
            (viewController as? MyVisionViewController)?.repeatResult()
        default:
            break
        }
    }

    private func presentViewController(withIdentifier identifier: String, from viewController: UIViewController) {
        guard let tabBarController = viewController.tabBarController else { return }
        for vc in tabBarController.viewControllers ?? [] {
            if vc.restorationIdentifier == identifier {
                tabBarController.selectedViewController = vc
                return
            }
        }
    }

    private func isUserSeeker(from viewController: UIViewController) -> Bool {
        return viewController is SupportSeekerViewController
    }
}
