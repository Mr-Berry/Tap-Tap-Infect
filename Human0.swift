//
//  Human0.swift
//  Tap Tap Infect
//
//  Created by Jason Patrick Berry on 2017-06-11.
//  Copyright © 2017 Jason Patrick Berry. All rights reserved.
//

import Foundation
import SpriteKit

class Human0 {
    
    var health: Int = 3             //three attacks and you are out
    static var MaxSpeed: Int = 10   //pixels per second
    var speed: Int = MaxSpeed
    
    var isAlive: Bool = true
    var canTurn: Bool = true
    
    static var brainChance: Float = 0.05    //chance that a zombie will drop a brain (currency)
    
    let radius: Int = 5
    let shadowOffset: Int = -2
    
    let shadow: SKShapeNode
    let shape: SKShapeNode
    
    init(color: UIColor) {
        let shadow = SKShapeNode(circleOfRadius: CGFloat(radius))
        let shape = SKShapeNode(circleOfRadius: CGFloat(radius))
        shadow.fillColor = SKColor.black
        shape.fillColor = color
        shape.strokeColor = SKColor.clear
        shape.position = CGPoint.zero
        shadow.position = CGPoint(x: 0, y: shape.position.y + CGFloat(shadowOffset))
        self.shadow = shadow
        self.shape = shape
    }
    
    func addChild(scene: SKScene) {
        scene.addChild(shadow)
        scene.addChild(shape)
    }
    
    func move() {
        
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
