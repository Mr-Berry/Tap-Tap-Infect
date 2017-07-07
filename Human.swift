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
    static var brainChance: Int = 50
    static var combinedChance: Int = 0
    static var bulletSpeed: CGFloat = 300
    static var copChance: Int = 10
    static var humanMaxPop: Int = 50
    static var humanStartPop: Int = 10
    static let maxRadius: Int = 15
    static var militaryChance: Int = 10
    static let minRadius: Int = 10
    static var numTapped: Int = 0
    static var spawnFreq: Int = 5
    static let turnTime: Int = 3
    static var zChance: Int = 50
    static var scaleAmount: CGFloat = 0.4
}

class Human {
    
    var damage: Int = 1
    var health: Int = 0
    var healthMax: Int = 0
    var speed: CGFloat = 0
    var zSpeedFactor: CGFloat = 1
    var radius: Int = 0
    var maxRange: CGFloat = 0
    var category: Int = 0
    var type: Int = 0
    var closestHuman: CGFloat = 0
    
    var isAlive: Bool = true
    var canTurn: Bool = true
    var wantsBrainz: Bool = false
    
    var color = UIColor()
    
    var shape: SKShapeNode = SKShapeNode()
    var bullet: SKShapeNode = SKShapeNode()
    var accent: SKSpriteNode = SKSpriteNode()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(category: Int, type: Int) {
        setHealth(category: category, type: type)
        setRadius()
        speed = CGFloat(30/health)
        shape = initShape(category: category)
        setRange()
        self.category = category
        self.type = type
        bullet = SKShapeNode(circleOfRadius: 2)
        bullet.fillColor = .white
        bullet.alpha = 0
        bullet.zPosition = 50
    }
    
    func addChild(scene: SKScene) {
        scene.addChild(shape)
        scene.addChild(bullet)
    }
    
    func attack(human: Human) {
        switch human.category {
        case humanType.cop.rawValue:
            human.takeDamage(damage)
            break
        case humanType.military.rawValue:
            human.takeDamage(damage)
            break
        default:
            human.takeDamage(damage)
        }
    }
    
    func becomeZombie() {
        color = SKColorWithRGBA(255 , g: 0, b: 0, a: 120)
        shape.fillColor = color
        isAlive = true
        canTurn = false
        health = healthMax
        accent.texture = SKTexture(imageNamed: "zombie")
        walk()
    }
    
    func chase(_ human: Human) {
        if isAlive && human.isAlive{
            shape.removeAction(forKey: "walk")
            shape.removeAction(forKey: "run")
            if shape.action(forKey: "chase") == nil {
                let offset = human.shape.position - shape.position
                let direction = offset/offset.length()
                let angle = direction.angle
                accent.run(SKAction.rotate(toAngle: angle, duration: 0.3))
                let vector = CGVector(dx: 2*direction.x*speed, dy: 2*direction.y*speed)
                let chase = SKAction.move(by: vector, duration: 1)
                let clean = SKAction.run { self.shape.removeAction(forKey: "chase")}
                shape.run(SKAction.sequence([chase,clean,SKAction.run{ self.walk() }]), withKey: "chase")
            }
        }
        if Int((human.shape.position - shape.position).length()) <= radius + human.radius && shape.action(forKey: "attack") == nil {
            let clean = SKAction.run { self.shape.removeAction(forKey: "attack") }
            let attack = SKAction.sequence([SKAction.run { self.attack(human: human) },
                                            SKAction.wait(forDuration: TimeInterval(HumanSettings.attackRate)), clean])
            shape.run(attack, withKey: "attack")
        }
    }
    
    func flash(color: CIColor) {
        if shape.action(forKey: "flash") == nil {
            let clean = SKAction.run { self.shape.removeAction(forKey: "flash") }
            let maxBrightness = SKAction.run { self.shape.fillColor = UIColor(ciColor: color) }
            let original = SKAction.run { self.shape.fillColor = self.color }
            let wait = SKAction.wait(forDuration: 0.1)
            shape.run(SKAction.sequence([wait,maxBrightness,wait,original,original,wait,clean]), withKey: "flash")
        }
    }
    
    func initShape(category: Int) -> SKShapeNode {
        let shape = SKShapeNode(circleOfRadius: CGFloat(radius))
        switch category {
        case humanType.cop.rawValue:
            color = SKColorWithRGBA(0 , g: 64, b: 128, a: 120)
            shape.fillColor = color
            accent = SKSpriteNode(imageNamed: "cop")
        case humanType.military.rawValue:
            color = SKColorWithRGBA(0 , g: 128, b: 0, a: 120)
            shape.fillColor = color
            accent = SKSpriteNode(imageNamed: "military")
        default:
            color = SKColorWithRGBA(255 , g: 255, b: 255, a: 120)
            shape.fillColor = color
            accent = SKSpriteNode(imageNamed: "civilian")
        }
        shape.strokeColor = .clear
        shape.position = CGPoint.zero
        shape.zPosition = 5
        shape.alpha = 0
        shape.physicsBody = SKPhysicsBody(circleOfRadius: CGFloat(radius))
        shape.physicsBody?.restitution = 0.2
        shape.physicsBody?.linearDamping = 0.5
        shape.physicsBody?.friction = 0
        shape.physicsBody?.allowsRotation = false
        accent.setScale(HumanSettings.scaleAmount)
        shape.addChild(accent)
        return shape
    }
    
