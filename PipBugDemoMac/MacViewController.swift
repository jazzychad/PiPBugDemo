//
//  ViewController.swift
//  PipBugDemoMac
//
//  Created by Chad Etzel on 11/10/21.
//

import Cocoa
import AVKit
import AVFoundation

class MacViewController: NSViewController, AVPictureInPictureSampleBufferPlaybackDelegate, AVPictureInPictureControllerDelegate {

    @IBOutlet weak var videoContainerView: NSView!
    @IBOutlet weak var pipButton: NSButton!
    @IBOutlet weak var pipSupportedLabel: NSTextField!
    @IBOutlet weak var pipPossibleLabel: NSTextField!

    var pipController: AVPictureInPictureController! = nil
    var pipObservation: NSKeyValueObservation?

    private let videoProvider = VideoProvider()


    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        videoContainerView.wantsLayer = true

        let bufferDisplayLayer = videoProvider.bufferDisplayLayer
        bufferDisplayLayer.frame = videoContainerView.bounds
        bufferDisplayLayer.videoGravity = .resizeAspect
        videoContainerView.layer?.addSublayer(bufferDisplayLayer)

        self.pipButton.title = ""
        self.pipButton.image =  AVPictureInPictureController.pictureInPictureButtonStartImage
        videoProvider.start()

        let contentSource = AVPictureInPictureController.ContentSource(sampleBufferDisplayLayer: videoProvider.bufferDisplayLayer, playbackDelegate: self)


        pipController = AVPictureInPictureController(contentSource: contentSource)
        pipController.delegate = self

        pipObservation = pipController.observe(\AVPictureInPictureController.isPictureInPicturePossible,
                                                options: [.initial, .new]) { [weak self] _, change in
            print("isPictureInPicturePossible: \(change.newValue ?? false)")

            DispatchQueue.main.async {
                self?.pipPossibleLabel.stringValue = "\(change.newValue ?? false)"
            }
        }

        self.pipSupportedLabel.stringValue = "\(AVPictureInPictureController.isPictureInPictureSupported())"
    }

    @IBAction func _pipButtonDidTap(_ sender: Any) {
        print("PIP supported??????? \(AVPictureInPictureController.isPictureInPictureSupported())")
        if pipController.isPictureInPicturePossible {
            pipController.startPictureInPicture()
        } else {
            print("NO PIP AVAILABLE.. trying anyway")
            pipController.startPictureInPicture()
        }
    }

    // MARK: - AVPictureInPictureSampleBufferPlaybackDelegate

    func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController, setPlaying playing: Bool) {
        print("\(#function)")
        if playing {
            videoProvider.start()
        } else {
            videoProvider.stop()
        }
    }

    func pictureInPictureControllerTimeRangeForPlayback(_ pictureInPictureController: AVPictureInPictureController) -> CMTimeRange {

#warning("This delegate method is never called on macOS, this feels like a bug")

        print("\(#function)")
        return CMTimeRange(start: .negativeInfinity, duration: .positiveInfinity)
    }

    func pictureInPictureControllerIsPlaybackPaused(_ pictureInPictureController: AVPictureInPictureController) -> Bool {

#warning("This delegate method is never called on macOS, this feels like a bug")

        print("\(#function)")
        return false
    }

    func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController, didTransitionToRenderSize newRenderSize: CMVideoDimensions) {
        print("\(#function)")
    }

    func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController, skipByInterval skipInterval: CMTime, completion completionHandler: @escaping () -> Void) {
        print("\(#function)")
        completionHandler()
    }


    // MARK: - AVPictureInPictureControllerDelegate

    func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController, failedToStartPictureInPictureWithError error: Error) {
        print("\(#function)")
        print("pip error: \(error)")
    }

    func pictureInPictureControllerWillStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        print("\(#function)")
    }

    func pictureInPictureControllerWillStopPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        print("\(#function)")
    }


}

