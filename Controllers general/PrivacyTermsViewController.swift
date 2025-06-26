import UIKit
import AVFoundation
import Speech

class PrivacyTermsViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var warningPopupView: UIView! // The warning popup itself

    override func viewDidLoad() {
        super.viewDidLoad()

        scrollView.contentSize = CGSize(width: scrollView.frame.width, height: contentView.frame.height)
        warningPopupView.isHidden = true

        if arePermissionsGranted() {
            self.navigateToLogin()
        }
    }

    @IBAction func agreeButtonTapped(_ sender: UIButton) {
        showCameraPermissionAlert()
    }

    // MARK: - Step 1: Ask for Camera Permission
    func showCameraPermissionAlert() {
        let alert = UIAlertController(
            title: "Camera Access",
            message: "Optima needs access to your **camera** to help you capture images .",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Allow", style: .default) { _ in
            self.requestCameraPermission()
        })

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        self.present(alert, animated: true, completion: nil)
    }

    func requestCameraPermission() {
        AVCaptureDevice.requestAccess(for: .video) { cameraGranted in
            DispatchQueue.main.async {
                if cameraGranted {
                    self.showMicrophonePermissionAlert()
                } else {
                    print("Camera permission denied.")
                    self.showWarningPopup()
                }
            }
        }
    }

    // MARK: - Step 2: Ask for Microphone Permission
    func showMicrophonePermissionAlert() {
        let alert = UIAlertController(
            title: "Microphone Access",
            message: "Optima needs access to your **microphone** so you can talk during support video calls.",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Allow", style: .default) { _ in
            self.requestMicrophonePermission()
        })

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        self.present(alert, animated: true, completion: nil)
    }

    func requestMicrophonePermission() {
        let audioSession = AVAudioSession.sharedInstance()
        audioSession.requestRecordPermission { microphoneGranted in
            DispatchQueue.main.async {
                if microphoneGranted {
                    self.showSpeechRecognitionAlert()
                } else {
                    print("Microphone permission denied.")
                    self.showWarningPopup()
                }
            }
        }
    }

    // MARK: - Step 3: Ask for Speech Recognition Permission
    func showSpeechRecognitionAlert() {
        let alert = UIAlertController(
            title: "Voice Command Access",
            message: "Optima needs access to **Speech Recognition** so you can control the app with your voice.",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Allow", style: .default) { _ in
            self.requestSpeechPermission()
        })

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        self.present(alert, animated: true, completion: nil)
    }

    func requestSpeechPermission() {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            DispatchQueue.main.async {
                if authStatus == .authorized {
                    self.storePermissionsGranted()
                    self.navigateToLogin()
                } else {
                    print("Speech recognition permission denied.")
                    self.showWarningPopup()
                }
            }
        }
    }

    // MARK: - Navigation
    func navigateToLogin() {
        DispatchQueue.main.async {
            if let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") {
                loginVC.modalPresentationStyle = .fullScreen
                self.present(loginVC, animated: true, completion: nil)
            } else {
                print("❌ LoginViewController not found in storyboard.")
            }
        }
    }

    func storePermissionsGranted() {
        UserDefaults.standard.set(true, forKey: "permissionsGranted")
    }

    func arePermissionsGranted() -> Bool {
        return UserDefaults.standard.bool(forKey: "permissionsGranted")
    }

    func showWarningPopup() {
        DispatchQueue.main.async {
            self.warningPopupView.isHidden = false
        }
    }
}
