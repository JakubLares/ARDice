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

    var diceArray = [SCNNode]()
    var stackView = UIStackView()

    let rollAllButton: UIButton = {
        let button = UIButton()
        button.setTitle("Roll All!", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(rollAll), for: .touchUpInside)
        button.backgroundColor = .lightGray
        return button
    }()

    let removeAllButton: UIButton = {
        let button = UIButton()
        button.setTitle("Remove All!", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(removeAll), for: .touchUpInside)
        button.backgroundColor = .red
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        sceneView.delegate = self
        sceneView.autoenablesDefaultLighting  = true

        setupStackView()
        activateConstraints()
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

    private func setupStackView() {
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(rollAllButton)
        stackView.addArrangedSubview(removeAllButton)
        stackView.axis = .horizontal
        stackView.spacing = 10
        sceneView.addSubview(stackView)
    }

    private func activateConstraints() {
        NSLayoutConstraint.activate([
            stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            stackView.centerXAnchor.constraint(equalTo: sceneView.centerXAnchor),
            rollAllButton.widthAnchor.constraint(equalToConstant: 150),
            removeAllButton.widthAnchor.constraint(equalTo: rollAllButton.widthAnchor, multiplier: 1)
            ])
    }

    @objc private func rollAll() {
        diceArray.forEach { rollDice($0) }
    }

    @objc private func removeAll() {
        diceArray.forEach { $0.removeFromParentNode() }
        diceArray.removeAll()
    }

    private func rollDice(_ dice: SCNNode) {
        let randomX = Float(arc4random_uniform(4) + 1) * (Float.pi / 2)
        let randomZ = Float(arc4random_uniform(4) + 1) * (Float.pi / 2)
        dice.runAction(SCNAction.rotateBy(x: CGFloat(randomX * 5),
                                          y: 0,
                                          z: CGFloat(randomZ * 5),
                                          duration: 1))
    }

    private func addDice(atLocation location: ARHitTestResult?) {
        guard let location = location else { return }
        let diceScene = SCNScene(named: "art.scnassets/diceCollada.scn")
        guard let diceNode = diceScene?.rootNode.childNode(withName: "Dice", recursively: true) else { return }
        diceNode.position = SCNVector3(location.worldTransform.columns.3.x,
                                       location.worldTransform.columns.3.y + diceNode.boundingSphere.radius,
                                       location.worldTransform.columns.3.z)
        diceArray.append(diceNode)
        sceneView.scene.rootNode.addChildNode(diceNode)
        rollDice(diceNode)
    }

    private func createPlane(with planeAnchor: ARPlaneAnchor) -> SCNNode {
        let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
        let planeNode = SCNNode(geometry: plane)
        planeNode.position = SCNVector3(planeAnchor.extent.x, 0, planeAnchor.extent.z)
        planeNode.transform = SCNMatrix4MakeRotation(-Float.pi / 2, 1, 0, 0)
        let gridMaterial = SCNMaterial()
        gridMaterial.diffuse.contents = UIImage(named: "art.scnassets/grid.png")
        plane.materials = [gridMaterial]
        return planeNode
    }

    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        rollAll()
    }
}

extension ViewController: ARSCNViewDelegate {

    public func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        node.addChildNode(createPlane(with: planeAnchor))
    }

    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let touchLocation = touch.location(in: sceneView)
        let results = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
        addDice(atLocation: results.first)
    }
}
