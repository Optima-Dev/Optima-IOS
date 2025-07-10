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
    private var isProcessingCall = false // Prevents multiple connections

    var isSpecificMeeting: Bool = false
    var specificMeetingId: String? // Assigned from previous screen if specific meeting

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        addBlurEffect()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // Make sure we only start the call flow once
        guard !hasStartedCallFlow else {
            print("⛔️ Call flow already started (viewDidAppear)")
            return
        }

        hasStartedCallFlow = true
        print("🟢 viewDidAppear triggered startCallFlow()")
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
        videoContainerView.viewWithTag(999)?.removeFromSuperview()
        statusLabel.isHidden = true
    }

    // Entry point for joining the meeting
    private func startCallFlow() {
        if isProcessingCall {
            print("⛔️ Already processing call. Skipping.")
            return
        }

        isProcessingCall = true
        print("🟡 Starting call flow | isSpecific: \(isSpecificMeeting) | meetingId: \(specificMeetingId ?? "nil")")

        // Validate meeting type
        guard isSpecificMeeting, let meetingId = specificMeetingId else {
            print("❌ ERROR: Invalid meeting setup. isSpecificMeeting is false or meetingId is nil.")
            return
        }

        // Accept specific meeting request
        HelpRequestService.shared.acceptSpecificMeeting(meetingId: meetingId) { [weak self] result in
            switch result {
            case .success(let response):
                print("✅ Specific meeting accepted successfully.")
                self?.handleTokenResponse(response)

            case .failure(let error):
                print("❌ Failed to accept specific meeting: \(error)")
                self?.isProcessingCall = false
            }
        }
    }

    // Process response and connect to room
    private func handleTokenResponse(_ response: MeetingTokenResponse) {
        guard let tokenData = response.data else {
            print("❌ Token data is nil")
            return
        }

        accessToken = tokenData.token
        roomName = tokenData.roomName

        print("🧾 Received helper token: \(tokenData.token.prefix(20))...")
        print("🧾 Received room name: \(tokenData.roomName)")

        DispatchQueue.main.async {
            self.connectToRoom()
        }
    }

    // Connect to Twilio room
    private func connectToRoom() {
        guard let token = accessToken, let room = roomName else {
            print("❌ Missing token or room name")
            return
        }

        print("🚀 Helper connecting to room: \(room)")
        print("📹 Enable Video: false")

        VideoCallManager.shared.connectToRoom(
            token: token,
            roomName: room,
            enableVideo: false,
            delegate: self
        )
    }

    // End the call
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

    // Display incoming video track from seeker
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
        print("👥 Remote participants count: \(room.remoteParticipants.count)")

        for participant in room.remoteParticipants {
            print("👤 Existing participant: \(participant.identity)")
            participant.delegate = self

            if let videoTrack = participant.remoteVideoTracks.first?.remoteTrack {
                print("📺 Found remote video track on connect")
                DispatchQueue.main.async {
                    self.showRemoteVideo(videoTrack)
                    self.removeBlurAndStatus()
                }
            } else {
                print("⚠️ No remote video track found on connect")
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
        print("🟢 Participant connected: \(participant.identity)")
        DispatchQueue.main.async {
            self.removeBlurAndStatus()
        }
        participant.delegate = self
    }

    func participantDidDisconnect(room: Room, participant: RemoteParticipant) {
        print("🔴 Participant left: \(participant.identity)")
        DispatchQueue.main.async {
            self.statusLabel?.text = "Participant left"
        }
    }
}

// MARK: - RemoteParticipantDelegate
extension HelperVideoCallViewController: RemoteParticipantDelegate {
    func remoteParticipant(_ participant: RemoteParticipant, publishedVideoTrack publication: RemoteVideoTrackPublication) {
        print("📹 Remote video track published by: \(participant.identity)")
    }

    func remoteParticipant(_ participant: RemoteParticipant, unpublishedVideoTrack publication: RemoteVideoTrackPublication) {
        print("🚫 Remote video track unpublished by: \(participant.identity)")
    }

    func remoteParticipant(_ participant: RemoteParticipant, subscribedTo videoTrack: RemoteVideoTrack, publication: RemoteVideoTrackPublication) {
        print("✅ Subscribed to remote video track from: \(participant.identity)")
        DispatchQueue.main.async {
            self.showRemoteVideo(videoTrack)
        }
    }

    func remoteParticipant(_ participant: RemoteParticipant, unsubscribedFrom videoTrack: RemoteVideoTrack, publication: RemoteVideoTrackPublication) {
        print("🔕 Unsubscribed from remote video from: \(participant.identity)")
    }
}
