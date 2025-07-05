import UIKit

class SeekerBaseViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupVoiceSwipeGesture()
    }

    private func setupVoiceSwipeGesture() {
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(startVoiceCommands))
        swipeRight.direction = .right
        swipeRight.cancelsTouchesInView = false 
        view.addGestureRecognizer(swipeRight)
    }

    @objc private func startVoiceCommands() {
        print("👉 Swipe detected. Voice Commands starting...")
        VoiceCommandManager.shared.startListening(in: self)
        AudioFeedback.shared.vibrateLight()
        showListeningBanner()
    }

    private func showListeningBanner() {
        let bannerHeight: CGFloat = 50
        let banner = UILabel()
        banner.text = "Listening..."
        banner.textAlignment = .center
        banner.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        banner.textColor = .white
        banner.layer.cornerRadius = 12
        banner.layer.masksToBounds = true
        banner.font = UIFont.systemFont(ofSize: 16, weight: .medium)

        banner.frame = CGRect(x: 20, y: -bannerHeight, width: self.view.frame.width - 40, height: bannerHeight)
        banner.alpha = 0
        view.addSubview(banner)

        UIView.animate(withDuration: 0.4, animations: {
            banner.frame.origin.y = 60
            banner.alpha = 1
        }) { _ in
            UIView.animate(withDuration: 0.4, delay: 1.5, options: [], animations: {
                banner.frame.origin.y = -bannerHeight
                banner.alpha = 0
            }, completion: { _ in
                banner.removeFromSuperview()
            })
        }
    }
}
