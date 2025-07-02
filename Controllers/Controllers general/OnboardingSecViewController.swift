import UIKit

class OnboardingSecViewController: UIViewController {
    
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var nextButton: UIButton!
    
    @IBAction func nextButtonTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let nextVC = storyboard.instantiateViewController(withIdentifier: "OnboardingThirdViewController") as? OnboardingThirdViewController {
            navigationController?.pushViewController(nextVC, animated: true)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setLineSpacing(for: descriptionLabel, lineSpacing: 6)
        styleNextButton()
    }

    func setLineSpacing(for label: UILabel, lineSpacing: CGFloat) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineSpacing

        let attributedString = NSMutableAttributedString(string: label.text ?? "")
        attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: attributedString.length))

        label.attributedText = attributedString
    }

    func styleNextButton() {
        let borderColor = UIColor(red: 39/255, green: 39/255, blue: 196/255, alpha: 1)
        
        nextButton.layer.cornerRadius = 12
        nextButton.layer.masksToBounds = true
        nextButton.layer.borderWidth = 2
        nextButton.layer.borderColor = borderColor.cgColor
        nextButton.backgroundColor = .white
        
        nextButton.setAttributedTitle(NSAttributedString(
            string: "NEXT",
            attributes: [
                .font: UIFont.systemFont(ofSize: 20, weight: .bold),
                .foregroundColor: borderColor
            ]
        ), for: .normal)

        nextButton.contentHorizontalAlignment = .left
        nextButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
    }
}
