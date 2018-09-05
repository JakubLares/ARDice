//
//  ViewController.swift
//  ARDice
//
//  Created by Jakub Lares on 04.09.18.
//  Copyright © 2018 Jakub Lares. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController {

    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        sceneView.delegate = self
        sceneView.autoenablesDefaultLighting  = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
}

extension ViewController: ARSCNViewDelegate {

    public func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
        let planeNode = SCNNode(geometry: plane)
        planeNode.position = SCNVector3(planeAnchor.extent.x, 0, planeAnchor.extent.z)
        planeNode.transform = SCNMatrix4MakeRotation(-Float.pi / 2, 1, 0, 0)
        let gridMaterial = SCNMaterial()
        gridMaterial.diffuse.contents = UIImage(named: "art.scnassets/grid.png")
        plane.materials = [gridMaterial]
        node.addChildNode(planeNode)
    }

    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let touchLocation = touch.location(in: sceneView)
        let results = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
        guard let hitResult = results.first else { return }
        let diceScene = SCNScene(named: "art.scnassets/diceCollada.scn")
        guard let diceNode = diceScene?.rootNode.childNode(withName: "Dice", recursively: true) else { return }
        diceNode.position = SCNVector3(hitResult.worldTransform.columns.3.x,
                                       hitResult.worldTransform.columns.3.y + diceNode.boundingSphere.radius,
                                       hitResult.worldTransform.columns.3.z)
        sceneView.scene.rootNode.addChildNode(diceNode)
        let randomX = Float(arc4random_uniform(4) + 1) * (Float.pi / 2)
        let randomZ = Float(arc4random_uniform(4) + 1) * (Float.pi / 2)
        diceNode.runAction(SCNAction.rotateBy(x: CGFloat(randomX * 5),
                                              y: 0,
                                              z: CGFloat(randomZ * 5),
                                              duration: 1))
    }
}
