import UIKit

class VoiceControlViewController: SeekerBaseViewController  {

    // MARK: - Outlets
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!

    @IBOutlet weak var commandView1: UIView!
    @IBOutlet weak var commandView2: UIView!
    @IBOutlet weak var commandView3: UIView!
    @IBOutlet weak var commandView4: UIView!
    @IBOutlet weak var commandView5: UIView!
    @IBOutlet weak var commandView6: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()

        scrollView.contentSize = CGSize(width: scrollView.frame.width, height: contentView.frame.height)

        setupBackgroundImage()
        applyStyles(to: [
            commandView1,
            commandView2,
            commandView3,
            commandView4,
            commandView5,
            commandView6
        ])

        setupSwipeGesture()
    }

    // MARK: - Background Image Setup
    private func setupBackgroundImage() {
        let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
        backgroundImage.image = UIImage(named: "Background")
        backgroundImage.contentMode = .scaleAspectFill
        view.insertSubview(backgroundImage, at: 0)
    }

    // MARK: - Apply Styles to Views
    private func applyStyles(to views: [UIView]) {
        for view in views {
            view.backgroundColor = UIColor(red: 203/255, green: 203/255, blue: 203/255, alpha: 1.0) // #CBCBCB
            view.layer.cornerRadius = 20
            view.clipsToBounds = true
        }
    }

    // MARK: - Swipe Gesture Setup
    private func setupSwipeGesture() {
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeRight))
        swipeRight.direction = .right
        view.addGestureRecognizer(swipeRight)
    }

    @objc private func handleSwipeRight() {
        print("Voice activated by swipe 👉")
        showListeningBanner()
        VoiceCommandManager.shared.startListening(in: self)
        AudioFeedback.shared.vibrateLight()
    }

    // MARK: - Show Listening Banner
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

        banner.frame = CGRect(
            x: 20,
            y: -bannerHeight,
            width: self.view.frame.width - 40,
            height: bannerHeight
        )

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
