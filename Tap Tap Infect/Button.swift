//
//  Button.swift
//  Tap Tap Infect
//
//  Created by Jason Patrick Berry on 2017-07-03.
//  Copyright © 2017 Jason Patrick Berry. All rights reserved.
//

import Foundation
import SpriteKit
import UIKit

class Button: SKSpriteNode{
    
    var button: SKShapeNode = SKShapeNode()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
    }
}
