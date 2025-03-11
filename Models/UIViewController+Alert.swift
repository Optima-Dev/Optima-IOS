//
//  UIViewController+Alert.swift
//  Optima
//
//  Created by Ghada Abdelrahman on 09/03/2025.
//

import UIKit

extension UIViewController {
    func showAlert(title: String = "Error", message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            completion?()
        })
        present(alert, animated: true)
    }
}
