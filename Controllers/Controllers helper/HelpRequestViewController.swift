import UIKit

class HelpRequestViewController: UIViewController {

    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var helpRequestButton: UIButton!
    @IBOutlet weak var notificationButton: UIButton!

    private var backgroundImageView: UIImageView!
    private var refreshTimer: Timer?
    private var didAcceptRequest = false // to stop loops
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        setupBackground()
        checkHelpRequest()
        startAutoRefresh()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stopAutoRefresh()
    }

    private func setupBackground() {
        backgroundImageView = UIImageView(frame: view.bounds)
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(backgroundImageView, at: 0)

        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    private func checkHelpRequest() {
        guard !didAcceptRequest else { return } // ✅ امنع التكرار بعد القبول

        HelpRequestService.shared.checkPendingHelpRequest { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }

                switch result {
                case .success(let hasRequest):
                    self.updateUI(hasPending: hasRequest)
                case .failure:
                    self.updateUI(hasPending: false)
                }
            }
        }
    }

    private func updateUI(hasPending: Bool) {
        if hasPending {
            backgroundImageView.image = UIImage(named: "helpReq1")
            acceptButton.backgroundColor = UIColor(hex: "#2727C4")
            acceptButton.setTitleColor(.white, for: .normal)
            acceptButton.isEnabled = true
        } else {
            backgroundImageView.image = UIImage(named: "helpReq2")
            acceptButton.backgroundColor = UIColor(hex: "#5E5E5E")
            acceptButton.setTitleColor(.white, for: .normal)
            acceptButton.isEnabled = false
        }
    }

    private func startAutoRefresh() {
        refreshTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
            self?.checkHelpRequest()
        }
    }

    private func stopAutoRefresh() {
        refreshTimer?.invalidate()
        refreshTimer = nil
    }

    @IBAction func acceptButtonTapped(_ sender: UIButton) {
        acceptButton.isEnabled = false
        stopAutoRefresh()

        HelpRequestService.shared.acceptHelpRequest { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }

                switch result {
                case .success(let response):
                    self.didAcceptRequest = true // ✅ هنا نوقف التكرار بعد القبول
                    print("✅ Token received: \(response.data?.token ?? "no token")")
                    self.navigateToCall()
                case .failure(let error):
                    self.showError(error)
                    self.acceptButton.isEnabled = true
                    self.startAutoRefresh()
                }
            }
        }
    }

    private func navigateToCall() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "HelperVideoCallViewController") as? HelperVideoCallViewController {
            vc.modalPresentationStyle = .fullScreen
            vc.isSpecificMeeting = false
            self.present(vc, animated: true)
        } else {
            print("❌ Failed to instantiate HelperVideoCallViewController")
        }
    }

    private func showError(_ error: Error) {
        let alert = UIAlertController(title: "Error", message: "Something went wrong. Please try again.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    @IBAction func goToNotifications(_ sender: UIButton) {
        if let notiVC = storyboard?.instantiateViewController(withIdentifier: "NotificationsViewController") {
            navigationController?.pushViewController(notiVC, animated: true)
        }

        UIView.animate(withDuration: 0.4) {
            self.helpRequestButton.transform = CGAffineTransform(translationX: 170, y: 0)
            self.helpRequestButton.alpha = 0

            self.notificationButton.transform = .identity
            self.notificationButton.alpha = 1
        }
    }
}
