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
    case initial = 0, reset, upgrading, gameOver
}

class HUD: SKNode {
    
    let resetTexture = SKTexture(imageNamed: "HUD_0")
    let upgradesTexture = SKTexture(imageNamed: "HUD_1")
    let zCountTexture = SKTexture(imageNamed: "HUD_2")
    let bBankTexture = SKTexture(imageNamed: "HUD_3")
    let bCountTexture = SKTexture(imageNamed: "HUD_4")
    
    var resetButton: Button?
    var upgradesButton: Button?
    var zCountButton: Button?
    var brainBankButton: Button?
    var brainCountButton: Button?
    
    var upgradesMenu: SKShapeNode = SKShapeNode()
    
    var zCountLabel: SKLabelNode = SKLabelNode()
    var brainBankLabel: SKLabelNode = SKLabelNode()
    var bCountLabel: SKLabelNode = SKLabelNode()
    var zTapLabel: SKLabelNode = SKLabelNode()
    
    let splatEmitter = SKEmitterNode(fileNamed: "Splat")
    
    var hudState: HUDState = .initial {
        didSet {
            updateHUDState(from: oldValue, to: hudState)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
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
    
    func addBrainBank(brains: Int) {
        let position = CGPoint(x: brainBankButton!.position.x+26, y: brainBankButton!.position.y-15)
        brainBankLabel = SKLabelNode(fontNamed: HUDSettings.largeFont)
        brainBankLabel.position = position
        brainBankLabel.fontColor = .white
        brainBankLabel.fontSize = 40
        brainBankLabel.zPosition = 100
        brainBankLabel.text = ":0"
        addChild(brainBankLabel)
        updateBrainBank(brains: brains)
    }
    
    func addBrainCount() {
        let position = CGPoint(x: brainCountButton!.position.x-16, y: brainCountButton!.position.y-15)
        bCountLabel = SKLabelNode(fontNamed: HUDSettings.largeFont)
        bCountLabel.position = position
        bCountLabel.fontColor = .white
        bCountLabel.fontSize = 40
        bCountLabel.zPosition = 100
        bCountLabel.text = "+0"
        addChild(bCountLabel)
    }
    
    func addZCount() {
        let position = CGPoint(x: zCountButton!.position.x+32, y: zCountButton!.position.y-15)
        zCountLabel = SKLabelNode(fontNamed: HUDSettings.largeFont)
        zCountLabel.position = position
        zCountLabel.fontColor = .white
        zCountLabel.fontSize = 40
        zCountLabel.zPosition = 100
        zCountLabel.text = ":0"
        addChild(zCountLabel)
    }
    
    func addZTapLabel(numTaps: Int) {
        let position = CGPoint(x: 0,
                               y: -1*brainBankButton!.position.y-16)
        zTapLabel = SKLabelNode(fontNamed: HUDSettings.largeFont)
        zTapLabel.position = position
        zTapLabel.fontColor = .white
        zTapLabel.fontSize = 40
        zTapLabel.zPosition = 50
        zTapLabel.text = ":0"
        addChild(zTapLabel)
        updateZTap(numTaps: numTaps)
    }

    func clearUI(_ oldState: HUDState) {
        switch oldState {
        case .reset:
            remove(message: HUDMessages.reset)
            remove(message: HUDMessages.resetText)
            remove(message: HUDMessages.yes)
            remove(message: HUDMessages.no)
        case .upgrading:
            hideUpgradesMenu()
        case .gameOver:
            remove(message: HUDMessages.gameOver)
        default:
            break
        }
    }
    
    func hideUpgradesMenu() {
        let scale = SKAction.scale(to: 0, duration: 0.2)
        let fade = SKAction.fadeOut(withDuration: 0.2)
        upgradesMenu.run(SKAction.group([scale,fade]))
    }
    
    func remove(message: String) {
        childNode(withName: message)?.removeFromParent()
    }
    
    func setupButtons(size: CGSize) {
        resetButton = Button(texture: resetTexture, color: .clear, size: resetTexture.size())
        resetButton!.position = CGPoint(x: 5, y: size.height*0.5+0.3*resetButton!.size.height)
        resetButton!.name = "reset"
        resetButton!.zPosition = 99
        
        zCountButton = Button(texture: zCountTexture, color: .clear, size: zCountTexture.size())
        zCountButton!.position = CGPoint(x: size.width*0.5+0.3*zCountButton!.size.height-2, y: resetButton!.position.y-2)
        zCountButton!.name = "zCounter"
        zCountButton!.zPosition = 99
        
        upgradesButton = Button(texture: upgradesTexture, color: .clear, size: upgradesTexture.size())
        upgradesButton!.position = CGPoint(x: zCountButton!.position.x-0.8*upgradesButton!.size.width, y: resetButton!.position.y)
        upgradesButton!.name = "upgrades"
        upgradesButton!.zPosition = 99
        
        brainBankButton = Button(texture: bBankTexture, color: .clear, size: bBankTexture.size())
        brainBankButton!.position = CGPoint(x: -0.5*size.width-0.2*brainBankButton!.size.width,
                                             y: resetButton!.position.y)
        brainBankButton!.name = "bBank"
        brainBankButton!.zPosition = 99
        
        brainCountButton = Button(texture: bCountTexture, color: .clear, size: bCountTexture.size())
        brainCountButton!.position = CGPoint(x: brainBankButton!.position.x+0.9*brainCountButton!.size.width, y: resetButton!.position.y)
        brainCountButton!.name = "bCounter"
        brainCountButton!.zPosition = 99
    
        self.addChild(resetButton!)
        self.addChild(upgradesButton!)
        self.addChild(zCountButton!)
        self.addChild(brainBankButton!)
        self.addChild(brainCountButton!)
        
        addZCount()
        addBrainCount()
    }
    
    func setupNodes(size: CGSize) {
        setupButtons(size: size)
        setupUpgradesMenu(size: size)
    }
    
    func setupUpgradesMenu(size: CGSize) {
        let buttonSize = CGSize(width: size.height*0.4, height: size.width*0.4)
        
        let button1 = SKShapeNode(rectOf: buttonSize)
        button1.fillTexture = SKTexture(imageNamed: "rpgTile133")
        button1.fillColor = .white
        button1.strokeColor = .clear
        button1.name = "upgradeButton1"
        button1.zPosition = 1
        let b1text = SKLabelNode(fontNamed: HUDSettings.font)
        b1text.text = "Zombie Upgrades Coming Soon"
        b1text.fontSize = 10
        button1.addChild(b1text)
        
        let button2 = SKShapeNode(rectOf: buttonSize)
        button2.fillTexture = SKTexture(imageNamed: "rpgTile133")
        button2.fillColor = .white
        button2.strokeColor = .clear
        button2.name = "upgradeButton2"
        button2.zPosition = 1
        let b2text = SKLabelNode(fontNamed: HUDSettings.font)
        b2text.text = "General Upgrades Coming Soon"
        b2text.fontSize = 10
        button2.addChild(b2text)
        
        let button3 = SKShapeNode(rectOf: CGSize(width: buttonSize.height*0.5, height: buttonSize.width*0.5))
        button3.fillTexture = SKTexture(imageNamed: "rpgTile133")
        button3.fillColor = .red
        button3.strokeColor = .clear
        button3.name = "upgradesDone"
        button3.zPosition = 1
        let b3text = SKLabelNode(fontNamed: HUDSettings.font)
        b3text.text = "Done"
        b3text.fontSize = 30
        b3text.position.y = -10
        button3.addChild(b3text)
        
        let emitter = SKEmitterNode(fileNamed: "Splat")
        emitter!.zPosition = 0
        
        upgradesMenu = SKShapeNode(rectOf: CGSize(width: size.width*3, height: size.height*3))
        upgradesMenu.fillColor = SKColorWithRGBA(25, g: 25, b: 25, a: 200)
        upgradesMenu.strokeColor = .clear
        upgradesMenu.zPosition = 90
        upgradesMenu.addChild(emitter!)
        upgradesMenu.addChild(button1)
        
        button1.position = CGPoint(x: -0.25*size.width, y: 0)
        upgradesMenu.addChild(button2)
        
        button2.position = CGPoint(x: 0.25*size.width, y: 0)
        upgradesMenu.addChild(button3)
        
        button3.position = CGPoint(x: 0, y: -1*buttonSize.width)
        addChild(upgradesMenu)
        
        upgradesMenu.setScale(0)
    }
    
    func showUpgradesMenu() {
        let scale = SKAction.scale(to: 1, duration: 0.2)
        let fade = SKAction.fadeIn(withDuration: 0.2)
        upgradesMenu.run(SKAction.group([scale,fade]))
    }
    
    func updateBrainBank(brains: Int) {
        let bCount = String(":\(brains)")
        brainBankLabel.text = bCount
    }
    
    func updateBrainCount(brains: Int) {
        let bCount = String("+\(brains)")
        self.bCountLabel.text = bCount
    }
    
    func updateHUDState(from: HUDState, to: HUDState) {
        clearUI(from)
        updateHUD(to)
    }

    func updateHUD(_ state: HUDState) {
        switch hudState {
        case .reset:
            add(message: HUDMessages.reset, position: CGPoint(x: 0, y: 50), fontSize: 40)
            add(message: HUDMessages.resetText, position: .zero, fontSize: 20)
            add(message: HUDMessages.yes, position: CGPoint(x: -140, y: -50), fontSize: 30)
            add(message: HUDMessages.no, position: CGPoint(x: 130, y: -50), fontSize: 30)
        case .gameOver:
            add(message: HUDMessages.gameOver, position: .zero, fontSize: 40)
        case .upgrading:
            showUpgradesMenu()
        default:
            break
        }
    }
    
    func updateZombieCount(zombies: Int) {
        let zCount = String(":\(zombies)")
        self.zCountLabel.text = zCount
    }
    
    func updateZTap(numTaps: Int) {
        let tapCount = String("number of infects left: \(numTaps)")
        self.zTapLabel.text = tapCount
    }
}
