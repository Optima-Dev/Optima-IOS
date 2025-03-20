import UIKit

class SplashScreenViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
            self.handleNavigation()
        }
    }
    
    func handleNavigation() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        if let userRole = getUserRole() {
            let tabBarVC: UITabBarController
            
            if userRole == .seeker {
                tabBarVC = storyboard.instantiateViewController(withIdentifier: "SeekerTabBarController") as! UITabBarController
            } else {
                tabBarVC = storyboard.instantiateViewController(withIdentifier: "HelperTabBarController") as! UITabBarController
            }
            
            switchToRootViewController(tabBarVC)
        } else {
            let onboardingVC = storyboard.instantiateViewController(withIdentifier: "OnboardingPageViewController") as! OnboardingPageViewController
            switchToRootViewController(onboardingVC)
        }
    }
    
    func switchToRootViewController(_ viewController: UIViewController) {
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = scene.windows.first {
            window.rootViewController = viewController
            window.makeKeyAndVisible()
        }
    }

    // دالة لاسترجاع الـ Role لو المستخدم مسجل دخول
    func getUserRole() -> UserRole? {
        if let savedRole = UserDefaults.standard.string(forKey: "userRole") {
            return savedRole == "seeker" ? .seeker : .helper
        }
        return nil
    }
}

// تعريف الـ Enum الخاص بالـ Roles
enum UserRole {
    case seeker
    case helper
}
