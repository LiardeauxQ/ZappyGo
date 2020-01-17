//
//  Map.swift
//  ZappyGo
//
//  Created by Quentin Liardeaux on 6/25/19.
//  Copyright © 2019 Quentin Liardeaux. All rights reserved.
//

import SceneKit
import ARKit

class Map: SCNNode {

    var tiles: [[TileNode]];
    private var anchor: ARPlaneAnchor
    private var waitingResources: [(x: Int, y: Int, quantities: [Int])]

    init(anchor: ARPlaneAnchor) {
        tiles = []
        waitingResources = []
        self.anchor = anchor
        super.init()
        self.geometry = SCNPlane(width: CGFloat(anchor.extent.x), height: CGFloat(anchor.extent.x))
        self.geometry?.firstMaterial?.diffuse.contents = UIColor.brown
        self.position = SCNVector3(anchor.center.x, 0, anchor.center.z)
        self.geometry?.firstMaterial?.isDoubleSided = true
        self.eulerAngles = SCNVector3(Double.pi / 2, 0, 0)
    }
    
    func addTiles(xTiles: Int, zTiles: Int) {
        let tileWidthSize = anchor.extent.x / Float(xTiles)
        let tileHeightSize = anchor.extent.x / Float(zTiles)
        
        for x in 0 ..< xTiles {
            tiles.append([])
            for z in 0 ..< zTiles {
                let xOffset = (-anchor.extent.x / 2) + (tileWidthSize / 2)
                let yOffset = (-anchor.extent.x / 2) + (tileHeightSize / 2)
                
                tiles[x].append(TileNode(width: CGFloat(tileWidthSize),
                                         height: 0.1,
                                         length: CGFloat(tileHeightSize)))
                tiles[x][z].position = SCNVector3(xOffset + (Float(x) * tileWidthSize),
                                                  yOffset + (Float(z) * tileHeightSize), 0)
                tiles[x][z].geometry?.firstMaterial?.lightingModel = .constant
                tiles[x][z].add(resourceOfType: .Food, withQuantity: 2)
                tiles[x][z].add(resourceOfType: .Mendiane, withQuantity: 1)
                addChildNode(tiles[x][z])
            }
        }
        for resource in waitingResources {
            addResources(x: resource.x, y: resource.y, quantities: resource.quantities)
        }
        waitingResources.removeAll()
    }
    
    func addResources(x: Int, y: Int, quantities: [Int]) {
        for i in 0 ..< quantities.count {
            if (tiles.count < x || tiles[x].count < y) {
                waitingResources.append((x, y, quantities))
                return
            }
            tiles[x][y].add(resourceOfType: ResourceType(rawValue: i)!, withQuantity: quantities[i])
        }
    }

    required init?(coder: NSCoder) {
        fatalError("Unable to init")
    }
}
