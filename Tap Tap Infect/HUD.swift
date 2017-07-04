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
}

enum HUDMessages {
    static let tapToStart = "Tap to Start"
    static let win = "You Win!"
    static let lose = "Out Of Time!"
    static let nextLevel = "Tap for Next Level"
    static let playAgain = "Tap to Play Again"
    static let reload = "Continue Previous Game?"
    static let yes = "Yes"
    static let no = "No"
}

enum LabelState: Int {
    case win = 0, lose, start, reload
}

class HUD: SKNode {
    
    let resetTexture = SKTexture(imageNamed: "HUD_0")
    
    var resetButton: Button?
    var zombieCountLabel: SKNode = SKNode()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init() {
        super.init()
        name = "HUD"
        zPosition = 20
    }
    
    func add(message: String, position: CGPoint, fontSize: CGFloat = HUDSettings.fontSize) {
        let label: SKLabelNode
        label = SKLabelNode(fontNamed: HUDSettings.font)
        label.text = message
        label.name = message
        label.zPosition = 100
        addChild(label)
        label.fontSize = fontSize
        label.position = position
    }

    func clearUI(labelState: LabelState) {
        switch labelState {
        case .win:
            remove(message: HUDMessages.win)
            remove(message: HUDMessages.nextLevel)
            break
        case .lose:
            remove(message: HUDMessages.lose)
            remove(message: HUDMessages.playAgain)
            break
        case .start:
            remove(message: HUDMessages.tapToStart)
            break
        case .reload:
            remove(message: HUDMessages.reload)
            remove(message: HUDMessages.yes)
            remove(message: HUDMessages.no)
            break
        }
    }
    
    func remove(message: String) {
        childNode(withName: message)?.removeFromParent()
    }
    
    func setupNodes(size: CGSize) {
        resetButton = Button(texture: resetTexture, color: .clear, size: resetTexture.size())
        resetButton!.position = CGPoint(x: 0, y: size.height*0.5+resetButton!.size.height*0.5)
        resetButton!.name = "reset"
        self.addChild(resetButton!)
    }
    
    func updateGameState(from: LabelState, to: LabelState) {
        clearUI(labelState: from)
        updateUI(labelState: to)
    }

    func updateUI(labelState: LabelState) {
        switch labelState {
        case .win:
            add(message: HUDMessages.win, position: .zero)
            add(message: HUDMessages.nextLevel, position: CGPoint(x: 0, y: -100))
            break
        case .lose:
            add(message: HUDMessages.lose, position: .zero)
            add(message: HUDMessages.playAgain, position: CGPoint(x: 0, y: -100))
            break
        case .start:
            add(message: HUDMessages.tapToStart, position: .zero)
            break
        case .reload:
            add(message: HUDMessages.reload, position: .zero, fontSize: 40)
            add(message: HUDMessages.yes, position: CGPoint(x: -140, y: -100))
            add(message: HUDMessages.no, position: CGPoint(x: 130, y: -100))
            break
        default:
            break
        }
    }
}
