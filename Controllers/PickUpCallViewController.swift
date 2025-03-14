//
//  PickUpCallViewController.swift
//  Optima
//
//  Created by Ghada Abdelrahman on 14/03/2025.
//

import UIKit

class PickUpCallViewController: UIViewController {
    // MARK: - Outlets
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    // Connect your UIViews here
    @IBOutlet weak var myView1: UIView!
    @IBOutlet weak var myView2: UIView!
    @IBOutlet weak var myView3: UIView!
    @IBOutlet weak var myView4: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

            // Set the scroll view content size
            scrollView.contentSize = CGSize(width: scrollView.frame.width, height: contentView.frame.height)
            
            // Set up the background image
            setupBackgroundImage()
            
            // Apply styles to all UIViews
            applyStyles(to: [myView1, myView2, myView3, myView4])
        }
        
        // MARK: - Background Image Setup
        private func setupBackgroundImage() {
            let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
            backgroundImage.image = UIImage(named: "Background")
            backgroundImage.contentMode = .scaleAspectFill
            
            // Insert the background image at the bottom layer
            view.insertSubview(backgroundImage, at: 0)
        }
        
        // MARK: - Apply Styles to UIViews
        private func applyStyles(to views: [UIView]) {
            for view in views {
                view.layer.borderColor = UIColor(hex: "#2727BB").cgColor
                view.layer.borderWidth = 2 // Border width
                view.layer.cornerRadius = 24 // Rounded corners
                view.clipsToBounds = true // Clip to bounds
            }
        }
    }

    // MARK: - UIColor Extension for Hex Support
extension UIColor {
    convenience init(hexString: String, alpha: CGFloat = 1.0) {
        var hexFormatted: String = hexString.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if hexFormatted.hasPrefix("#") {
            hexFormatted = String(hexFormatted.dropFirst())
        }

        var rgbValue: UInt64 = 0
        Scanner(string: hexFormatted).scanHexInt64(&rgbValue)

        self.init(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: alpha
        )
    }
}
    
