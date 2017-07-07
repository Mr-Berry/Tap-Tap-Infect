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
    static let largeFont = "Futura-CondensedExtraBold"
    static let font = "Noteworthy-Bold"
    static let fontSize: CGFloat = 50
    static let backgroundradius = 20
    static let backgroundpadding: CGFloat = 30.0
}

enum HUDMessages {
    static let tapToStart = "Tap to Start"
    static let win = "You Win!"
    static let lose = "Out Of Time!"
    static let reset = "Would you like to reset?"
    static let resetText = "You lose everything but can use your brainz"
    static let gameOver = "Tap to Play Again"
    static let attack = "Make Zombies Attack?"
    static let yesAttack = "Attack!"
    static let yes = "Gimme Brainz!"
    static let no = "Not now!"
}

enum HUDState: Int {
    case initial = 0, buildingTapped, attackTapped, reset, gameOver
}

class HUD: SKNode {
    
    let resetTexture = SKTexture(imageNamed: "HUD_0")
    let upgradesTexture = SKTexture(imageNamed: "HUD_1")
    let zCountTexture = SKTexture(imageNamed: "HUD_2")
    
    var resetButton: Button?
    var upgradesButton: Button?
    var zCountButton: Button?
    var brainCountButton: Button?
    
    var zCountLabel: SKLabelNode?
    var brainCountLabel: SKLabelNode?
    
    var hudState: HUDState = .initial {
        didSet {
            updateHUDState(from: oldValue, to: hudState)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        zCountLabel = childNode(withName: "ZombieCounter") as? SKLabelNode
        brainCountLabel = childNode(withName: "BrainCounter") as? SKLabelNode
    }
    
    override init() {
        super.init()
        name = "HUD"
    }
    
    func add(message: String, position: CGPoint, fontSize: CGFloat = HUDSettings.fontSize) {
        let label: SKLabelNode
        label = SKLabelNode(fontNamed: HUDSettings.largeFont)
        label.text = message
        label.name = message
        label.zPosition = 100
        label.fontSize = fontSize
        label.position = position
        label.addChild(addBackground(size: label.frame.size, color: .black, name: message))
        addChild(label)
    }
    
    func addBackground(size: CGSize, color: UIColor, name: String) -> SKShapeNode {
        let background = SKShapeNode(rectOf: CGSize(width: size.width+HUDSettings.backgroundpadding, height: size.height+HUDSettings.backgroundpadding),
            cornerRadius: CGFloat(HUDSettings.backgroundradius))
        background.fillTexture = SKTexture(imageNamed: "whitePuff00")
        background.fillColor = color
        background.strokeColor = .clear
        background.position = CGPoint(x: 0, y: 0.5*size.height)
        background.name = name
        return background
    }
    
    func addZCount(zombies: Int) {
        let position = CGPoint(x: zCountButton!.position.x+32, y: zCountButton!.position.y-8)
        add(message: "ZCounter:", position: position, fontSize: 34)
        zCountLabel = childNode(withName: "ZCounter:") as? SKLabelNode
        zCountLabel!.removeAllChildren()
        zCountLabel!.fontName = "Menlo"
        updateZombieCount(zombies: zombies)
    }

    func clearUI(_ oldState: HUDState) {
        switch oldState {
        case .initial:
            break
        case .buildingTapped:
            break
        case .attackTapped:
            remove(message: HUDMessages.attack)
            remove(message: HUDMessages.yesAttack)
            remove(message: HUDMessages.no)
        case .reset:
            remove(message: HUDMessages.reset)
            remove(message: HUDMessages.resetText)
            remove(message: HUDMessages.yes)
            remove(message: HUDMessages.no)
        default:
            break
        }
    }
    
    func remove(message: String) {
        childNode(withName: message)?.removeFromParent()
    }
    
    func setupButtons(size: CGSize) {
        resetButton = Button(texture: resetTexture, color: .clear, size: resetTexture.size())
        resetButton!.position = CGPoint(x: 0, y: size.height*0.5+0.3*resetButton!.size.height)
        resetButton!.name = "reset"
        resetButton!.zPosition = 100
        
        zCountButton = Button(texture: zCountTexture, color: .clear, size: zCountTexture.size())
        zCountButton!.position = CGPoint(x: size.width*0.5+0.3*zCountButton!.size.height-2, y: resetButton!.position.y-2)
        zCountButton!.name = "zCounter"
        zCountButton!.zPosition = 100
        
        upgradesButton = Button(texture: upgradesTexture, color: .clear, size: upgradesTexture.size())
        upgradesButton!.position = CGPoint(x: zCountButton!.position.x-0.8*upgradesButton!.size.width, y: resetButton!.position.y)
        upgradesButton!.name = "upgrades"
        upgradesButton!.zPosition = 100
    
        self.addChild(resetButton!)
        self.addChild(upgradesButton!)
        self.addChild(zCountButton!)
    }
    
    func setupNodes(size: CGSize) {
        setupButtons(size: size)
    }
    
    func updateHUDState(from: HUDState, to: HUDState) {
        clearUI(from)
        updateHUD(to)
    }

    func updateHUD(_ state: HUDState) {
        switch hudState {
        case .initial:
            
            break
        case .buildingTapped:
            break
        case .attackTapped:
            add(message: HUDMessages.attack, position: .zero, fontSize: 40)
            add(message: HUDMessages.yesAttack, position: CGPoint(x: -140, y: -100))
            add(message: HUDMessages.no, position: CGPoint(x: 130, y: -100))
        case .reset:
            add(message: HUDMessages.reset, position: CGPoint(x: 0, y: 50), fontSize: 40)
            add(message: HUDMessages.resetText, position: .zero, fontSize: 20)
            add(message: HUDMessages.yes, position: CGPoint(x: -140, y: -50), fontSize: 30)
            add(message: HUDMessages.no, position: CGPoint(x: 130, y: -50), fontSize: 30)
        case .gameOver:
            add(message: HUDMessages.gameOver, position: .zero, fontSize: 40)
        }
    }
    
    func updateZombieCount(zombies: Int) {
        let zCount = String("\(zombies)")
        zCountLabel?.text = zCount
    }
}
