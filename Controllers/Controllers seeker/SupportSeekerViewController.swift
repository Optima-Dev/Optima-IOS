import UIKit

class SupportSeekerViewController: SeekerBaseViewController {

    @IBOutlet weak var myPeople: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set background image
        let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
        backgroundImage.image = UIImage(named: "Background")
        backgroundImage.contentMode = .scaleAspectFill
        view.insertSubview(backgroundImage, at: 0)

        // Style My People button
        myPeople.layer.borderWidth = 3
        myPeople.layer.borderColor = UIColor(red: 39/255, green: 39/255, blue: 196/255, alpha: 1.0).cgColor
        myPeople.layer.cornerRadius = 22
        myPeople.clipsToBounds = true

    }

    @IBAction func callAVolunteerTapped(_ sender: UIButton) {
        // Global call: no helperId needed
        MeetingService.shared.createMeeting(type: "global", helperId: nil) { result in
            switch result {
            case .success(let response):
                let tokenData = response.data

                DispatchQueue.main.async {
                    if let tokenData = tokenData,
                       let vc = self.storyboard?.instantiateViewController(withIdentifier: "SeekerVideoCallViewController") as? SeekerVideoCallViewController {

                        vc.callType = .global
                        vc.token = tokenData.token
                        vc.roomName = tokenData.roomName
                        vc.identity = tokenData.identity
                        vc.meetingId = tokenData.meetingId ?? ""
                        self.navigationController?.pushViewController(vc, animated: true)
                    } else {
                        print("❌ Token data is nil")
                    }
                }

            case .failure(let error):
                print("❌ Failed to create meeting: \(error)")
            }
        }
    }
}
