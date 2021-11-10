
# PiP Bug Demo

I believe there is an Apple-level framework issue when using `AVPictureInPictureController` with an `AVSampleBufferDisplayLayer` content source on `macOS` or `tvOS`

This bug manifests itself with the following consequence: **It is not possible to start a PiP session on `tvOS` or `macOS` when using an `AVSampleBufferDisplayLayer` as a content source for `AVPictureInPictureController`.**

---

This project presents 3 apps, one for `iOS`, `tvOS`, and `macOS` - which are all setup to use Picture in Picture with AVSampleBufferDisplayLayer as the content source. This is new API available in iOS 15, tvOS 15, and macOS 12.

For `iOS` and `tvOS` I have added the `Picture in Picture` background mode in Signing and Capabilities (Info.plist entry). There doesn't seem to be an equivelent on `macOS`.


I have also set the `AVAudioSession` to `.playback` on `iOS` and `tvOS` which is required to support Picture in Picture. Again, there seems to be no equivelent on `macOS` but I could be wrong?


```swift
do {
    try AVAudioSession.sharedInstance().setCategory(.playback, mode: .moviePlayback)
} catch {
    print("Setting category to AVAudioSessionCategoryPlayback failed.")
}
```

In the relevant apps' view controller code, the AVPictureInPictureController setup is as follows:

```swift
let contentSource = AVPictureInPictureController.ContentSource(sampleBufferDisplayLayer: videoProvider.bufferDisplayLayer, playbackDelegate: self)


pipController = AVPictureInPictureController(contentSource: contentSource)
pipController.delegate = self
```

On `iOS` I am receiving delegate callbacks to the `AVPictureInPictureSampleBufferPlaybackDelegate` methods:

```
IOSViewController.pictureInPictureControllerTimeRangeForPlayback(_:)
IOSViewController.pictureInPictureControllerIsPlaybackPaused(_:)
```

which it seems necessary for the system to call in order to setup Picture in Picture playback.

However, these methods **ARE NEVER CALLED** on `tvOS` or `macOS`

As a result, `pipController.isPictureInPicturePossible` is `true` on iOS but is always `false` on tvOS and macOS.

I suspect that somewhere in the guts of the AVKit/AVFoundation framework, these delegate methods are not being queried on `tvOS` nor `macOS` and so PiP setup is never completed and it will always fail.
