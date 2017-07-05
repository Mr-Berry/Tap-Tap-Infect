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
    static let backgroundradius = 20
    static let backgroundpadding: CGFloat = 20.0
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
        label.addChild(addBackground(size: label.frame.size, color: .black))
        addChild(label)
    }
    
    func addBackground(size: CGSize, color: UIColor) -> SKShapeNode {
        let background = SKShapeNode(rectOf: CGSize(width: size.width+HUDSettings.backgroundpadding,
                                                height: size.height+HUDSettings.backgroundpadding))
        background.fillColor = color
        background.position = CGPoint(x: 0,
        y: 0.5*size.height)
        return background
    }

    func clearUI(_ oldState: HUDState) {
        switch oldState {
        case .initial:
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
