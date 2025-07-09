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
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(stopListening),
            name: UIApplication.willResignActiveNotification,
            object: nil
        )
    }

    func startListening(in viewController: UIViewController) {
        guard isUserSeeker(from: viewController) else { return }

        SFSpeechRecognizer.requestAuthorization { authStatus in
            if authStatus == .authorized {
                DispatchQueue.main.async {
                    self.startRecording(in: viewController)
                }
            } else {
                print("Speech recognition not authorized ❌")
            }
        }
    }

    @objc func stopListening() {
        if audioEngine.isRunning {
            audioEngine.stop()
            audioEngine.inputNode.removeTap(onBus: 0)
        }
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        recognitionTask = nil
    }

    private func startRecording(in viewController: UIViewController) {
        stopListening()

        if audioEngine.isRunning {
            print("Audio engine already running – skipping restart 🚫")
            return
        }

        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let request = recognitionRequest else { return }

        let inputNode = audioEngine.inputNode
        let format = inputNode.outputFormat(forBus: 0)
        inputNode.removeTap(onBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { buffer, _ in
            request.append(buffer)
        }

        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            print("❌ Failed to start audio engine: \(error.localizedDescription)")
            return
        }

        recognitionTask = speechRecognizer?.recognitionTask(with: request) { result, error in
            if let result = result {
                let command = result.bestTranscription.formattedString.lowercased()
                let didHandle = self.handleCommand(command, in: viewController)

                if didHandle {
                    self.stopListening()
                }
            }

            if error != nil {
                self.stopListening()
            }
        }
    }

    private func handleCommand(_ command: String, in viewController: UIViewController) -> Bool {
        switch command {
        case let str where str.contains("open my vision"):
            presentViewController(withIdentifier: "MyVisionViewController", from: viewController)
            AudioFeedback.shared.vibrateLight()
            return true

        case let str where str.contains("open my people"):
            presentViewController(withIdentifier: "MyPeopleViewController", from: viewController)
            AudioFeedback.shared.vibrateLight()
            return true

        case let str where str.contains("open support"):
            presentViewController(withIdentifier: "SupportSeekerViewController", from: viewController)
            AudioFeedback.shared.vibrateLight()
            return true

        case let str where str.contains("open settings"):
            presentViewController(withIdentifier: "SettingForBlindViewController", from: viewController)
            AudioFeedback.shared.vibrateLight()
            return true

        case let str where str.contains("take a picture"):
            (viewController as? MyVisionViewController)?.captureImage()
            AudioFeedback.shared.vibrateMedium()
            return true

        case let str where str.contains("repeat"):
            (viewController as? MyVisionViewController)?.repeatResult()
            AudioFeedback.shared.vibrateLight()
            return true

        case let str where str.contains("call a volunteer"):
            (viewController as? SupportSeekerViewController)?.callAVolunteerTapped(UIButton())
            AudioFeedback.shared.vibrateMedium()
            return true

        case let str where str.contains("call"):
            if let myPeopleVC = viewController as? MyPeopleViewController {
                let words = str.components(separatedBy: " ")
                if let nameIndex = words.firstIndex(of: "call"), nameIndex + 1 < words.count {
                    let name = words[nameIndex + 1].lowercased()

                    if let friend = myPeopleVC.friends.first(where: {
                        $0.firstName.lowercased() == name || $0.lastName.lowercased() == name
                    }) {
                        myPeopleVC.selectedFriend = friend
                        myPeopleVC.callButtonTapped(UIButton())
                        AudioFeedback.shared.vibrateMedium()
                        return true
                    }
                }
            }
            return false

        default:
            return false
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
        return viewController is SeekerBaseViewController
    }
}
