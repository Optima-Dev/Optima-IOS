import Foundation
import TwilioVideo

class VideoCallManager {

    static let shared = VideoCallManager()

    private var room: Room?
    private var camera: CameraSource?
    private var localVideoTrack: LocalVideoTrack?

    private init() {}

    func connectToRoom(token: String, roomName: String, enableVideo: Bool, delegate: RoomDelegate) {
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
                        }
                    }

                    builder.videoTracks = [self.localVideoTrack].compactMap { $0 }
                }
            }
        }

        self.room = TwilioVideoSDK.connect(options: options, delegate: delegate)
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
