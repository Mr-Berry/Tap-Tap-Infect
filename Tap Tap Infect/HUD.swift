//
//  HUD.swift
//  Tap Tap Infect
//
//  Created by Jason Patrick Berry on 2017-06-24.
//  Copyright © 2017 Jason Patrick Berry. All rights reserved.
//

import Foundation
import SpriteKit

enum HUDSettings {
    static let font = "Noteworthy-Bold"
    static let fontSize: CGFloat = 50
    static let messageSize = 320
}

enum HUDMessages {
    static let tapToStart = "Tap to Start"
    static let win = "You Win!"
    static let lose = "Out Of Time!"
    static let nextLevel = "Tap for Next Level"
    static let playAgain = "Tap to Play Again"
    static let enterBuilding = "Enter the building?"
    static let yes = "Yes"
    static let no = "No"
}

enum HUDState: Int {
    case initial = 0, buildingTapped, start, reload
}

class HUD: SKNode {
    
    let resetTexture = SKTexture(imageNamed: "HUD_0")
    let upgradesTexture = SKTexture(imageNamed: "HUD_1")
    let zCountTexture = SKTexture(imageNamed: "HUD_2")
    
    var messageNode: SKShapeNode!
    
    var resetButton: Button?
    var upgradesButton: Button?
    var zCountButton: Button?
    var brainCountButton: Button?
    
    var zCountLabel: SKLabelNode?
    var brainCountLabel: SKLabelNode?
    var messageLabel: SKLabelNode!
    
    var fillRectR: SKShapeNode?
    var fillRectL: SKShapeNode?
    
    var hudState: HUDState = .initial
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init() {
        super.init()
        name = "HUD"
    }
    
    func add(message: String, position: CGPoint, fontSize: CGFloat = HUDSettings.fontSize) {
        let label: SKLabelNode
        label = SKLabelNode(fontNamed: HUDSettings.font)
        label.text = message
        label.name = message
        label.zPosition = 100
        label.fontSize = fontSize
        label.position = position
        addChild(label)
    }

    func clearUI() {
        switch hudState {
        case .initial:
            remove(message: HUDMessages.win)
            remove(message: HUDMessages.nextLevel)
            break
        case .buildingTapped:
            remove(message: HUDMessages.enterBuilding)
            remove(message: HUDMessages.yes)
            remove(message: HUDMessages.no)
            break
        case .start:
            remove(message: HUDMessages.tapToStart)
            break
        case .reload:
            remove(message: HUDMessages.enterBuilding)
            remove(message: HUDMessages.yes)
            remove(message: HUDMessages.no)
            break
        }
    }
    
    func remove(message: String) {
        childNode(withName: message)?.removeFromParent()
    }
    
    func setupButtons(size: CGSize) {
        resetButton = Button(texture: resetTexture, color: .clear, size: resetTexture.size())
        resetButton!.position = CGPoint(x: 0, y: 0)
        resetButton!.name = "reset"
        
        upgradesButton = Button(texture: upgradesTexture, color: .clear, size: upgradesTexture.size())
        upgradesButton!.position = CGPoint(x: size.width*0.25, y: resetButton!.position.y)
        upgradesButton!.name = "upgrades"
        
        zCountButton = Button(texture: zCountTexture, color: .clear, size: zCountTexture.size())
        zCountButton!.position = CGPoint(x: upgradesButton!.position.x + upgradesButton!.size.width*0.8, y: resetButton!.position.y-2)
        zCountButton!.name = "zCounter"
        
        self.addChild(resetButton!)
        self.addChild(upgradesButton!)
        self.addChild(zCountButton!)
    }
    
    func setupNodes(size: CGSize) {
        setupButtons(size: size)
        setupShapes(size: size)
    }
    
    func setupShapes(size: CGSize) {
        let rect = CGRect(x: zCountButton!.position.x + zCountButton!.size.width,
                          y: zCountButton!.position.y - 0.5*zCountButton!.size.height + 4,
                          width: size.width*0.5 - (zCountButton!.position.x + zCountButton!.size.width),
                          height: zCountButton!.size.height)
        fillRectR = SKShapeNode(rect: rect)
        fillRectR!.fillColor = #colorLiteral(red: 0.3176470697, green: 0.07450980693, blue: 0.02745098062, alpha: 1)
        self.addChild(fillRectR!)
    }
    
    func setupMessageNode() {
        let rect = CGRect(x: 0, y: 0, width: HUDSettings.messageSize, height: HUDSettings.messageSize)
        
        messageNode = SKShapeNode(rect: rect, cornerRadius: 10)
        messageNode.fillColor = .clear
        messageNode.strokeColor = .clear
        messageLabel.fontName = HUDSettings.font
        messageLabel.fontSize = HUDSettings.fontSize
        messageNode.addChild(messageLabel)
        self.addChild(messageNode)
    }
    
    func updateHUDState(to: HUDState) {
        clearUI()
        updateHUD(to)
    }

    func updateHUD(_ state: HUDState) {
        switch hudState {
        case .initial:

            break
        case .buildingTapped:
            add(message: HUDMessages.enterBuilding, position: .zero, fontSize: 40)
            add(message: HUDMessages.yes, position: CGPoint(x: -140, y: -100))
            add(message: HUDMessages.no, position: CGPoint(x: 130, y: -100))
            break
        case .start:
            add(message: HUDMessages.tapToStart, position: .zero)
            break
        case .reload:
            add(message: HUDMessages.enterBuilding, position: .zero, fontSize: 40)
            add(message: HUDMessages.yes, position: CGPoint(x: -140, y: -100))
            add(message: HUDMessages.no, position: CGPoint(x: 130, y: -100))
            break
        default:
            break
        }
    }
}
