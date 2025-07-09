import UIKit
import TwilioVideo

enum CallType {
    case global
    case friend
}

class SeekerVideoCallViewController: UIViewController {

    @IBOutlet weak var videoContainerView: UIView!
    @IBOutlet weak var remoteParticipantView: UIView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var flipCameraButton: UIButton!
    @IBOutlet weak var endCallButton: UIButton!

    var helperId: String?
    var callType: CallType = .global

    var token: String = ""
    var roomName: String = ""
    var identity: String = ""
    var meetingId: String = ""

    private var hasConnectedParticipant = false
    private var hasStartedMeeting = false

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        addBlurEffect()
        print("🔵 SeekerVideoCallViewController loaded")
        startMeeting()
    }

    private func setupUI() {
        flipCameraButton.layer.cornerRadius = 8
        endCallButton.layer.cornerRadius = 8
    }

    private func addBlurEffect() {
        let background = UIImageView(frame: videoContainerView.bounds)
        background.image = UIImage(named: "videoCall")
        background.contentMode = .scaleAspectFill
        background.clipsToBounds = true
        background.tag = 998
        videoContainerView.addSubview(background)

        let blur = UIBlurEffect(style: .dark)
        let blurView = UIVisualEffectView(effect: blur)
        blurView.frame = videoContainerView.bounds
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurView.tag = 999
        videoContainerView.addSubview(blurView)

        videoContainerView.bringSubviewToFront(statusLabel)
    }

    private func removeBlurAndStatus() {
        videoContainerView.viewWithTag(999)?.removeFromSuperview()
        videoContainerView.viewWithTag(998)?.removeFromSuperview()
        statusLabel.isHidden = true
    }

    private func startMeeting() {
        guard !hasStartedMeeting else {
            print("⛔️ Meeting already started. Skipping duplicate call.")
            return
        }
        hasStartedMeeting = true

        let type = callType == .friend ? "specific" : "global"

        createNewMeeting(type: type)
    }

    private func createNewMeeting(type: String) {
        MeetingService.shared.createMeeting(type: type, helperId: helperId) { [weak self] result in
            switch result {
            case .success(let response):
                if response.status == "success", let data = response.data {
                    self?.token = data.token
                    self?.roomName = data.roomName
                    self?.identity = data.identity
                    self?.meetingId = data.meetingId ?? ""
                    self?.connectToRoom()
                } else {
                    print("❌ Server error: \(response.message ?? "Unknown error")")
                }
            case .failure(let error):
                print("❌ Failed to create meeting: \(error)")
            }
        }
    }

    private func connectToRoom() {
        guard !token.isEmpty, !roomName.isEmpty, !identity.isEmpty else {
            print("❌ Missing token, room name, or identity")
            return
        }

        print("💬 TOKEN:\n\(token)")
        print("💬 ROOM NAME:\n\(roomName)")
        print("💬 IDENTITY:\n\(identity)")

        VideoCallManager.shared.connectToRoom(
            token: token,
            roomName: roomName,
            enableVideo: true,
            delegate: self,
            previewView: self.videoContainerView
        )
    }

    @IBAction func flipCameraTapped(_ sender: UIButton) {
        VideoCallManager.shared.flipCamera()
    }

    @IBAction func endCallTapped(_ sender: UIButton) {
        VideoCallManager.shared.disconnect()

        if !meetingId.isEmpty {
            MeetingService.shared.endMeeting(meetingId: meetingId) { result in
                switch result {
                case .success:
                    print("✅ Meeting ended successfully")
                case .failure(let error):
                    print("❌ Failed to end meeting: \(error)")
                }
            }
        } else {
            print("⚠️ No meetingId. Skipping endMeeting.")
        }

        dismiss(animated: true)
    }
}

// MARK: - RoomDelegate
extension SeekerVideoCallViewController: RoomDelegate {
    func roomDidConnect(room: Room) {
        print("🟢 Connected to room: \(room.name)")

        VideoCallManager.shared.publishLocalVideoTrack()
    }

    func roomDidDisconnect(room: Room, error: Error?) {
        print("🔴 Disconnected from room. Error: \(error?.localizedDescription ?? "none")")
    }

    func roomDidFailToConnect(room: Room, error: Error) {
        print("❌ Connection failed: \(error.localizedDescription)")
    }

    func participantDidConnect(room: Room, participant: RemoteParticipant) {
        print("🟢 Participant connected")
        hasConnectedParticipant = true
        DispatchQueue.main.async {
            self.removeBlurAndStatus()
            if let videoTrack = participant.remoteVideoTracks.first?.remoteTrack {
                VideoCallManager.shared.renderRemoteVideoTrack(videoTrack, in: self.remoteParticipantView)
            } else {
                print("⚠️ No remote video track found")
            }
        }
    }

    func participantDidDisconnect(room: Room, participant: RemoteParticipant) {
        print("🔴 Participant left")
    }
}
