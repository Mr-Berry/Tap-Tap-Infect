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
    static let minRadius: Int = 8
    static let maxRadius: Int = 16
    static let turnTime: Int = 5
    static var numTapped: Int = 0
    static var maxTap: Int = 1
}

class Human {
    
    var health: Int = 0
    var healthMax: Int = 0
    var speed: Int = 0
    var radius: Int = 0
    var category: Int = 0
    var type: Int = 0
    
    var isAlive: Bool = true
    var canTurn: Bool = true
    var beingChased: Bool = false
    
    var shape: SKShapeNode = SKShapeNode()
    
    var starPath: CGPath = {
        let bezierPath = UIBezierPath()
        
        bezierPath.move(to: CGPoint(x: 0, y: 4))
        bezierPath.addLine(to: CGPoint(x: 0.88,y: 1.21))
        bezierPath.addLine(to: CGPoint(x: 3.8, y: 1.24))
        bezierPath.addLine(to: CGPoint(x: 1.43, y: -0.46))
        bezierPath.addLine(to: CGPoint(x: 2.35, y: -3.24))
        bezierPath.addLine(to: CGPoint(x: 0, y: -1.5))
        bezierPath.addLine(to: CGPoint(x: -2.35, y: -3.24))
        bezierPath.addLine(to: CGPoint(x: -1.43, y: -0.46))
        bezierPath.addLine(to: CGPoint(x: -3.8, y: 1.24))
        bezierPath.addLine(to: CGPoint(x: -0.88, y: 1.21))
        bezierPath.addLine(to: CGPoint(x: 0, y: 4))
        bezierPath.close()
        
        return bezierPath.cgPath
    }()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(category: Int, type: Int) {
        setHealth(category: category, type: type)
        setRadius()
        speed = 50/health
        shape = initShape(category: category)
        self.category = category
        self.type = type
        walk()
    }
    
    func initShape(category: Int) -> SKShapeNode {
        let shape = SKShapeNode(circleOfRadius: CGFloat(radius))
        switch category {
        case humanType.cop.rawValue:
            shape.fillColor = SKColor.blue
            shape.strokeColor = #colorLiteral(red: 0.09019608051, green: 0, blue: 0.3019607961, alpha: 1)
            break
        case humanType.military.rawValue:
            shape.fillColor = SKColor.green
            shape.strokeColor = #colorLiteral(red: 0.1960784346, green: 0.3411764801, blue: 0.1019607857, alpha: 1)
            break
        default:
            shape.fillColor = SKColor.white
            shape.strokeColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
            break
        }
        shape.position = CGPoint.zero
        shape.physicsBody = SKPhysicsBody(circleOfRadius: CGFloat(radius))
        shape.physicsBody?.restitution = 0
        shape.physicsBody?.linearDamping = 0.5
        shape.physicsBody?.friction = 0
        shape.physicsBody?.allowsRotation = false
        return shape
    }
    
    func addChild(scene: SKScene) {
        scene.addChild(shape)
    }
    
    private func attack() {
        
    }
    
    func position(position: CGPoint) {
        shape.position = position
    }
    
    func move(zombiePosition: CGPoint) {
        shape.removeAllActions()
        switch category {
        case humanType.civilian.rawValue:
            runAway(zombiePosition: zombiePosition)
            break
        default:
            attack()
            break
        }
    }
    
    func walk() {
        let direction = CGPoint(x: Int.random(min: -1, max: 1), y: Int.random(min: -1, max: 1))
        let vector = CGVector(dx: direction.x*CGFloat(speed), dy: direction.y*CGFloat(speed))
        let moveBy = SKAction.move(by: vector, duration: 3)
        let moveAgain = SKAction.run(walk)
        shape.run(SKAction.sequence([moveBy, moveAgain]))
    }
    
    func enterHouse() {
        
    }
    
    private func runAway(zombiePosition: CGPoint) {
        
    }
    
    private func setHealth(category: Int, type: Int) {
        
        switch category {
        case humanType.cop.rawValue:
            switch type {
            case attackType.ranged.rawValue:
                let healthMin = 3
                healthMax = 6
                health = Int.random(min: healthMin, max: healthMax)
                break
            case attackType.boss.rawValue:
                let healthMin = 6
                healthMax = 12
                health = Int.random(min: healthMin, max: healthMax)
                break
            default:
                let healthMin = 4
                healthMax = 7
                health = Int.random(min: healthMin, max: healthMax)
                break
            }
            break
        case humanType.military.rawValue:
            switch type {
            case attackType.boss.rawValue:
                let healthMin = 8
                healthMax = 15
                health = Int.random(min: healthMin, max: healthMax)
                break
            default:
                let healthMin = 4
                healthMax = 7
                health = Int.random(min: healthMin, max: healthMax)
                break
            }
            break
        default:
            switch type {
            case attackType.ranged.rawValue:
                let healthMin = 1
                healthMax = 2
                health = Int.random(min: healthMin, max: healthMax)
                break
            case attackType.boss.rawValue:
                let healthMin = 5
                healthMax = 9
                health = Int.random(min: healthMin, max: healthMax)
                break
            default:
                let healthMin = 2
                healthMax = 4
                health = Int.random(min: healthMin, max: healthMax)
                break
            }
            break
        }
    }
    
    private func setRadius() {
        if 3*health > HumanSettings.maxRadius {
            radius = HumanSettings.maxRadius
        } else if 3*health < HumanSettings.minRadius {
            radius = HumanSettings.minRadius
        } else {
            radius = 3*health
        }
    }
    
    func takeDamage(damage: Int) {
        health -= damage
        if health <= -healthMax {
            canTurn = false
            
        } else if health <= 0 {
            speed = 0
            isAlive = false
        }
    }
    
    func becomeZombie() {
        
    }
}
