//
//  Player.swift
//  ZappyGo
//
//  Created by Quentin Liardeaux on 6/25/19.
//  Copyright © 2019 Quentin Liardeaux. All rights reserved.
//

import SceneKit

enum BodyType {
    case head
    case body
    case arm
    case leg
}

enum Direction {
    case left
    case right
}

class BodyPart: SCNBox {
    
    var type: BodyType
    var direction: Direction?
    var size: SCNVector3
    
    override init() {
        type = .head
        size = SCNVector3Zero
        super.init()
    }

    convenience init(type: BodyType, width: CGFloat, height: CGFloat, length: CGFloat, direction: Direction? = nil) {
        self.init(width: width, height: height, length: length, chamferRadius: (type == .head) ? 1 : 0)
        self.type = type
        self.direction = direction
    }

    required init?(coder: NSCoder) {
        fatalError("Unable to init")
    }
}

class PlayerNode: SCNNode {

    private var head: SCNNode
    private var body: SCNNode
    private var leftArm: SCNNode
    private var rightArm: SCNNode
    private var leftLeg: SCNNode
    private var rightLeg: SCNNode

    init(proportion: CGFloat, color: UIColor) {
        head = SCNNode(geometry: BodyPart(type: .head, width: 0.1 * proportion,
                                          height:  0.1 * proportion, length: 0.1 * proportion))
        head.geometry?.firstMaterial?.diffuse.contents = color
        body = SCNNode(geometry: BodyPart(type: .body, width: 0.1 * proportion, height: 0.1 * proportion,
                                        length: 0.1 * proportion))
        body.geometry?.firstMaterial?.diffuse.contents = color
        leftArm = SCNNode(geometry: BodyPart(type: .arm, width: 0.1 * proportion, height: 0.1 * proportion,
                                           length: 0.1 * proportion, direction: .left))
        leftArm.geometry?.firstMaterial?.diffuse.contents = color
        rightArm = SCNNode(geometry: BodyPart(type: .arm, width: 0.1 * proportion, height: 0.1 * proportion,
                                           length: 0.1 * proportion, direction: .right))
        rightArm.geometry?.firstMaterial?.diffuse.contents = color
        leftLeg = SCNNode(geometry: BodyPart(type: .leg, width: 0.1 * proportion, height: 0.1 * proportion,
                                           length: 0.1 * proportion, direction: .left))
        leftLeg.geometry?.firstMaterial?.diffuse.contents = color
        rightLeg = SCNNode(geometry: BodyPart(type: .leg, width: 0.1 * proportion, height: 0.1 * proportion,
                                           length: 0.1 * proportion, direction: .right))
        rightLeg.geometry?.firstMaterial?.diffuse.contents = color
        super.init()
        addChildNode(head)
        addChildNode(body)
        addChildNode(leftArm)
        addChildNode(rightArm)
        addChildNode(leftLeg)
        addChildNode(rightLeg)
        head.position = SCNVector3(0, 0, 0) // x: forward y:left z:up
    }
    
    required init?(coder: NSCoder) {
        fatalError("Error with init")
    }
}