    func moveToPoint(point: CGPoint) {
        shape.removeAction(forKey: "walk")
        shape.removeAction(forKey: "run")
        if !shape.hasActions() {
            let distance = point.length()
            let direction = point/distance
            let angle = direction.angle
            accent.run(SKAction.rotate(toAngle: angle, duration: 0.3))
            let vector = CGVector(dx: 6*direction.x*speed, dy: 6*direction.y*speed)
            let run = SKAction.move(by: vector, duration: 3)
            let clean = SKAction.run { self.shape.removeAction(forKey: "run")}
            shape.run(SKAction.sequence([run,clean,SKAction.run{ self.walk() }]), withKey: "run")
        }
    }
    
    func position(position: CGPoint) {
        shape.position = position
    }
    
    func react(zombie: Human) {
        switch category {
        case humanType.military.rawValue:
            shoot(zombie: zombie)
        case humanType.cop.rawValue:
            chase(zombie)
        default:
            runAway(zombiePosition: zombie.shape.position)
        }
    }
    
    func rollDice() {
        if canTurn {
            let chance = Int.random(min: 1, max: 100)
            if chance < HumanSettings.zChance {
                becomeZombie()
            } else {
                canTurn = false
            }
        }
    }
    
    func runAway(zombiePosition: CGPoint) {
        if isAlive {
            shape.removeAction(forKey: "walk")
            if shape.action(forKey: "runAway") == nil{
                let offset = zombiePosition - shape.position
                let direction = offset/offset.length()
                let angle = direction.angle
                accent.run(SKAction.rotate(toAngle: angle+π, duration: 0.3))
                let vector = CGVector(dx: -2*direction.x*speed,
                                      dy: -2*direction.y*speed)
                let run = SKAction.move(by: vector, duration: 1)
                let clean = SKAction.run { self.shape.removeAction(forKey: "runAway") }
                shape.run(SKAction.sequence([run,clean,SKAction.run{ self.walk() }]), withKey: "runAway")
            }
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
        if 4*health > HumanSettings.maxRadius {
            radius = HumanSettings.maxRadius
        } else if 4*health < HumanSettings.minRadius {
            radius = HumanSettings.minRadius
        } else {
            radius = 4*health
        }
    }
    
    func setRange() {
        maxRange = CGFloat(20*radius)
    }
    
    func shoot(zombie: Human) {
        if isAlive && zombie.isAlive{
            shape.removeAction(forKey: "walk")
            if bullet.action(forKey: "shoot") == nil {
                let offset = zombie.shape.position - shape.position
                let direction = offset/offset.length()
                let angle = direction.angle
                accent.run(SKAction.rotate(toAngle: angle, duration: 0.2))
                spawnBullet(direction: direction)
                let travelTime = offset.length()/HumanSettings.bulletSpeed
                let travel = SKAction.move(to: zombie.shape.position, duration: TimeInterval(travelTime))
                let removeBullet = SKAction.fadeOut(withDuration: 0.1)
                let clean = SKAction.run { self.shape.removeAction(forKey: "shoot")}
                let wait = SKAction.wait(forDuration: 0.5)
                bullet.run(SKAction.sequence([travel,removeBullet,SKAction.run {                  zombie.takeDamage(self.damage) },wait,clean,SKAction.run{ self.walk() }]), withKey: "shoot")
            }
        }
    }
    
    func spawnBullet(direction: CGPoint) {
        let spawnPoint = CGPoint(x: shape.position.x + direction.x*CGFloat(radius),
                                 y: shape.position.y + direction.y*CGFloat(radius))
        bullet.run(SKAction.sequence([SKAction.move(to: spawnPoint, duration: 0), SKAction.fadeIn(withDuration: 0)]))
        print("bullet spawned")
    }
    
    func takeDamage(_ damage: Int) {
        if canTurn{
            flash(color: CIColor(red: 255, green: 0, blue: 0))
        } else {
            flash(color: CIColor(red: 0, green: 0, blue: 0))
        }
        health -= damage
   
        if health <= 0 {
            self.color = .black
            self.shape.fillColor = color
            self.shape.removeAllActions()
            isAlive = false
            if canTurn {
                shape.run(SKAction.sequence([SKAction.wait(forDuration: 2),
                                             SKAction.run {self.rollDice()}]))
            }
        }
    }
    
    func walk() {
        if isAlive {
            let direction = CGPoint(x: Int.random(min: -1, max: 1), y: Int.random(min: -1, max: 1))
            let vector = CGVector(dx: 2*direction.x*CGFloat(speed), dy: 2*direction.y*CGFloat(speed))
            let moveBy = SKAction.move(by: vector, duration: 2)
            let moveAgain = SKAction.run(walk)
            let angle = direction.angle
            accent.run(SKAction.rotate(toAngle: angle, duration: 0.3))
            shape.run(SKAction.sequence([moveBy, moveAgain]), withKey: "walk")
        }
    }
}
