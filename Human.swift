//
//  Human.swift
//  Tap Tap Infect
//
//  Created by Jason Patrick Berry on 2017-06-17.
//  Copyright © 2017 Jason Patrick Berry. All rights reserved.
//

import Foundation
import SpriteKit

enum HumanSettings {
    static var attackRate: Int = 2
    static var humanMaxPop: Int = 10
    static var humanStartPop: Int = 3
    static var copChance: Int = 10
    static var militaryChance: Int = 0
    static let minRadius: Int = 6
    static let maxRadius: Int = 10
    static var maxTap: Int = 1
    static var numTapped: Int = 0
    static var spawnFreq: Int = 10
    static let turnTime: Int = 5
}

class Human {
    
    var damage: Int = 0
    var health: Int = 0
    var healthMax: Int = 0
    var speed: CGFloat = 0
    var radius: Int = 0
    var maxRange: CGFloat = 0
    var category: Int = 0
    var type: Int = 0
    var closestHuman: CGFloat = 0
    
    var isAlive: Bool = true
    var canTurn: Bool = true
    var beingChased: Bool = false
    
    var shape: SKShapeNode = SKShapeNode()
    var range: SKShapeNode = SKShapeNode()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(category: Int, type: Int) {
        setHealth(category: category, type: type)
        setRadius()
        speed = CGFloat(40/health)
        shape = initShape(category: category)
        setRange()
        self.category = category
        self.type = type
    }
    
    func addChild(scene: SKScene) {
        scene.addChild(shape)
    }
    
    func attack(human: Human) {
        human.takeDamage(damage)
    }
    
    func becomeZombie() {
        shape.fillColor = .red
        isAlive = false
    }
    
    func chase(human: Human) {
        shape.removeAction(forKey: "walk")
        if shape.action(forKey: "chase") == nil {
            let offset = human.shape.position - shape.position
            let direction = offset/offset.length()
            let vector = CGVector(dx: 2*direction.x*speed, dy: 2*direction.y*speed)
            let chase = SKAction.move(by: vector, duration: 1)
            let clean = SKAction.run { self.shape.removeAllActions() }
            shape.run(SKAction.sequence([chase,clean,SKAction.run{ self.walk() }]), withKey: "chase")
        }
    }
    
    func flash(color: CIColor) {
        let o_color = shape.fillColor
        let midBrightness = SKAction.run {
            self.shape.fillColor = UIColor(ciColor: CIColor(red: color.red*0.5, green: color.green*0.5, blue: color.blue*0.5))
        }
        let maxBrightness = SKAction.run { self.shape.fillColor = UIColor(ciColor: color) }
        let original = SKAction.run { self.shape.fillColor = o_color }
        let wait = SKAction.wait(forDuration: 0.25)
        shape.run(SKAction.sequence([wait,midBrightness,wait,maxBrightness,wait,midBrightness,wait,original]))
    }
    
    func initShape(category: Int) -> SKShapeNode {
        let shape = SKShapeNode(circleOfRadius: CGFloat(radius))
        switch category {
        case humanType.cop.rawValue:
            shape.fillColor = .blue
            shape.strokeColor = #colorLiteral(red: 0.09019608051, green: 0, blue: 0.3019607961, alpha: 1)
            break
        case humanType.military.rawValue:
            shape.fillColor = .green
            shape.strokeColor = #colorLiteral(red: 0.1960784346, green: 0.3411764801, blue: 0.1019607857, alpha: 1)
            break
        default:
            shape.fillColor = .white
            shape.strokeColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
            break
        }
        shape.position = CGPoint.zero
        shape.zPosition = 5
        shape.alpha = 0
        shape.physicsBody = SKPhysicsBody(circleOfRadius: CGFloat(radius))
        shape.physicsBody?.restitution = 0
        shape.physicsBody?.linearDamping = 0.5
        shape.physicsBody?.friction = 0
        shape.physicsBody?.allowsRotation = false
        return shape
    }
    
    func position(position: CGPoint) {
        shape.position = position
    }
    
    func runAway(zombiePosition: CGPoint) {
        shape.removeAction(forKey: "walk")
        if shape.action(forKey: "runAway") == nil{
            let offset = zombiePosition - shape.position
            let direction = offset/offset.length()
            let vector = CGVector(dx: -2*direction.x*speed,
                                  dy: -2*direction.y*speed)
            let run = SKAction.move(by: vector, duration: 1)
            let clean = SKAction.run { self.shape.removeAllActions() }
            shape.run(SKAction.sequence([run,clean,SKAction.run{ self.walk() }]), withKey: "runAway")
        }
    }
    
    func setHealth(category: Int, type: Int) {
        
        switch category {
        case humanType.cop.rawValue:
            switch type {
            case attackType.ranged.rawValue:
                let healthMin = 3
                healthMax = 6
                health = Int.random(min: healthMin, max: healthMax)
            default:
                let healthMin = 4
                healthMax = 7
                health = Int.random(min: healthMin, max: healthMax)
            }
        case humanType.military.rawValue:
            let healthMin = 4
            healthMax = 7
            health = Int.random(min: healthMin, max: healthMax)
        default:
            switch type {
            case attackType.ranged.rawValue:
                let healthMin = 1
                healthMax = 2
                health = Int.random(min: healthMin, max: healthMax)
            default:
                let healthMin = 2
                healthMax = 4
                health = Int.random(min: healthMin, max: healthMax)
            }
        }
    }
    
    func setRadius() {
        if 3*health > HumanSettings.maxRadius {
            radius = HumanSettings.maxRadius
        } else if 3*health < HumanSettings.minRadius {
            radius = HumanSettings.minRadius
        } else {
            radius = 3*health
        }
    }
    
    func setRange() {
        maxRange = CGFloat(15*radius)
        range = SKShapeNode(circleOfRadius: maxRange)
        range.strokeColor = .black
        range.fillColor = .clear
        shape.addChild(range)
    }
    
    func takeDamage(_ damage: Int) {
        if isAlive {
            flash(color: CIColor(red: 255, green: 0, blue: 0))
        } else {
            flash(color: CIColor(red: 0, green: 0, blue: 0))
        }
        health -= damage
        if health <= -healthMax {
            canTurn = false
            
        } else if health <= 0 {
            speed = 0
            isAlive = false
        }
    }
    
    func updateHuman() {
        if beingChased && !shape.hasActions(){
            beingChased = false
            walk()
        }
    }
    
    func walk() {
        let direction = CGPoint(x: Int.random(min: -1, max: 1), y: Int.random(min: -1, max: 1))
        let vector = CGVector(dx: direction.x*CGFloat(speed), dy: direction.y*CGFloat(speed))
        let moveBy = SKAction.move(by: vector, duration: 5)
        let moveAgain = SKAction.run(walk)
        shape.run(SKAction.sequence([moveBy, moveAgain]), withKey: "walk")
    }
}
