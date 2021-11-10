//
//  ViewController.swift
//  PiPBugDemo
//
//  Created by Chad Etzel on 11/10/21.
//

import UIKit
import AVKit
import AVFoundation

class TVViewController: UIViewController, AVPictureInPictureSampleBufferPlaybackDelegate, AVPictureInPictureControllerDelegate {

    @IBOutlet weak var videoContainerView: UIView!
    @IBOutlet weak var pipButton: UIButton!
    @IBOutlet weak var pipSupportedLabel: UILabel!
    @IBOutlet weak var pipPossibleLabel: UILabel!

    var pipController: AVPictureInPictureController! = nil
    var pipObservation: NSKeyValueObservation?

    private let videoProvider = VideoProvider()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        let bufferDisplayLayer = videoProvider.bufferDisplayLayer
        bufferDisplayLayer.frame = videoContainerView.bounds
        bufferDisplayLayer.videoGravity = .resizeAspect
        videoContainerView.layer.addSublayer(bufferDisplayLayer)

        self.pipButton.setTitle("", for: .normal)
        self.pipButton.setImage(AVPictureInPictureController.pictureInPictureButtonStartImage, for: .normal)

        videoProvider.start()

        let contentSource = AVPictureInPictureController.ContentSource(sampleBufferDisplayLayer: videoProvider.bufferDisplayLayer, playbackDelegate: self)


#warning("This code MUST BE RUN ON A REAL DEVICE. NOT SUPPORTED ON SIMULATOR")

        pipController = AVPictureInPictureController(contentSource: contentSource)
        pipController.delegate = self

        pipObservation = pipController.observe(\AVPictureInPictureController.isPictureInPicturePossible,
                                                options: [.initial, .new]) { [weak self] _, change in
            print("isPictureInPicturePossible: \(change.newValue ?? false)")
            DispatchQueue.main.async {
                self?.pipPossibleLabel.text = "\(change.newValue ?? false)"
            }
        }

        pipSupportedLabel.text = "\(AVPictureInPictureController.isPictureInPictureSupported())"
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

#warning("This delegate method is never called on tvOS, this feels like a bug")

        print("\(#function)")
        if playing {
            videoProvider.start()
        } else {
            videoProvider.stop()
        }
    }

    func pictureInPictureControllerTimeRangeForPlayback(_ pictureInPictureController: AVPictureInPictureController) -> CMTimeRange {

#warning("This delegate method is never called on tvOS, this feels like a bug")

        print("\(#function)")
        return CMTimeRange(start: .negativeInfinity, duration: .positiveInfinity)
    }

    func pictureInPictureControllerIsPlaybackPaused(_ pictureInPictureController: AVPictureInPictureController) -> Bool {
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

