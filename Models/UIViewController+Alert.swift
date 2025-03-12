import UIKit

extension UIViewController {
    func showAlert(title: String = "Error", message: String, completion: (() -> Void)? = nil) {
        DispatchQueue.main.async {
            guard self.viewIfLoaded?.window != nil else {
                print("⚠️ Warning: Attempted to show alert while view is not in hierarchy")
                return
            }
            
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
