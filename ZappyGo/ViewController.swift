//
//  ViewController.swift
//  ZappyGo
//
//  Created by Quentin Liardeaux on 6/17/19.
//  Copyright © 2019 Quentin Liardeaux. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    var mapNode: Map?
    var serverCommunication: ServerCommunication?

    override func viewDidLoad() {
        super.viewDidLoad()

        sceneView.delegate = self
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        sceneView.showsStatistics = true
        sceneView.autoenablesDefaultLighting = true;
        //let scene = ZappyScene()
        let scene = SCNScene()
        
        sceneView.scene = scene
        view.addSubview(sceneView)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        configuration.planeDetection = .horizontal
        sceneView.session.run(configuration)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    // MARK: - ARSCNViewDelegate

    // Override to create and configure nodes for anchors added to the view's session.

    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        
        if mapNode == nil {
            mapNode = Map(anchor: planeAnchor)
            serverCommunication?.delegate = self
        }

        node.enumerateChildNodes { (node, _) in
            node.removeFromParentNode()
        }
        node.addChildNode(mapNode!)
    }

    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        guard let _ = anchor as? ARPlaneAnchor else { return }

        node.enumerateChildNodes { (node, _) in
            node.removeFromParentNode()
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

extension ViewController: ServerDelegate {
    func receive(map: srv_map_size_t) {
        mapNode?.addTiles(xTiles: Int(map.x), zTiles: Int(map.y))
    }
    
    func receive(tile: srv_tile_content_t) {
        let resources: [Int] = [Int(tile.q0), Int(tile.q1), Int(tile.q2), Int(tile.q3),
                                Int(tile.q4), Int(tile.q5), Int(tile.q6)]

        mapNode?.addResources(x: Int(tile.x), y: Int(tile.y), quantities: resources)
    }
}
