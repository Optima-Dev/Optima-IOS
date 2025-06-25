import UIKit
import TwilioVideo

class HelperVideoCallViewController: UIViewController {

    @IBOutlet weak var videoContainerView: UIView!
    @IBOutlet weak var endCallButton: UIButton!
    @IBOutlet weak var statusLabel: UILabel!

    private var accessToken: String?
    private var roomName: String?
    private var currentMeetingId: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        addBlurEffect()
        startCallFlow()
    }

    private func setupUI() {
        endCallButton.layer.cornerRadius = 8
        statusLabel.text = "Waiting for the seeker..."
        statusLabel.textColor = .white
        statusLabel.isHidden = false
    }

    private func addBlurEffect() {
        let blur = UIBlurEffect(style: .dark)
        let blurView = UIVisualEffectView(effect: blur)
        blurView.frame = videoContainerView.bounds
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurView.tag = 999
        videoContainerView.addSubview(blurView)
        videoContainerView.bringSubviewToFront(statusLabel)
    }

    private func removeBlurAndStatus() {
        if let blur = videoContainerView.viewWithTag(999) {
            blur.removeFromSuperview()
        }
        statusLabel.isHidden = true
    }

    func setMeetingId(_ id: String) {
        self.currentMeetingId = id
    }

    private func startCallFlow() {
        guard let meetingId = currentMeetingId else {
            print("❌ No meetingId provided")
            return
        }

        MeetingService.shared.generateToken(meetingId: meetingId) { [weak self] result in
            switch result {
            case .success(let tokenResponse):
                self?.accessToken = tokenResponse.data.token
                self?.roomName = tokenResponse.data.roomName
                DispatchQueue.main.async {
                    self?.connectToRoom()
                }
            case .failure(let error):
                print("❌ Token generation failed: \(error)")
            }
        }
    }

    private func connectToRoom() {
        guard let token = accessToken, let room = roomName else {
            print("❌ Missing token or room name")
            return
        }

        print("💬 TOKEN RECEIVED FROM API:\n\(token)")
        print("💬 ROOM NAME:\n\(room)")

        VideoCallManager.shared.connectToRoom(
            token: token,
            roomName: room,
            enableVideo: false, // Helper does not share video
            delegate: self
        )
    }

    @IBAction func endCallTapped(_ sender: UIButton) {
        VideoCallManager.shared.disconnect()

        if let meetingId = currentMeetingId {
            MeetingService.shared.endMeeting(meetingId: meetingId) { result in
                switch result {
                case .success:
                    print("✅ Meeting ended successfully")
                case .failure(let error):
                    print("❌ Failed to end meeting: \(error)")
                }
            }
        } else {
            print("⚠️ No meetingId to end")
        }

        dismiss(animated: true)
    }
}

extension HelperVideoCallViewController: RoomDelegate {
    func roomDidConnect(room: Room) {
        print("🟢 Connected to room: \(room.name)")
    }

    func roomDidDisconnect(room: Room, error: Error?) {
        print("🔴 Disconnected from room. Error: \(error?.localizedDescription ?? "none")")
        DispatchQueue.main.async {
            self.statusLabel.text = "Disconnected"
        }
    }

    func roomDidFailToConnect(room: Room, error: Error) {
        print("❌ Connection failed: \(error.localizedDescription)")
        DispatchQueue.main.async {
            self.statusLabel.text = "Connection failed"
        }
    }

    func participantDidConnect(room: Room, participant: RemoteParticipant) {
        print("🟢 Participant connected")
        DispatchQueue.main.async {
            self.removeBlurAndStatus()
        }
    }

    func participantDidDisconnect(room: Room, participant: RemoteParticipant) {
        print("🔴 Participant left")
        DispatchQueue.main.async {
            self.statusLabel.text = "Participant left"
        }
    }
}
