//
//  Resource.swift
//  ZappyGo
//
//  Created by Quentin Liardeaux on 6/25/19.
//  Copyright © 2019 Quentin Liardeaux. All rights reserved.
//

import SceneKit

enum ResourceType: Int, CaseIterable {
    case Food;
    case Linemate;
    case Deraumere;
    case Sibur;
    case Mendiane;
    case Phiras;
    case Thystame;
    
    func getColor() -> UIColor {
        switch self {
        case .Food:
            return UIColor.green
        case .Linemate:
            return UIColor.purple
        case .Deraumere:
            return UIColor.blue
        case .Sibur:
            return UIColor.red
        case .Mendiane:
            return UIColor.orange
        case .Phiras:
            return UIColor.yellow
        case .Thystame:
            return UIColor.brown
        }
    }
}

class ResourceNode: SCNNode {
    
    var quantity: Int = 0
    var type: ResourceType
    
    init(type: ResourceType, defaultQuantity: Int, radius: CGFloat = 0.01) {
        self.type = type
        quantity = defaultQuantity
        super.init()
        geometry = SCNSphere(radius: radius)
        geometry?.firstMaterial?.diffuse.contents = type.getColor()
    }
    
    required init?(coder: NSCoder) {
        fatalError("Unable to init resource")
    }
}
