import UIKit

class ChooseRoleViewController: UIViewController {
    
    
    @IBAction func blindButtonTapped(_ sender: UIButton) {
        UserDefaults.standard.set("Blind", forKey: "userRole")
        print("🔹 User selected role: Blind")
        // No need to manually navigate, Storyboard handles this
    }

    @IBAction func volunteerButtonTapped(_ sender: UIButton) {
        UserDefaults.standard.set("Volunteer", forKey: "userRole")
        print("🔹 User selected role: Volunteer")
        // No need to manually navigate, Storyboard handles this
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
        view.sendSubviewToBack(backgroundImage) // إرسال الصورة للخلف

        // ضبط الـ Constraints لجعل الصورة تمتد على كل الشاشة
        NSLayoutConstraint.activate([
            backgroundImage.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImage.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImage.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImage.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}
