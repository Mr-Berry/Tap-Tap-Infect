//
//  Zombie0.swift
//  Tap Tap Infect
//
//  Created by Jason Patrick Berry on 2017-06-10.
//  Copyright © 2017 Jason Patrick Berry. All rights reserved.
//

import Foundation
import SpriteKit

class Zombie0 {
    static let radius: Int = 5
    static let shadowOffset: Int = -2
    
    let shadow = SKShapeNode(circleOfRadius: CGFloat(radius))
    shadow.fillColor = SKColor.black
    shadow.position = CGPoint(x: 0, y: shadowOffset)
    self.addChild(shadow)
    let shape = SKShapeNode(circleOfRadius: CGFloat(radius))
    shape.fillColor = SKColor.red
    shape.strokeColor = SKColor.clear
    shape.position = CGPoint.zero
    self.addChild(shape)
}
