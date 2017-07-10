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

enum Upgrades: Int {
    case initial = 0, upgrade1, upgrade2, upgrade3
}

enum GameState: Int {
    case overview = 0, upgrades, attacking, gameOver
}

class GameScene: SKScene {
    
    static var restarts: Int = 0

    let brainzSound = [SKAction.playSoundFileNamed("brains.wav", waitForCompletion: false),
                       SKAction.playSoundFileNamed("brains2.wav", waitForCompletion: false),
                       SKAction.playSoundFileNamed("brains3.wav", waitForCompletion: false)]
    
    let ambientSound = [SKAction.playSoundFileNamed("groan.wav", waitForCompletion: false),
                       SKAction.playSoundFileNamed("rar.wav", waitForCompletion: false)]
    
    var lastUpdateTimeInterval: TimeInterval = 0
    var deltaTime: TimeInterval = 0
    
    var cameraNode: SKCameraNode!
    var humansCount: Int = 0
    var destroyedCount: Int = 0
    var brains: Int = 0
    static var brainsBanked: Int = 0
    
    var HumanPop: [Human] = []
    var ZombiePop: [Human] = []
    
    var hud = HUD()
    
    var buildings: SKNode!
    var background: SKTileMapNode!
    var obstaclesTileMap: SKTileMapNode!
    var buildingsTileMap: [SKTileMapNode] = []
    var clouds: SKTileMapNode!
    
    var numZTaps: Int = 5
    var unlockedSpawns: Int = 3
    let cameraMoveSpeed: Float = 15.0
    var initialTouch: CGPoint = .zero
    var movedTouch: CGPoint = .zero
    var endTouch: CGPoint = .zero
    var spawnPoints: [CGPoint] = []
    
    var zombieCount: Int = 0
    
    var gameState: GameState = .overview
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func didMove(to view: SKView) {
        setupEmitters()
        setupBuildingPhysics()
        setupObstaclePhysics()
        setupEdgeLoop()
        createHumans()
        setupHudAndCamera()
        playBackgroundMusic("zMusic.mp3")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        initialTouch = touch.location(in: self)
        movedTouch = initialTouch
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: cameraNode)
            let offset = movedTouch - location
            let direction = offset/offset.length()
            let vector = CGVector(dx: direction.x*CGFloat(cameraMoveSpeed),
                                  dy: direction.y*CGFloat(cameraMoveSpeed))

            cameraNode.run(SKAction.sequence([SKAction.move(by: vector, duration: 0.1)]))
            movedTouch = location
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        endTouch = touch.location(in: self)
        if gameState == .overview {
            if endTouch != .zero && endTouch == initialTouch {
                for zombie in ZombiePop {
                    zombie.moveToPoint(point: convert(endTouch, to: zombie.shape))
                }
            }
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        if lastUpdateTimeInterval > 0 {
            deltaTime = currentTime - lastUpdateTimeInterval
        } else {
            deltaTime = 0
        }
        lastUpdateTimeInterval = currentTime
        updateHUD()
        playRandomSound()
        setHumanSpawner()
        updateHumansAndZombies()
        cleanUp()
        hud.updateZombieCount(zombies: ZombiePop.count)
        hud.updateBrainCount(brains: brains)
        hud.updateZTap(numTaps: numZTaps)
    }
    
    func buildingFlash(building: SKTileMapNode) {
        let decorationNode = building.childNode(withName: "buildingdeco") as! SKTileMapNode
        let fadeOut = SKAction.fadeAlpha(to: 0.5, duration: 0.5)
        let fadeIn = SKAction.fadeIn(withDuration: 0.5)
        decorationNode.run(SKAction.sequence([fadeOut,fadeIn]))
        building.run(SKAction.sequence([fadeOut,fadeIn]))
    }
    
