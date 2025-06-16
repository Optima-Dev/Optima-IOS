import UIKit
import AVFoundation

class MyVisionViewController: UIViewController {

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

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
        configureInitialUI()
        synthesizer.delegate = self
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
        takePicture()
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
        isSpeaking = true
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        synthesizer.speak(utterance)
    }
}

// MARK: - AVCapture Delegate

extension MyVisionViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let imageData = photo.fileDataRepresentation(),
           let image = UIImage(data: imageData) {

            // Show loader
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
