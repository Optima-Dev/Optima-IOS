import UIKit

class SplashScreenViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
            self.navigateToOnboarding()
        }
    }
    
    func navigateToOnboarding() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let onboardingVC = storyboard.instantiateViewController(withIdentifier: "OnboardingPageViewController") as! OnboardingPageViewController
        
        if let window = UIApplication.shared.windows.first {
            window.rootViewController = onboardingVC
            window.makeKeyAndVisible()
        }
    }
}
