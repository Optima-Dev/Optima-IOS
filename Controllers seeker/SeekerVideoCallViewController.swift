import UIKit

class SeekerVideoCallViewController: UIViewController {

    // MARK: - IBOutlets

    @IBOutlet weak var videoContainerView: UIView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var flipCameraButton: UIButton!
    @IBOutlet weak var endCallButton: UIButton!

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        addBlurEffect()
    }

    // MARK: - UI Setup

    private func setupUI() {
        flipCameraButton.layer.cornerRadius = 8
        endCallButton.layer.cornerRadius = 8
    }

    private func addBlurEffect() {
        let blurEffect = UIBlurEffect(style: .dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = videoContainerView.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurEffectView.tag = 1001
        videoContainerView.addSubview(blurEffectView)

        videoContainerView.bringSubviewToFront(statusLabel)
    }

    // MARK: - Handle Helper Joined

    func handleHelperJoined() {
        if let blurView = videoContainerView.viewWithTag(1001) {
            blurView.removeFromSuperview()
        }
        statusLabel.isHidden = true
    }

    // MARK: - IBActions

    @IBAction func flipCameraTapped(_ sender: UIButton) {
        print("Flip camera tapped")
    }

    @IBAction func endCallTapped(_ sender: UIButton) {
        print("End call tapped")
        self.dismiss(animated: true, completion: nil)
    }
}
