import UIKit

class VoiceControlViewController: UIViewController {

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

        // Set scroll view content size to match content view
        scrollView.contentSize = CGSize(width: scrollView.frame.width, height: contentView.frame.height)

        // Set up background image
        setupBackgroundImage()

        // Apply styles to the 6 command views
        applyStyles(to: [
            commandView1,
            commandView2,
            commandView3,
            commandView4,
            commandView5,
            commandView6
        ])
    }

    // MARK: - Background Image Setup
    private func setupBackgroundImage() {
        let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
        backgroundImage.image = UIImage(named: "Background")
        backgroundImage.contentMode = .scaleAspectFill

        // Insert background behind all views
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
}
