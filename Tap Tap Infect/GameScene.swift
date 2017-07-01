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

class GameScene: SKScene {
    
    var cameraNode = SKCameraNode()
    
    var HumanPop: [Human] = []
    var ZombiePop: [Human] = []
    
    var background: SKTileMapNode!
    var obstaclesTileMap: SKTileMapNode!
    var buildingsTileMap: SKTileMapNode!
    
    let cameraMoveSpeed = 20.0
    var initialTouch: CGPoint = CGPoint()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        background = childNode(withName: "environment") as! SKTileMapNode
        obstaclesTileMap = childNode(withName: "obstacles") as! SKTileMapNode
        buildingsTileMap = childNode(withName: "buildings") as! SKTileMapNode
    }
    
    override func didMove(to view: SKView) {
        
        setupCamera()

        HumanPop.append(Human(category: humanType.civilian.rawValue, type: attackType.ranged.rawValue))
        HumanPop.append(Human(category: humanType.civilian.rawValue, type: attackType.melee.rawValue))
        HumanPop.append(Human(category: humanType.civilian.rawValue, type: attackType.boss.rawValue))
        for index in 0...(HumanPop.endIndex-1) {
            HumanPop[index].addChild(scene: self)
        }
        setupObstaclePhysics()
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
    
    override func update(_ currentTime: TimeInterval) {
        
    }
    
    func setupCamera() {
        guard let camera = camera, let view = view else { return }
        
        let xInset = min(view.bounds.width*0.7*camera.xScale, background.frame.width)
        let yInset = min(view.bounds.height*0.66*camera.yScale, background.frame.height)
        
        let constraintRect = background.frame.insetBy(dx: xInset, dy: yInset)
        
        let xRange = SKRange(lowerLimit: constraintRect.minX, upperLimit: constraintRect.maxX)
        let yRange = SKRange(lowerLimit: constraintRect.minY, upperLimit: constraintRect.maxY)
        
        let edgeConstraint = SKConstraint.positionX(xRange, y: yRange)
        edgeConstraint.referenceNode = background
        
        camera.constraints = [edgeConstraint]
    }
    
    func setupEdgeLoop() -> SKPhysicsBody {
        var physicsBodies: [SKPhysicsBody] = []
        let edgeLoop = SKPhysicsBody(bodies: physicsBodies)
        return edgeLoop
    }
    
    func setupObstaclePhysics() {
        
        guard let buildingsTileMap = buildingsTileMap else { return }
        for row in 0..<buildingsTileMap.numberOfRows {
            for column in 0..<buildingsTileMap.numberOfColumns {
                if let tile2 = tile(in: buildingsTileMap, at: (column,row)) {
                    //check if it is the bottom left tile of building
                    if (tile(in: buildingsTileMap, at: (column-1, row)) == nil &&
                        tile(in: buildingsTileMap, at: (column, row-1)) == nil) {
                        //count how many nodes are above one another
                        var numInAColumn = 1
                        var i = row + 1
                        while tile(in: buildingsTileMap, at: (column,i)) != nil {
                            numInAColumn += 1
                            i += 1
                        }
                        //count how many nodes are next to one another
                        var numInARow = 1
                        var j = column + 1
                        while tile(in: buildingsTileMap, at: (j,row)) != nil {
                            numInARow += 1
                            j += 1
                        }
                        let building = SKNode()
                        let size = CGSize(width: numInARow*Int(tile2.size.width), height: numInAColumn*Int(tile2.size.height))
                        let center = buildingsTileMap.centerOfTile(atColumn: column, row: row)
                        let anchorPoint = CGPoint(x: center.x-0.5*tile2.size.width,
                                                  y: center.y-0.5*tile2.size.height)
                        
                        building.physicsBody = SKPhysicsBody(rectangleOf: size)
                        building.physicsBody?.isDynamic = false
                        building.physicsBody?.friction = 0
                        building.position = CGPoint(
                            x: anchorPoint.x + CGFloat(0.5*size.width),
                            y: anchorPoint.y + CGFloat(0.5*size.height))
                        buildingsTileMap.addChild(building)
                    }
                }
            }
        }
    }
    
    private func spawnHuman() {
        
    }
    
    func tile(in tileMap: SKTileMapNode, at coordinates: TileCoordinates) -> SKTileDefinition? {
        return tileMap.tileDefinition(atColumn: coordinates.column, row: coordinates.row)
    }
    
    func tileCoordinates(in tileMap: SKTileMapNode, at position: CGPoint) -> TileCoordinates {
        let column = tileMap.tileColumnIndex(fromPosition: position)
        let row = tileMap.tileRowIndex(fromPosition: position)
        return(column, row)
    }
}
