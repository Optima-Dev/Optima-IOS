import UIKit

class ChooseRoleViewController: UIViewController {
    
    @IBAction func blindButtonTapped(_ sender: UIButton) {
        UserDefaults.standard.set("seeker", forKey: "userRole") // Changed to "seeker"
        print("🔹 User selected role:seeker")
    }

    @IBAction func volunteerButtonTapped(_ sender: UIButton) {
        UserDefaults.standard.set("helper", forKey: "userRole") // Changed to "helper"
        print("🔹 User selected role: helper")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setBackgroundImage()
    }

    func setBackgroundImage() {
        let backgroundImage = UIImageView(frame: view.bounds)
        backgroundImage.image = UIImage(named: "Background")
        backgroundImage.contentMode = .scaleAspectFill
        backgroundImage.clipsToBounds = true
        backgroundImage.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(backgroundImage)
        view.sendSubviewToBack(backgroundImage)
        
        NSLayoutConstraint.activate([
            backgroundImage.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImage.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImage.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImage.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}
