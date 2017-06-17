//
//  Human0.swift
//  Tap Tap Infect
//
//  Created by Jason Patrick Berry on 2017-06-11.
//  Copyright © 2017 Jason Patrick Berry. All rights reserved.
//

import Foundation
import SpriteKit

class Civilian_Melee {
    
    var health: Int = 3             //three attacks and you are out
    static var MaxSpeed: Int = 10   //pixels per second
    var speed: Int = 5
    var direction: CGPoint = CGPoint.zero
    var zombiePosition: CGPoint = CGPoint.zero
    
    var isAlive: Bool = true
    var canTurn: Bool = true
    var beingChased: Bool = false
    
    static var brainChance: Float = 0.05    //chance that a zombie will drop a brain (currency)
    
    let radius: Int = 5
    let shadowOffset: Int = 2
    
    var shape: SKShapeNode
    var accent: SKShapeNode
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    init() {
        let shape = SKShapeNode(circleOfRadius: CGFloat(radius))
        shape.fillColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
        shape.strokeColor = #colorLiteral(red: 0.1960784346, green: 0.3411764801, blue: 0.1019607857, alpha: 1)
        shape.position = CGPoint.zero
        let accent = SKShapeNode(circleOfRadius: CGFloat(radius/2))
        accent.fillColor = #colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1)
        accent.position = CGPoint.zero
        self.shape = shape
        self.accent = accent
        self.shape.addChild(accent)

        move()
    }
    
    
    func addChild(scene: SKScene) {
        scene.addChild(shape)
    }
    
    
    func position(position: CGPoint) {
        shape.position = position
    }
    
    
    func move() {
        if beingChased {
            runAway()
        } else {
            walk()
        }
    }
    
    
    func walk() {
        direction = CGPoint(x: Int.random(min: -1, max: 1), y: Int.random(min: -1, max: 1))
        let vector = CGVector(dx: direction.x*CGFloat(5), dy: direction.y*CGFloat(5))
        let moveBy = SKAction.move(by: vector, duration: 1)
        let moveAgain = SKAction.run(walk)
        shape.run(SKAction.sequence([moveBy, moveAgain]))
    }
    
    
    func enterHouse() {
        
    }
    
    
    func runAway() {
        
    }
    
    
    func takeDamage() {
        health -= 1
        if health <= 0 {
            speed = 0
        }
        if health <= -3 {
            
        }
    }
}
