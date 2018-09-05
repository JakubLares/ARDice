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

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        sceneView.delegate = self
        sceneView.autoenablesDefaultLighting  = true
        let diceScene = SCNScene(named: "art.scnassets/diceCollada.scn")
        guard let diceNode = diceScene?.rootNode.childNode(withName: "Dice", recursively: true) else { return }
        diceNode.position = SCNVector3(0, 0, -0.1)
        sceneView.scene.rootNode.addChildNode(diceNode)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let configuration = ARWorldTrackingConfiguration()
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
}
