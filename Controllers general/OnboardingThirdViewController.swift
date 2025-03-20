import UIKit

class OnboardingThirdViewController: UIViewController {
    
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    
    @IBAction func startButtonTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let chooseRoleVC = storyboard.instantiateViewController(withIdentifier: "ChooseRoleViewController") as? ChooseRoleViewController {
            navigationController?.pushViewController(chooseRoleVC, animated: true)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setLineSpacing(for: descriptionLabel, lineSpacing: 6)
        styleStartButton()
    }

    func setLineSpacing(for label: UILabel, lineSpacing: CGFloat) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineSpacing

        let attributedString = NSMutableAttributedString(string: label.text ?? "")
        attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: attributedString.length))

        label.attributedText = attributedString
    }

    func styleStartButton() {
        let borderColor = UIColor(red: 39/255, green: 39/255, blue: 196/255, alpha: 1)
        
        startButton.layer.cornerRadius = 12
        startButton.layer.masksToBounds = true
        startButton.layer.borderWidth = 2
        startButton.layer.borderColor = borderColor.cgColor
        startButton.backgroundColor = .white
        
        startButton.setAttributedTitle(NSAttributedString(
            string: "START",
            attributes: [
                .font: UIFont.systemFont(ofSize: 20, weight: .bold),
                .foregroundColor: borderColor
            ]
        ), for: .normal)

        startButton.contentHorizontalAlignment = .left
        startButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
    }
}
