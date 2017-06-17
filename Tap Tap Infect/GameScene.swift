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

        let civilian = Civilian_Melee()
        civilian.addChild(scene: self)
        
        let zombie = Zombie0()
        zombie.position(position: CGPoint(x: -10, y: 0))
        zombie.addChild(scene: self)
    }
}
