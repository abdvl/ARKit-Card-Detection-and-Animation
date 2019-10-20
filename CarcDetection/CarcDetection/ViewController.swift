//
//  ViewController.swift
//  CarcDetection
//
//  Created by Aikepaer Abuduweili on 10/19/19.
//  Copyright © 2019 Aikepaer Abuduweili. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    var heartNode:SCNNode?
    var diamondNode:SCNNode?
    var imageNodes = [SCNNode]()
    
    var isJumping = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.delegate = self
        sceneView.automaticallyUpdatesLighting = true
        let heartScene = SCNScene(named: "art.scnassets/heart.scn")
        let diamondScene = SCNScene(named: "art.scnassets/diamond.scn")
        heartNode = heartScene?.rootNode
        diamondNode = diamondScene?.rootNode
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let configuration = ARImageTrackingConfiguration()
        
        if let trackingImages = ARReferenceImage.referenceImages(inGroupNamed: "cards", bundle:Bundle.main){
            configuration.trackingImages = trackingImages
            configuration.maximumNumberOfTrackedImages = 2
        }

        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
        
        if let imageAnchor = anchor as? ARImageAnchor {
            let size = imageAnchor.referenceImage.physicalSize
            let plane = SCNPlane(width: size.width, height: size.height)
            plane.firstMaterial?.diffuse.contents = UIColor.white.withAlphaComponent(0.5)
            plane.cornerRadius = 0.005
            let planeNode = SCNNode(geometry: plane)
            planeNode.eulerAngles.x = -.pi/2
            node.addChildNode(planeNode)
            
            
            var shapeNode:SCNNode?
            
            if imageAnchor.referenceImage.name == "cao" {
                shapeNode = heartNode
            }else{
                shapeNode = diamondNode
            }
            
            guard let shape = shapeNode else {return nil}
            
            
            let shapeSpin = SCNAction.rotateBy(x: 0, y: 2 * .pi, z: 0, duration: 10)
            let reapeatSpin = SCNAction.repeatForever(shapeSpin)
            shapeNode?.runAction(reapeatSpin)
            
            node.addChildNode(shape)
            imageNodes.append(node)
            return node
        }
        
        
        return nil
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        if imageNodes.count == 2 {
            let positionOne = SCNVector3ToGLKVector3(imageNodes[0].position)
            let positionSecond = SCNVector3ToGLKVector3(imageNodes[1].position)
            
            let distance = GLKVector3Distance(positionOne, positionSecond)
            print(distance)
            
            if distance < 0.10 {
                spinJump(node: imageNodes[0])
                spinJump(node: imageNodes[1])
                isJumping = true
            }else{
                isJumping = false
            }
            
        }
    }
    
    func spinJump (node:SCNNode){
        
        if isJumping {return}
        
        let shapeNode = node.childNodes[1]
        
        let action  = SCNAction.rotateBy(x: 0, y: 2 * .pi, z: 0, duration: 1)
        action.timingMode = .easeInEaseOut
        
        let up = SCNAction.moveBy(x: 0, y: 0.03, z: 0, duration: 0.5)
        up.timingMode = .easeInEaseOut
        
        let down = up.reversed()
        
        let updown = SCNAction.sequence([up, down])
        shapeNode.runAction(action)
        shapeNode.runAction(updown)
    }

}
