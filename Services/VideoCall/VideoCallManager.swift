import Foundation
import TwilioVideo
import UIKit

class VideoCallManager {

    static let shared = VideoCallManager()

    private var room: Room?
    private var camera: CameraSource?
    private var localVideoTrack: LocalVideoTrack?

    private init() {}

    func connectToRoom(token: String, roomName: String, enableVideo: Bool, delegate: RoomDelegate, previewView: UIView? = nil) {
        let options = ConnectOptions(token: token) { builder in
            builder.roomName = roomName

            if enableVideo {
                let cameraOptions = CameraSourceOptions { $0.rotationTags = .remove }
                self.camera = CameraSource(options: cameraOptions, delegate: nil)

                if let frontCamera = CameraSource.captureDevice(position: .front),
                   let camera = self.camera {
                    self.localVideoTrack = LocalVideoTrack(source: camera, enabled: true, name: "Camera")

                    camera.startCapture(device: frontCamera) { _, _, error in
                        if let error = error {
                            print("❌ Error starting camera: \(error.localizedDescription)")
                        } else if let preview = previewView, let track = self.localVideoTrack {
                            DispatchQueue.main.async {
                                let renderer = VideoView(frame: preview.bounds)
                                renderer.contentMode = .scaleAspectFill
                                renderer.shouldMirror = true
                                renderer.autoresizingMask = [.flexibleWidth, .flexibleHeight]

                                track.addRenderer(renderer)
                                preview.addSubview(renderer)
                            }
                        }
                    }

                    builder.videoTracks = [self.localVideoTrack].compactMap { $0 }
                }
            }
        }

        self.room = TwilioVideoSDK.connect(options: options, delegate: delegate)
    }

    func publishLocalVideoTrack() {
        guard let room = room,
              let participant = room.localParticipant,
              let videoTrack = localVideoTrack else {
            print("❌ Cannot publish video track – missing components")
            return
        }

        participant.publishVideoTrack(videoTrack)
        print("✅ Local video track published")
    }

    func startLocalVideoPreview(in view: UIView) {
        guard let track = localVideoTrack else {
            print("❌ No local video track to preview")
            return
        }

        let renderer = VideoView(frame: view.bounds)
        renderer.contentMode = .scaleAspectFill
        renderer.shouldMirror = true
        renderer.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        track.addRenderer(renderer)
        view.addSubview(renderer)
    }

    func renderRemoteVideoTrack(_ videoTrack: VideoTrack, in view: UIView) {
        let remoteView = VideoView(frame: view.bounds)
        remoteView.contentMode = .scaleAspectFill
        remoteView.shouldMirror = false
        remoteView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        videoTrack.addRenderer(remoteView)
        view.addSubview(remoteView)
    }

    func flipCamera() {
        guard let camera = camera else { return }
        guard let current = camera.device?.position else { return }

        let newPosition: AVCaptureDevice.Position = (current == .front) ? .back : .front
        if let newDevice = CameraSource.captureDevice(position: newPosition) {
            camera.selectCaptureDevice(newDevice) { _, _, error in
                if let error = error {
                    print("❌ Error flipping camera: \(error.localizedDescription)")
                }
            }
        }
    }

    func disconnect() {
        camera?.stopCapture()
        localVideoTrack = nil
        camera = nil
        room?.disconnect()
        room = nil
    }
}
