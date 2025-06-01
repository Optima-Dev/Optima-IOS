import UIKit

class SupportSeekerViewController: UIViewController {

    @IBOutlet weak var myPeople: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Background setup
        let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
        backgroundImage.image = UIImage(named: "Background")
        backgroundImage.contentMode = .scaleAspectFill
        view.insertSubview(backgroundImage, at: 0)
        
        // Apply border and corner
        myPeople.layer.borderWidth = 3 
        myPeople.layer.borderColor = UIColor(hex: "#2727C4").cgColor
        myPeople.layer.cornerRadius = 22
        myPeople.clipsToBounds = true
    }
}
