import UIKit

extension UIButton {
    func applyCustomStyle(title: String, borderColor: UIColor) {
        self.layer.cornerRadius = 12
        self.layer.masksToBounds = true
        self.layer.borderWidth = 2
        self.layer.borderColor = borderColor.cgColor
        self.backgroundColor = .white
        
        self.setAttributedTitle(NSAttributedString(
            string: title,
            attributes: [
                .font: UIFont.systemFont(ofSize: 20, weight: .bold),
                .foregroundColor: borderColor
            ]
        ), for: .normal)

        self.contentHorizontalAlignment = .left
        self.contentEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
        
        self.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.bottomAnchor.constraint(equalTo: self.superview!.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            self.trailingAnchor.constraint(equalTo: self.superview!.trailingAnchor, constant: -20),
            self.widthAnchor.constraint(equalToConstant: 180),
            self.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
}
