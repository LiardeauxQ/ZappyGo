//
//  Tile.swift
//  ZappyGo
//
//  Created by Quentin Liardeaux on 6/25/19.
//  Copyright © 2019 Quentin Liardeaux. All rights reserved.
//

import SceneKit

class TileNode: SCNNode {

    private static let grassTexture = UIImage(named: "thumbnail.png")
    private var edgeNode: SCNNode
    private var resources: [ResourceNode]
    private var size: SCNVector3

    init(width: CGFloat, height: CGFloat, length: CGFloat) {
        edgeNode = SCNNode(geometry: SCNBox(width: width, height: height, length: length, chamferRadius: 0))

        edgeNode.geometry?.firstMaterial?.fillMode = .lines
        edgeNode.geometry?.firstMaterial?.diffuse.contents = UIColor.black
        resources = []
        size = SCNVector3(width, height, length)
        super.init()
        geometry = SCNBox(width: width, height: height, length: length, chamferRadius: 0)
        geometry?.firstMaterial?.diffuse.contents = TileNode.grassTexture
        addChildNode(edgeNode)
    }

    required init?(coder: NSCoder) {
        fatalError("Invalid init")
    }

    func add(resourceOfType type: ResourceType, withQuantity quantity: Int, radius: CGFloat = 0.01) {
        var newResource: ResourceNode

        for resource in resources {
            if (resource.type == type) {
                if (resource.quantity == 0 && quantity > 0) {
                    addChildNode(resource)
                }
                resource.quantity += quantity
                return
            }
        }
        newResource = ResourceNode(type: type, defaultQuantity: quantity, radius: CGFloat(size.x * 0.1))
        newResource.position = getRandomPosition()
        if newResource.quantity > 0 {
            addChildNode(newResource)
        }
        resources.append(newResource)
    }

    func getRandomPosition() -> SCNVector3 {
        print("\(position)")
        return SCNVector3(Float.random(in: 0 ..< size.x), Float.random(in: 0 ..< size.z), -(size.y / 2))
    }
}