    func buttonTaps() {
        let firstTouch = convert(initialTouch, to: hud)
        let lastTouch = convert(endTouch, to: hud)
        if hud.resetButton!.contains(firstTouch) && hud.resetButton!.contains(lastTouch) {
            hud.hudState = .reset
            initialTouch = .zero
            endTouch = .zero
        } else if hud.upgradesButton!.contains(firstTouch) && hud.upgradesButton!.contains(lastTouch){
            initialTouch = .zero
            endTouch = .zero
            hud.hudState = .upgrading
        } else if hud.zCountButton!.contains(firstTouch) && hud.zCountButton!.contains(lastTouch){
            initialTouch = .zero
            endTouch = .zero
        }
    }
    
    func cleanUp() {
        var indicesToClean: [Int] = []
        var indicesToSwap: [Int] = []
        if !HumanPop.isEmpty {
            for i in 0...HumanPop.count-1 {
                if !HumanPop[i].isAlive && !HumanPop[i].canTurn {
                    indicesToClean.append(i)
                } else if HumanPop[i].isAlive && !HumanPop[i].canTurn {
                    indicesToSwap.append(i)
                }
            }
        }
        if !indicesToClean.isEmpty {
            for i in 0...indicesToClean.count-1 {
                let human = HumanPop[indicesToClean[i]]
                HumanPop.remove(at: indicesToClean[i])
                playDeathAnimation(human)
                humansCount -= 1
                destroyedCount += 1
                if Int.random(min: 1, max: 100) < HumanSettings.brainChance {
                    brains += 1
                }
            }
        }
        if !indicesToSwap.isEmpty {
            for i in 0...indicesToSwap.count-1 {
                ZombiePop.append(HumanPop[indicesToSwap[i]])
                HumanPop.remove(at: indicesToSwap[i])
                zombieCount += 1
                humansCount -= 1
            }
        }
        indicesToClean.removeAll()
        if !ZombiePop.isEmpty {
            for i in 0...ZombiePop.count-1 {
                if !ZombiePop[i].isAlive {
                    indicesToClean.append(i)
                }
            }
        }
        if !indicesToClean.isEmpty {
            for i in 0...indicesToClean.count-1 {
                let zombie = ZombiePop[indicesToClean[i]]
                ZombiePop.remove(at: indicesToClean[i])
                playDeathAnimation(zombie)
                zombieCount -= 1
                destroyedCount += 1
            }
        }
    }
    
