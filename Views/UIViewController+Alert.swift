import UIKit

extension UIViewController {
    func showAlert(title: String = "Error", message: String, completion: (() -> Void)? = nil) {
        DispatchQueue.main.async {
            // ✅ Ensure that no alert is already presented
            if self.presentedViewController is UIAlertController { return }
            
            let alert = UIAlertController(
                title: title,
                message: message,
                preferredStyle: .alert
            )
            
            alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                completion?()
            })
            
            self.present(alert, animated: true)
        }
    }
}
