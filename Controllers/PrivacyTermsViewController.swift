import UIKit

class PrivacyTermsViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // ضبط حجم المحتوى داخل UIScrollView
        scrollView.contentSize = CGSize(width: scrollView.frame.width, height: contentView.frame.height)
    }
}
