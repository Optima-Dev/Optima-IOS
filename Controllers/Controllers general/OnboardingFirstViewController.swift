//
//  OnboardingFirstViewController.swift
//  Optima
//
//  Created by Ghada Abdelrahman on 18/02/2025.
//
import UIKit

class OnboardingFirstViewController: UIViewController {
    
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var nextButton: UIButton!
    @IBAction func nextButtonTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let nextVC = storyboard.instantiateViewController(withIdentifier: "OnboardingSecViewController") as? OnboardingSecViewController {
                navigationController?.pushViewController(nextVC, animated: true)
        }
    }

    @IBAction func skipButtonTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let lastVC = storyboard.instantiateViewController(withIdentifier: "OnboardingThirdViewController") as? OnboardingThirdViewController {
                navigationController?.pushViewController(lastVC, animated: true)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //  for line spacing
        setLineSpacing(for: descriptionLabel, lineSpacing: 6)
        
        // for rounded button
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
        let borderColor = UIColor(red: 39/255, green: 39/255, blue: 196/255, alpha: 1) // #2727C4
        
        nextButton.layer.cornerRadius = 12
        nextButton.layer.masksToBounds = true
        nextButton.layer.borderWidth = 2
        nextButton.layer.borderColor = borderColor.cgColor
        nextButton.backgroundColor = .white // يجعل الخلفية بيضاء مثل Figma
        
        nextButton.setTitle("NEXT", for: .normal)
        nextButton.setTitleColor(borderColor, for: .normal)
        nextButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        
        nextButton.setAttributedTitle(NSAttributedString(
            string: "NEXT",
            attributes: [
                .font: UIFont.systemFont(ofSize: 20, weight: .bold),
                .foregroundColor: UIColor(red: 39/255, green: 39/255, blue: 196/255, alpha: 1) // #2727C4
            ]
        ), for: .normal)
        // محاذاة النص لليسار
        nextButton.contentHorizontalAlignment = .left
        nextButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
    }
}
