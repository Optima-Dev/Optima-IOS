import UIKit
import TwilioVideo

class HelperVideoCallViewController: UIViewController {

    @IBOutlet weak var videoContainerView: UIView!
    @IBOutlet weak var remoteParticipantView: UIView!
    @IBOutlet weak var endCallButton: UIButton!
    @IBOutlet weak var statusLabel: UILabel!

    private var accessToken: String?
    private var roomName: String?
    private var hasStartedCallFlow = false
    private var isProcessingCall = false // ✅ Prevents multiple calls

    // ✅ NEW: to distinguish meeting type
    var isSpecificMeeting: Bool = false
    var specificMeetingId: String? // used if isSpecificMeeting = true

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        addBlurEffect()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !hasStartedCallFlow {
            hasStartedCallFlow = true
            startCallFlow()
        }
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
        videoContainerView.viewWithTag(999)?.removeFromSuperview()
        statusLabel.isHidden = true
    }

    private func startCallFlow() {
        guard !isProcessingCall else {
            print("⛔️ Call already in progress, skipping.")
            return
        }
        isProcessingCall = true

        print("🟡 Starting call flow | isSpecific: \(isSpecificMeeting) | meetingId: \(specificMeetingId ?? "nil")")

        if isSpecificMeeting, let meetingId = specificMeetingId {
            // ✅ Specific meeting logic
            HelpRequestService.shared.acceptSpecificMeeting(meetingId: meetingId) { [weak self] result in
                switch result {
                case .success(let response):
                    self?.handleTokenResponse(response)
                case .failure(let error):
                    print("❌ Failed to accept specific meeting: \(error)")
                }
            }
        } else {
            // ✅ Global meeting logic
            HelpRequestService.shared.acceptHelpRequest { [weak self] result in
                switch result {
                case .success(let response):
                    self?.handleTokenResponse(response)
                case .failure(let error):
                    print("❌ Failed to accept global meeting: \(error)")
                }
            }
        }
    }

    private func handleTokenResponse(_ response: MeetingTokenResponse) {
        guard let tokenData = response.data else {
            print("❌ Token data is nil")
            return
        }

        accessToken = tokenData.token
        roomName = tokenData.roomName

        print("🟢 Token: \(tokenData.token)")
        print("🟢 Room Name: \(tokenData.roomName)")

        DispatchQueue.main.async {
            self.connectToRoom()
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
            enableVideo: false,
            delegate: self
        )
    }

    @IBAction func endCallTapped(_ sender: UIButton) {
        VideoCallManager.shared.disconnect()

        MeetingService.shared.endMeetingForCurrentUser { result in
            switch result {
            case .success:
                print("✅ Meeting ended successfully")
            case .failure(let error):
                print("❌ Failed to end meeting: \(error)")
            }
        }

        dismiss(animated: true)
    }

    private func showRemoteVideo(_ videoTrack: VideoTrack) {
        let remoteView = VideoView(frame: remoteParticipantView.bounds)
        remoteView.contentMode = .scaleAspectFill
        remoteView.shouldMirror = false
        remoteView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        videoTrack.addRenderer(remoteView)
        remoteParticipantView.addSubview(remoteView)
    }
}

// MARK: - RoomDelegate
extension HelperVideoCallViewController: RoomDelegate {
    func roomDidConnect(room: Room) {
        print("🟢 Connected to room: \(room.name)")
        for participant in room.remoteParticipants {
            print("👤 Existing participant: \(participant.identity)")
            participant.delegate = self

            if let videoTrack = participant.remoteVideoTracks.first?.remoteTrack {
                DispatchQueue.main.async {
                    self.showRemoteVideo(videoTrack)
                    self.removeBlurAndStatus()
                }
            }
        }
    }

    func roomDidDisconnect(room: Room, error: Error?) {
        print("🔴 Disconnected from room. Error: \(error?.localizedDescription ?? "none")")
        DispatchQueue.main.async {
            self.statusLabel?.text = "Disconnected"
        }
    }

    func roomDidFailToConnect(room: Room, error: Error) {
        print("❌ Connection failed: \(error.localizedDescription)")
        DispatchQueue.main.async {
            self.statusLabel?.text = "Connection failed"
        }
    }

    func participantDidConnect(room: Room, participant: RemoteParticipant) {
        print("🟢 Participant connected")
        DispatchQueue.main.async {
            self.removeBlurAndStatus()
        }
        participant.delegate = self
    }

    func participantDidDisconnect(room: Room, participant: RemoteParticipant) {
        print("🔴 Participant left")
        DispatchQueue.main.async {
            self.statusLabel?.text = "Participant left"
        }
    }
}

// MARK: - RemoteParticipantDelegate
extension HelperVideoCallViewController: RemoteParticipantDelegate {
    func remoteParticipant(_ participant: RemoteParticipant, publishedVideoTrack publication: RemoteVideoTrackPublication) {
        print("📹 Remote video track published")
    }

    func remoteParticipant(_ participant: RemoteParticipant, unpublishedVideoTrack publication: RemoteVideoTrackPublication) {
        print("🚫 Remote video track unpublished")
    }

    func remoteParticipant(_ participant: RemoteParticipant, subscribedTo videoTrack: RemoteVideoTrack, publication: RemoteVideoTrackPublication) {
        print("✅ Subscribed to remote video track")
        DispatchQueue.main.async {
            self.showRemoteVideo(videoTrack)
        }
    }

    func remoteParticipant(_ participant: RemoteParticipant, unsubscribedFrom videoTrack: RemoteVideoTrack, publication: RemoteVideoTrackPublication) {
        print("🔕 Unsubscribed from remote video")
    }
}
