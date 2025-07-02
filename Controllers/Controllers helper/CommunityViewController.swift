import UIKit

class CommunityViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!

    @IBOutlet weak var articleView1: UIView!
    @IBOutlet weak var articleView2: UIView!
    @IBOutlet weak var articleView3: UIView!
    @IBOutlet weak var articleView4: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()

        scrollView.contentSize = CGSize(width: scrollView.frame.width, height: contentView.frame.height)

        setupBackgroundImage()
        
        applyImageBackground(to: [articleView2, articleView4], imageName: "Article")
    }

    // MARK: - Background
    private func setupBackgroundImage() {
        let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
        backgroundImage.image = UIImage(named: "Background")
        backgroundImage.contentMode = .scaleAspectFill
        view.insertSubview(backgroundImage, at: 0)
    }

   

    private func applyImageBackground(to views: [UIView], imageName: String) {
        for view in views {
            view.backgroundColor = .clear
            let bgImage = UIImageView(frame: view.bounds)
            bgImage.image = UIImage(named: imageName)
            bgImage.contentMode = .scaleAspectFill
            bgImage.clipsToBounds = true
            bgImage.layer.cornerRadius = 20
            bgImage.translatesAutoresizingMaskIntoConstraints = false
            view.insertSubview(bgImage, at: 0)

            // Match image to view's size
            NSLayoutConstraint.activate([
                bgImage.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                bgImage.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                bgImage.topAnchor.constraint(equalTo: view.topAnchor),
                bgImage.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
        }
    }
}
