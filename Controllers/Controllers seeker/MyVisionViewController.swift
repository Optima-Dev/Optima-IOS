import UIKit
import AVFoundation

class MyVisionViewController: SeekerBaseViewController {

    @IBOutlet weak var cameraPreview: UIView!
    @IBOutlet weak var takePictureMainButton: UIButton!
    @IBOutlet weak var repeatButton: UIButton!
    @IBOutlet weak var secondaryTakePicButton: UIButton!
    @IBOutlet weak var resultOverlayView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var resultLabel: UILabel!

    private let captureSession = AVCaptureSession()
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private let photoOutput = AVCapturePhotoOutput()
    private var overlayView: OverlayMaskView?

    private var currentResultText: String?
    private var isSpeaking = false
    private let synthesizer = AVSpeechSynthesizer()
    private var geminiService = VisionGeminiService()

    // ⏳ Used to limit API calls
    private var isWaiting = false

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
        configureInitialUI()
        synthesizer.delegate = self
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        // 🛑 Stop speaking if still active when the view disappears
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
    }

    private func configureInitialUI() {
        takePictureMainButton.isHidden = false
        repeatButton.isHidden = true
        secondaryTakePicButton.isHidden = true
        resultOverlayView.isHidden = true
        activityIndicator.hidesWhenStopped = true
    }

    private func setupCamera() {
        captureSession.sessionPreset = .photo

        guard let backCamera = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: backCamera),
              captureSession.canAddInput(input),
              captureSession.canAddOutput(photoOutput) else {
            print("❌ Error setting up camera input/output")
            return
        }

        captureSession.addInput(input)
        captureSession.addOutput(photoOutput)

        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer?.videoGravity = .resizeAspectFill
        previewLayer?.frame = view.bounds

        if let layer = previewLayer {
            cameraPreview.layer.addSublayer(layer)
        }

        DispatchQueue.global(qos: .userInitiated).async {
            self.captureSession.startRunning()
            DispatchQueue.main.async {
                self.addOverlayMaskView()
            }
        }
    }

    private func addOverlayMaskView() {
        let overlay = OverlayMaskView(frame: view.bounds)
        overlay.backgroundColor = .clear
        self.view.addSubview(overlay)

        self.view.bringSubviewToFront(takePictureMainButton)
        self.view.bringSubviewToFront(repeatButton)
        self.view.bringSubviewToFront(secondaryTakePicButton)
        self.view.bringSubviewToFront(resultOverlayView)

        self.overlayView = overlay
    }

    // MARK: - Button Actions

    @IBAction func takePictureMainTapped(_ sender: UIButton) {
        guard !isWaiting else {
            showWaitAlert()
            return
        }

        isWaiting = true
        takePicture()

        // Reset the waiting flag after 30 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 30.0) {
            self.isWaiting = false
        }
    }

    @IBAction func repeatTapped(_ sender: UIButton) {
        guard let text = currentResultText, !isSpeaking else { return }
        speak(text: text)
    }

    @IBAction func secondaryTakePictureTapped(_ sender: UIButton) {
        resetToInitialState()
    }

    // MARK: - Camera Handling

    private func takePicture() {
        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: self)
    }

    // MARK: - Result & TTS

    private func showResultUI(with result: String) {
        takePictureMainButton.isHidden = true
        resultOverlayView.isHidden = false
        resultLabel.text = result
        currentResultText = result
        repeatButton.isHidden = false
        secondaryTakePicButton.isHidden = false
        speak(text: result)
    }

    private func resetToInitialState() {
        resultOverlayView.isHidden = true
        activityIndicator.stopAnimating()
        resultLabel.text = ""
        currentResultText = nil

        repeatButton.isHidden = true
        secondaryTakePicButton.isHidden = true
        takePictureMainButton.isHidden = false
    }

    private func speak(text: String) {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        isSpeaking = true
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        synthesizer.speak(utterance)
    }

    private func showWaitAlert() {
        let alert = UIAlertController(title: nil, message: "Please wait before taking another picture.", preferredStyle: .alert)
        self.present(alert, animated: true)

        // Dismiss alert automatically after 1.5 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            alert.dismiss(animated: true)
        }
    }

    // MARK: - Voice Command Actions

    func captureImage() {
        print("📸 Voice Command Triggered: Take A Picture")
        takePictureMainTapped(takePictureMainButton)
    }

    func repeatResult() {
        print("🔁 Voice Command Triggered: Repeat")
        guard let text = currentResultText, !isSpeaking else { return }
        speak(text: text)
    }
}

// MARK: - AVCapture Delegate

extension MyVisionViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let imageData = photo.fileDataRepresentation(),
           let image = UIImage(data: imageData) {

            resultOverlayView.isHidden = false
            activityIndicator.startAnimating()
            resultLabel.text = ""

            geminiService.analyzeImage(image) { result in
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    switch result {
                    case .success(let description):
                        self.showResultUI(with: description)
                    case .failure(let error):
                        self.showResultUI(with: "❌ Failed to analyze image: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
}

// MARK: - TTS Delegate

extension MyVisionViewController: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        isSpeaking = false
    }
}
