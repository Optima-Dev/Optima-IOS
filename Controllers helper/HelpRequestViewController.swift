import UIKit

class HelpRequestViewController: UIViewController {

    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var helpRequestButton: UIButton!
    @IBOutlet weak var notificationButton: UIButton!

    private var backgroundImageView: UIImageView!
    private var currentMeetingId: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackground()
        checkHelpRequest()

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
        HelpRequestService.shared.checkPendingHelpRequest { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let hasRequest):
                    self?.updateUI(hasPending: hasRequest)
                case .failure:
                    self?.updateUI(hasPending: false)
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

    @IBAction func acceptButtonTapped(_ sender: UIButton) {
        acceptButton.isEnabled = false
        HelpRequestService.shared.acceptHelpRequest { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    let meetingId = response.data.meeting.id
                    self?.navigateToCall(meetingId: meetingId)
                case .failure(let error):
                    self?.showError(error)
                    self?.acceptButton.isEnabled = true
                }
            }
        }
    }

    private func navigateToCall(meetingId: String) {
        let vc = HelperVideoCallViewController()
        vc.setMeetingId(meetingId)
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }

    private func showError(_ error: Error) {
        let alert = UIAlertController(title: "Error", message: "Something went wrong. Please try again.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    @IBAction func goToNotifications(_ sender: UIButton) {
        UIView.animate(withDuration: 0.4, animations: {
            self.helpRequestButton.transform = CGAffineTransform(translationX: 170, y: 0)
            self.helpRequestButton.alpha = 0

            self.notificationButton.transform = .identity
            self.notificationButton.alpha = 1
        }, completion: { _ in
            guard let notiVC = self.storyboard?.instantiateViewController(withIdentifier: "NotificationsViewController") else { return }
            self.navigationController?.pushViewController(notiVC, animated: true)
        })
    }
}
