import UIKit
import AVFoundation

class MyVisionViewController: UIViewController {
    
    @IBOutlet weak var cameraPreview: UIView!
    @IBOutlet weak var takePictureButton: UIButton!

    private let captureSession = AVCaptureSession()
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private let photoOutput = AVCapturePhotoOutput()

    private var overlayView: OverlayMaskView?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
    }
    
    private func setupCamera() {
        captureSession.sessionPreset = .photo
        
        guard let backCamera = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: backCamera),
              captureSession.canAddInput(input),
              captureSession.canAddOutput(photoOutput) else {
            print("Error setting up camera input/output")
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
        // Create overlay programmatically
        let overlay = OverlayMaskView(frame: view.bounds)
        overlay.backgroundColor = .clear
        self.view.addSubview(overlay)
        self.view.bringSubviewToFront(takePictureButton) // keep button above overlay
        
        self.overlayView = overlay
    }

    @IBAction func takePictureTapped(_ sender: UIButton) {
        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
}

extension MyVisionViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let imageData = photo.fileDataRepresentation(),
           let image = UIImage(data: imageData) {
            print("Picture taken!")
        }
    }
}
