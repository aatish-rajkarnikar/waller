//
//  ViewController.swift
//  waller
//
//  Created by Aatish Rajkarnikar on 11/20/17.
//  Copyright © 2017 Aatish Rajkarnikar. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    var currentIndex = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        sceneView.automaticallyUpdatesLighting = true
        sceneView.autoenablesDefaultLighting = true
        // Create a new scene
        let scene = SCNScene()
        
        // Set the scene to the view
        sceneView.scene = scene
        
        self.sceneView.debugOptions = ARSCNDebugOptions.showFeaturePoints
        
        let previousButton = UIButton(frame: CGRect(x: 16, y: view.frame.height - 100, width: 100, height: 40))
        previousButton.setTitle("Previous", for: .normal)
        previousButton.addTarget(self, action: #selector(prev), for: .touchUpInside)
        view.addSubview(previousButton)
        
        let nextButton = UIButton(frame: CGRect(x: view.frame.width - 116, y: view.frame.height - 100, width: 100, height: 40))
        nextButton.setTitle("Next", for: .normal)
        nextButton.addTarget(self, action: #selector(changeToNext), for: .touchUpInside)
        view.addSubview(nextButton)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        // Run the view's session
        sceneView.session.run(configuration)
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
    
    @objc func changeToNext(){
        if currentIndex < 3 {
            currentIndex += 1
        }else{
            currentIndex = 1
        }
        for item in self.sceneView.scene.rootNode.childNodes {
            let material = SCNMaterial()
            material.diffuse.contents = UIImage(named: String(currentIndex))
            item.geometry?.replaceMaterial(at: 0, with: material)
        }
    }
    
    @objc func prev(){
        if currentIndex > 1 {
            currentIndex -= 1
        }else{
            currentIndex = 3
        }
        for item in self.sceneView.scene.rootNode.childNodes {
            let material = SCNMaterial()
            material.diffuse.contents = UIImage(named: String(currentIndex))
            item.geometry?.replaceMaterial(at: 0, with: material)
        }
    }

    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            print("Unable to identify touches on any plane. Ignoring interaction...")
            return
        }
        let touchPoint = touch.location(in: sceneView)
        let hitTestResults = sceneView.hitTest(touchPoint, types: .featurePoint )
        
        if let result = hitTestResults.first {
            for item in self.sceneView.scene.rootNode.childNodes {
                item.removeFromParentNode()
            }
            
            let position = SCNVector3.positionFrom(matrix: result.worldTransform)
            let plane = SCNPlane(width: 1, height: 1)
            let material = SCNMaterial()
            material.diffuse.contents = UIImage(named: String(currentIndex))
            plane.materials = [material]
            let node = SCNNode(geometry: plane)
            node.position = position
            
            let pitch = sceneView.session.currentFrame?.camera.eulerAngles.x
            let yawn = sceneView.session.currentFrame?.camera.eulerAngles.y
            let roll = sceneView.session.currentFrame?.camera.eulerAngles.z
            let newRotation = SCNVector3Make(0, yawn!, 0)
            node.eulerAngles = newRotation
            self.sceneView.scene.rootNode.addChildNode(node)
            
        }
    }
    
    
    
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

extension SCNVector3 {
    
    static func positionFrom(matrix: matrix_float4x4) -> SCNVector3 {
        let column = matrix.columns.3
        return SCNVector3(column.x, column.y, column.z)
    }
}
