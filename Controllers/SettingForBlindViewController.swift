//
//  SettingForBlindViewController.swift
//  Optima
//
//  Created by Ghada Abdelrahman on 27/02/2025.
//

import UIKit

class SettingForBlindViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        //set background
        let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
        backgroundImage.image = UIImage(named: "Background")
        backgroundImage.contentMode = .scaleAspectFill
        
        //make background at layer 0
        view.insertSubview(backgroundImage, at: 0)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
