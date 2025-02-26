//
//  ViewController.swift
//  SceneKitVideoRecorderDemo
//
//  Created by Okaris 2017 on 08/09/2017.
//  Copyright © 2017 okaris. All rights reserved.
//

import UIKit
import Photos
import SceneKit
import ARKit
import SceneKitVideoRecorder

class ViewController: UIViewController, ARSCNViewDelegate {

  @IBOutlet var sceneView: ARSCNView!

  var recorder: SceneKitVideoRecorder?

  override func viewDidLoad() {
    super.viewDidLoad()

    // Set the view's delegate
    sceneView.delegate = self

    // Show statistics such as fps and timing information
    sceneView.showsStatistics = true

    // Create a new scene
    let scene = SCNScene(named: "art.scnassets/ship.scn")!

    // Set the scene to the view
    sceneView.scene = scene

    // this example don't use audio
    var options = SceneKitVideoRecorder.Options.default
    options.useMicrophone = false
    options.horizontallyFlipped = true
    recorder = try! SceneKitVideoRecorder(scene: sceneView, options: options, setupAudio: false)
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    // Create a session configuration
    let configuration = ARWorldTrackingConfiguration()

    // Run the view's session
    sceneView.session.run(configuration)
  }

  @IBAction func startRecording (sender: UIButton) {
    sender.backgroundColor = .red
    _ = self.recorder?.startWriting()
  }

  @IBAction func stopRecording (sender: UIButton) {
    sender.backgroundColor = .white
    self.recorder?.finishWriting().onSuccess { [weak self] url in
      print("Recording Finished", url)
      self?.checkAuthorizationAndPresentActivityController(toShare: url, using: self!)
    }
  }

  private func checkAuthorizationAndPresentActivityController(toShare data: Any, using presenter: UIViewController) {
    switch PHPhotoLibrary.authorizationStatus() {
    case .authorized:
      let activityViewController = UIActivityViewController(activityItems: [data], applicationActivities: nil)
      activityViewController.excludedActivityTypes = [UIActivity.ActivityType.addToReadingList, UIActivity.ActivityType.openInIBooks, UIActivity.ActivityType.print]
      presenter.present(activityViewController, animated: true, completion: nil)
    case .restricted, .denied:
      let libraryRestrictedAlert = UIAlertController(title: "Photos access denied",
                                                     message: "Please enable Photos access for this application in Settings > Privacy to allow saving screenshots.",
                                                     preferredStyle: UIAlertController.Style.alert)
      libraryRestrictedAlert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
      presenter.present(libraryRestrictedAlert, animated: true, completion: nil)
    case .notDetermined:
      PHPhotoLibrary.requestAuthorization({ (authorizationStatus) in
        if authorizationStatus == .authorized {
          let activityViewController = UIActivityViewController(activityItems: [data], applicationActivities: nil)
            activityViewController.excludedActivityTypes = [UIActivity.ActivityType.addToReadingList, UIActivity.ActivityType.openInIBooks, UIActivity.ActivityType.print]
            presenter.present(activityViewController, animated: true, completion: nil)
        }
      })
    }
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)

    // Pause the view's session
    sceneView.session.pause()
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Release any cached data, images, etc that aren't in use.
  }

  // MARK: - ARSCNViewDelegate

  /*
   // Override to create and configure nodes for anchors added to the view's session.
   func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
   let node = SCNNode()

   return node
   }
   */

  func session(_ session: ARSession, didFailWithError error: Error) {
    // Present an error message to the user

  }

  func sessionWasInterrupted(_ session: ARSession) {
    // Inform the user that the session has been interrupted, for example, by presenting an overlay

  }

  func sessionInterruptionEnded(_ session: ARSession) {
    // Reset tracking and/or remove existing anchors if consistent tracking is required

  }
}
