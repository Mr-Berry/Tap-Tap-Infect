//
//  GameScene.swift
//  Tap Tap Infect
//
//  Created by Jason Patrick Berry on 2017-06-10.
//  Copyright © 2017 Jason Patrick Berry. All rights reserved.
//

import SpriteKit
import GameplayKit
import UIKit

struct PhysicsCategory {
    static let None: UInt32                         = 0
    static let Civilian: UInt32                     = 0b1
    static let Cop: UInt32                          = 0b10
    static let Military: UInt32                     = 0b100
    static let Zombie: UInt32                       = 0b1000
    static let obstacle: UInt32                     = 0b10000
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var lastUpdateTimeInterval: TimeInterval = 0
    var deltaTime: TimeInterval = 0
    
    var cameraNode = SKCameraNode()
    var humansCount: Int = 0
    var zombieCount: Int = 0
    var HumanPop: [Human] = []
    var ZombiePop: [Human] = []
    
    var background: SKTileMapNode!
    var obstaclesTileMap: SKTileMapNode!
    var buildingsTileMap: [SKTileMapNode] = []
    var clouds: SKTileMapNode!
    
    var numZTaps: Int = 1
    var unlockedSpawns: Int = 1
    let cameraMoveSpeed: Float = 20.0
    var initialTouch: CGPoint = .zero
    var endTouch: CGPoint = .zero
    var spawnPoints: [CGPoint] = []
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        setupEmitters()
        setupBuildingPhysics()
        setupObstaclePhysics()
        setupCamera()
        createHumans()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        initialTouch = touch.location(in: self)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: cameraNode)
            let offset = initialTouch - location
            let direction = offset/offset.length()
            let vector = CGVector(dx: direction.x*CGFloat(cameraMoveSpeed),
                                  dy: -1*direction.y*CGFloat(cameraMoveSpeed))

            camera!.run(SKAction.sequence([SKAction.move(by: vector, duration: 0.1)]))
            initialTouch = location
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        endTouch = touch.location(in: self)
    }
    
    override func update(_ currentTime: TimeInterval) {
        if lastUpdateTimeInterval > 0 {
            deltaTime = currentTime - lastUpdateTimeInterval
        } else {
            deltaTime = 0
        }
        lastUpdateTimeInterval = currentTime
        setHumanSpawner()
        tapZombie()
        updateHumansAndZombies()
    }
    
    func createHumans() {
        for i in 0...HumanSettings.humanMaxPop-1 {
            let chance = Int.random(min: 1, max: 100)
            if chance <= HumanSettings.militaryChance {
                HumanPop.insert(Human(category: humanType.military.rawValue,
                                      type: attackType.ranged.rawValue), at: i)
            } else if chance <= (HumanSettings.copChance + HumanSettings.militaryChance) {
                if Int.random(min: 1, max: 100) <= 25 {
                    HumanPop.insert(Human(category: humanType.cop.rawValue,
                                          type: attackType.ranged.rawValue), at: i)
                } else {
                    HumanPop.insert(Human(category: humanType.cop.rawValue,
                                          type: attackType.melee.rawValue), at: i)
                }
            } else {
                if Int.random(min: 1, max: 100) <= 25 {
                    HumanPop.insert(Human(category: humanType.civilian.rawValue,
                                          type: attackType.ranged.rawValue), at: i)
                } else {
                    HumanPop.insert(Human(category: humanType.civilian.rawValue,
                                          type: attackType.melee.rawValue), at: i)
                }
            }
            HumanPop[i].addChild(scene: self)
            HumanPop[i].shape.position = CGPoint(x: background.frame.size.width,
                                                 y: background.frame.size.height)
        }
        for i in 0...HumanSettings.humanStartPop-1 {
            spawnHuman(human: HumanPop[i])
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        if contact.bodyA.categoryBitMask == PhysicsCategory.Zombie || contact.bodyB.categoryBitMask == PhysicsCategory.Zombie{
            let other = contact.bodyA.categoryBitMask == PhysicsCategory.Zombie ? contact.bodyB : contact.bodyA
            switch other.categoryBitMask {
            case PhysicsCategory.Zombie:
                print("Rawr")
            default:
                break
            }
        }

    }
    
    func setHumanSpawner() {
        let spawnAction = SKAction.sequence([
            SKAction.wait(forDuration: TimeInterval(HumanSettings.spawnFreq)),
            SKAction.run{ self.spawnHuman(human: self.HumanPop[self.humansCount])},
            SKAction.removeFromParent()])
        if self.action(forKey: "spawn") == nil &&
            (humansCount+zombieCount) < HumanSettings.humanMaxPop {
            run(spawnAction, withKey: "spawn")
        }
    }
    
    func setupBuildings() {
        let buildings = childNode(withName: "buildings")!
        buildings.enumerateChildNodes(withName: "*", using: {(node,stop) in
            let building = node as! SKTileMapNode
            self.buildingsTileMap.append(building)
        })
    }
    
    func setupBuildingPhysics() {
        setupBuildings()
        for building in buildingsTileMap {
            let decorationNode = building.childNode(withName: "buildingdeco") as! SKTileMapNode
            for row in 0..<building.numberOfRows {
                for column in 0..<building.numberOfColumns {
                    if let tile = tile(in: building, at: (column,row)) {
                        let node = SKNode()
                        node.position = building.centerOfTile(atColumn: column, row: row)
                        node.physicsBody = SKPhysicsBody(rectangleOf: tile.size)
                        node.physicsBody?.isDynamic = false
                        building.addChild(node)
                    }
                    if let tile1 = tile(in: decorationNode, at: (column,row)) {
                        if tile1.name == "door" {
                            var point = decorationNode.centerOfTile(atColumn: column, row: row)
                            point.y -= 0.5*tile1.size.height
                            let spawnPoint = convert(point, from: decorationNode)
                            self.spawnPoints.append(spawnPoint)
                        }
                    }
                }
            }
        }
    }
    
    func setupObstaclePhysics() {
        obstaclesTileMap = childNode(withName: "obstacles") as! SKTileMapNode
        for row in 0..<obstaclesTileMap.numberOfRows {
            for column in 0..<obstaclesTileMap.numberOfColumns {
                if let tile = tile(in: obstaclesTileMap, at: (column,row)) {
                    let node = SKNode()
                    node.position = obstaclesTileMap.centerOfTile(atColumn: column, row: row)
                    node.position.y -= 0.25*tile.size.height
                    node.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: tile.size.width,
                                                                        height: tile.size.height*0.5))
                    node.physicsBody?.isDynamic = false
                    obstaclesTileMap.addChild(node)
                }
            }
        }
    }
    
    func setupCamera() {
        guard let camera = camera, let view = view else { return }
        
        let xInset = min(view.bounds.width*0.5*camera.xScale, obstaclesTileMap.frame.width*0.5)
        let yInset = min(view.bounds.height*0.5*camera.yScale, obstaclesTileMap.frame.height*0.5)
        
        let constraintRect = obstaclesTileMap.frame.insetBy(dx: xInset, dy: yInset)
        
        let xRange = SKRange(lowerLimit: constraintRect.minX, upperLimit: constraintRect.maxX)
        let yRange = SKRange(lowerLimit: constraintRect.minY, upperLimit: constraintRect.maxY)
        
        let edgeConstraint = SKConstraint.positionX(xRange, y: yRange)
        edgeConstraint.referenceNode = obstaclesTileMap
        
        camera.constraints = [edgeConstraint]
    }
    
    func setupEdgeLoop() {

    }
    
    func setupEmitters() {
        background = childNode(withName: "environment") as! SKTileMapNode
        background.enumerateChildNodes(withName: "*", using: { (node, stop) in
            let cloud = node as! SKEmitterNode
            cloud.advanceSimulationTime(50)
        })
    }
    
    func spawnHuman(human: Human) {
        let spawnPoint = spawnPoints[Int.random(min: 0, max: unlockedSpawns)]
        let move = SKAction.move(to: spawnPoint, duration: 0)
        let recolor = SKAction.fadeAlpha(to: 1, duration: 2.0)
        let spawnAction = SKAction.sequence([move,recolor,SKAction.run{human.walk()}])
        human.shape.run(spawnAction)
        humansCount += 1
    }
    
    func tapZombie() {
        if numZTaps > 0 && initialTouch != .zero{
            var index: Int = -1
            for i in 0...HumanPop.count-1 {
                if HumanPop[i].shape.contains(initialTouch) && HumanPop[i].shape.contains(endTouch){
                    HumanPop[i].becomeZombie()
                    ZombiePop.append(HumanPop[i])
                    zombieCount += 1
                    numZTaps -= 1
                    index = i
                }
            }
            if index >= 0 {
                HumanPop.remove(at: index)
                humansCount -= 1
            }
        }
    }
    
    func tile(in tileMap: SKTileMapNode, at coordinates: TileCoordinates) -> SKTileDefinition? {
        return tileMap.tileDefinition(atColumn: coordinates.column, row: coordinates.row)
    }
    
    func tileCoordinates(in tileMap: SKTileMapNode, at position: CGPoint) -> TileCoordinates {
        let column = tileMap.tileColumnIndex(fromPosition: position)
        let row = tileMap.tileRowIndex(fromPosition: position)
        return(column, row)
    }
    
    func updateHumansAndZombies() {
        var target: Human?
        for zombie in ZombiePop{
            for human in HumanPop {
                if zombie.maxRange > (zombie.shape.position - human.shape.position).length(){
                    human.runAway(zombiePosition: zombie.shape.position)
                    if zombie.closestHuman == 0 || (zombie.closestHuman >= (zombie.shape.position - human.shape.position).length()) {
                        zombie.closestHuman = (zombie.shape.position-human.shape.position).length()
                        target = human
                    }
                }
            }
            if target != nil {
                zombie.chase(human: target!)
            } else {
                zombie.closestHuman = 0
            }
        }
    }
}
