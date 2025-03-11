//
//  SettingForBlindViewController.swift
//  Optima
//
//  Created by Ghada Abdelrahman on 27/02/2025.
//
import UIKit

class SettingForBlindViewController: UIViewController {
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //set background
        let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
        backgroundImage.image = UIImage(named: "Background")
        backgroundImage.contentMode = .scaleAspectFill
        
        //make background at layer 0
        view.insertSubview(backgroundImage, at: 0)
        loadUserData()
    }
    
    private func loadUserData() {
        UserManager.shared.fetchCurrentUser { [weak self] result in
            switch result {
            case .success(let user):
                DispatchQueue.main.async {
                    self?.userNameLabel.text = "\(user.firstName) \(user.lastName)"
                    self?.emailLabel.text = user.email
                }
            case .failure(let error):
                self?.showAlert(message: "Error: \(error.localizedDescription)")
            }
        }
    }
}
/*
 //set background
 let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
 backgroundImage.image = UIImage(named: "Background")
 backgroundImage.contentMode = .scaleAspectFill
 
 //make background at layer 0
 view.insertSubview(backgroundImage, at: 0)
 */
