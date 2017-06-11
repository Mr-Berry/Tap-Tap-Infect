//
//  GameScene.swift
//  Tap Tap Infect
//
//  Created by Jason Patrick Berry on 2017-06-10.
//  Copyright © 2017 Jason Patrick Berry. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    override func didMove(to view: SKView) {

        let shape = SKShapeNode(circleOfRadius: 5)
        shape.fillColor = SKColor.red
        shape.strokeColor = SKColor.clear
        shape.position = CGPoint(x: 0, y: 0)
        addChild(shape)
    }
}