    func convertHuman(human: Human) {
        switch human.category {
        case humanType.military.rawValue:
            human.category = humanType.cop.rawValue
            human.color = SKColorWithRGBA(0 , g: 64, b: 128, a: 100)
            human.shape.fillColor = human.color
        case humanType.cop.rawValue:
            human.category = humanType.civilian.rawValue
            human.color = SKColorWithRGBA(255 , g: 255, b: 255, a: 100)
            human.shape.fillColor = human.color
        default:
            human.becomeZombie()
            zombieCount += 1
        }
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
    
    func playBackgroundMusic(_ name: String) {
        if let backgroundMusic = childNode(withName: "backgroundMusic") {
            backgroundMusic.removeFromParent()
        }
        let music = SKAudioNode(fileNamed: name)
        music.autoplayLooped = true
        addChild(music)
    }
    
    func playBrainsAnimation(_ zombie: Human) {
        if !zombie.wantsBrainz {
            let particles = SKEmitterNode(fileNamed: "Brainz")!
            particles.position = zombie.shape.position
            particles.zPosition = 30
            background.addChild(particles)
            particles.run(SKAction.sequence([SKAction.removeFromParentAfterDelay(1),
                                             SKAction.run { zombie.wantsBrainz = false }]))
            zombie.wantsBrainz = true
        }
    }
    
    func playBrainsSound() {
        if self.action(forKey: "brainSound") == nil && ZombiePop.count > 0{
            let randomNum = Int.random(brainzSound.count)
            let wait = SKAction.wait(forDuration: TimeInterval(randomNum*8))
            run(SKAction.sequence([brainzSound[randomNum],wait,SKAction.removeFromParent()]), withKey: "brainSound")
        }
    }
    
    func playDeathAnimation(_ human: Human) {
        let particles = SKEmitterNode(fileNamed: "DeathAnimation")!
        particles.position = human.shape.position
        particles.zPosition = 10
        background.addChild(particles)
        particles.run(SKAction.removeFromParentAfterDelay(5.0))
        human.shape.run(SKAction.sequence([SKAction.fadeOut(withDuration: 0.5), SKAction.removeFromParent()]))
    }
    
    func playRandomSound() {
        if self.action(forKey: "ambient") == nil && ZombiePop.count > 0{
            let randomNum = Int.random(ambientSound.count)
            let wait = SKAction.wait(forDuration: TimeInterval(randomNum*8))
            run(SKAction.sequence([ambientSound[randomNum],wait,SKAction.removeFromParent()]), withKey: "ambient")
        }
    }
    
    func playShoutAnimation(_ human: Human) {
        if !human.isScreaming {
            let particles = SKEmitterNode(fileNamed: "Shout")!
            particles.position = human.shape.position
            particles.zPosition = 30
            background.addChild(particles)
            particles.run(SKAction.sequence([SKAction.removeFromParentAfterDelay(1),
                                             SKAction.run { human.isScreaming = false }]))
            human.isScreaming = true
        }
    }
    
    func restart() {
        let newScene = SKScene(fileNamed: "GameScene.sks")
        newScene!.scaleMode = .aspectFill
        view?.presentScene(newScene!, transition: SKTransition.crossFade(withDuration: 2))
    }
    
    func setHumanSpawner() {
        let spawnAction = SKAction.sequence([
            SKAction.wait(forDuration: TimeInterval(HumanSettings.spawnFreq)),
            SKAction.run{ self.spawnHuman(human: self.HumanPop[self.humansCount])},
            SKAction.removeFromParent()])
        if self.action(forKey: "spawn") == nil &&
            (humansCount+zombieCount+destroyedCount) < HumanSettings.humanMaxPop {
            run(spawnAction, withKey: "spawn")
        }
    }
    
    func setupBuildings() {
        buildings = childNode(withName: "buildings")!
        var i = 1
        buildings.enumerateChildNodes(withName: "*", using: {(node,stop) in
            let building = node as! SKTileMapNode
            self.buildingsTileMap.append(building)
            let buildingTexture = SKTexture(imageNamed: "building\(i)")
            building.physicsBody = SKPhysicsBody(texture: buildingTexture, size: building.frame.size)
            building.physicsBody?.isDynamic = false
            i+=1
        })
    }
    
    func setupBuildingPhysics() {
        setupBuildings()
        for building in buildingsTileMap {
            let decorationNode = building.childNode(withName: "buildingdeco") as! SKTileMapNode
            for row in 0..<decorationNode.numberOfRows {
                for column in 0..<decorationNode.numberOfColumns {
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
                    node.physicsBody?.friction = 0
                    obstaclesTileMap.addChild(node)
                }
            }
        }
    }
    
    func setupHudAndCamera() {
        
        guard let view = view else { return }
        
        cameraNode = camera
        
        let xInset = min(view.bounds.width*0.5*cameraNode.xScale, obstaclesTileMap.frame.width*0.5)
        let yInset = min(view.bounds.height*0.5*cameraNode.yScale, obstaclesTileMap.frame.height*0.5)
        
        let constraintRect = obstaclesTileMap.frame.insetBy(dx: xInset, dy: yInset)
        
        let xRange = SKRange(lowerLimit: constraintRect.minX, upperLimit: constraintRect.maxX)
        let yRange = SKRange(lowerLimit: constraintRect.minY, upperLimit: constraintRect.maxY)
        
        let edgeConstraint = SKConstraint.positionX(xRange, y: yRange)
        edgeConstraint.referenceNode = obstaclesTileMap
        
        cameraNode.constraints = [edgeConstraint]
        
        hud.setupNodes(size: view.frame.size)
        cameraNode.addChild(hud)
        hud.position = .zero
        hud.addBrainBank(brains: GameScene.brainsBanked)
        hud.addZTapLabel(numTaps: numZTaps)
}
    
    func setupEdgeLoop() {
        let edgeLoop = SKPhysicsBody(edgeLoopFrom: obstaclesTileMap.frame)
        self.physicsBody = edgeLoop
    }
    
    func setupEmitters() {
        background = childNode(withName: "environment") as! SKTileMapNode
        background.enumerateChildNodes(withName: "*", using: { (node, stop) in
            let cloud = node as! SKEmitterNode
            cloud.advanceSimulationTime(50)
        })
    }
    
    func spawnHuman(human: Human) {
        var spawn = 0
        switch human.category {
        case humanType.cop.rawValue:
            spawn = Int.random(min: 1, max: unlockedSpawns)
        case humanType.military.rawValue:
            spawn = 3
        default:
            spawn = Int.random(min: 0, max: unlockedSpawns)
        }
        let spawnPoint = spawnPoints[spawn]
        let move = SKAction.move(to: spawnPoint, duration: 0)
        let recolor = SKAction.fadeAlpha(by: 1, duration: 0.5)
        let spawnAction = SKAction.sequence([move,recolor,SKAction.run{human.walk()}])
        human.shape.run(spawnAction)
        humansCount += 1
    }
    
    func tapZombie() {
        if numZTaps > 0 && initialTouch != .zero{
            for i in 0...HumanPop.count-1 {
                if endTouch != .zero {
                    if HumanPop[i].shape.contains(initialTouch) && HumanPop[i].shape.contains(endTouch){
                        convertHuman(human: HumanPop[i])
                        numZTaps -= 1
                        endTouch = .zero
                        initialTouch = .zero
                    }
                }
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
                if human.isAlive {
                    if zombie.maxRange > (zombie.shape.position - human.shape.position).length(){
                        human.react(zombie: zombie)
                        if human.category == humanType.civilian.rawValue {
                            playShoutAnimation(human)
                        }
                        if zombie.closestHuman == 0 || (zombie.closestHuman >= (zombie.shape.position - human.shape.position).length()) {
                            zombie.closestHuman = (zombie.shape.position-human.shape.position).length()
                            target = human
                        }
                    }
                }
            }
            if target != nil {
                if target!.canTurn {
                    zombie.chase(target!)
                    playBrainsSound()
                    playBrainsAnimation(zombie)
                }
            } else {
                zombie.closestHuman = 0
            }
            target = nil
        }
    }
    
    func updateBuildings() {
        var i = 0
        for building in buildingsTileMap {
            if building.contains(convert(initialTouch, to: buildings)) && building.contains(convert (endTouch, to: buildings)){
                buildingFlash(building: building)
                endTouch = .zero
            }
            i+=1
        }
    }
    
    func updateHUD() {
        let touch = convert(initialTouch, to: hud)
        switch hud.hudState {
        case .initial:
            tapZombie()
            buttonTaps()
            updateBuildings()
        case .reset:
            if hud.childNode(withName: HUDMessages.yes)!.contains(touch){
                hud.hudState = .upgrading
                gameState = .gameOver
                initialTouch = .zero
            } else if hud.childNode(withName: HUDMessages.no)!.contains(touch) {
                hud.hudState = .initial
                gameState = .overview
                initialTouch = .zero
            }
        case .upgrading:
            if gameState == .gameOver {
                GameScene.brainsBanked += brains
                hud.brainBankLabel.text = ":\(GameScene.brainsBanked+brains)"
                brains = 0
            }
            if hud.upgradesMenu.childNode(withName: "upgradesDone")!.contains(touch) {
                if gameState == .gameOver {
                    restart()
                } else {
                    hud.hudState = .initial
                }
            }
        default:
            break
        }
    }
}
