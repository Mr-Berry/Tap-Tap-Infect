//
//  Zombie0.swift
//  Tap Tap Infect
//
//  Created by Jason Patrick Berry on 2017-06-10.
//  Copyright © 2017 Jason Patrick Berry. All rights reserved.
//

import Foundation
import SpriteKit

class Zombie0: SKShapeNode {
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let shadow = SKShapeNode(circleOfRadius: 5)
    shadow.fillColor = SKColor.black
    shadow.position = CGPoint(x: 0, y: -2)
    addChild(shadow)
}
