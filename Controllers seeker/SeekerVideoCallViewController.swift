import UIKit
import TwilioVideo

class SeekerVideoCallViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var videoContainerView: UIView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var flipCameraButton: UIButton!
    @IBOutlet weak var endCallButton: UIButton!

    // MARK: - Properties
    private var accessToken: String?
    private var roomName: String?
    private var currentMeetingId: String?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        addBlurEffect()
        print("🔵 SeekerVideoCallViewController loaded")
        startCallFlow()
    }

    private func setupUI() {
        flipCameraButton.layer.cornerRadius = 8
        endCallButton.layer.cornerRadius = 8
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

    // MARK: - Video Flow
    private func startCallFlow() {
        let helperId = "PUT_HELPER_ID_HERE"

        MeetingService.shared.createMeeting(type: "global", helperId: helperId) { [weak self] result in
            switch result {
            case .success(let meetingResponse):
                let meetingId = meetingResponse.data.meeting.id
                self?.currentMeetingId = meetingId

                MeetingService.shared.generateToken(meetingId: meetingId) { tokenResult in
                    switch tokenResult {
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

            case .failure(let error):
                print("❌ Meeting creation failed: \(error)")
            }
        }
    }

    private func connectToRoom() {
        guard let token = accessToken, let room = roomName else {
            print("❌ Missing token or room name")
            return
        }

        VideoCallManager.shared.connectToRoom(
            token: token,
            roomName: room,
            enableVideo: true,
            delegate: self
        )
    }

    // MARK: - Actions
    @IBAction func flipCameraTapped(_ sender: UIButton) {
        VideoCallManager.shared.flipCamera()
    }

    @IBAction func endCallTapped(_ sender: UIButton) {
        // Disconnect Twilio
        VideoCallManager.shared.disconnect()

        // End meeting via API
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

        // Dismiss the VC
        dismiss(animated: true)
    }
}

// MARK: - RoomDelegate
extension SeekerVideoCallViewController: RoomDelegate {
    func roomDidConnect(room: Room) {
        print("🟢 Connected to room: \(room.name)")
    }

    func roomDidDisconnect(room: Room, error: Error?) {
        print("🔴 Disconnected from room. Error: \(error?.localizedDescription ?? "none")")
    }

    func roomDidFailToConnect(room: Room, error: Error) {
        print("❌ Connection failed: \(error.localizedDescription)")
    }

    func participantDidConnect(room: Room, participant: RemoteParticipant) {
        print("🟢 Participant connected")
        DispatchQueue.main.async {
            self.removeBlurAndStatus()
        }
    }

    func participantDidDisconnect(room: Room, participant: RemoteParticipant) {
        print("🔴 Participant left")
    }
}
