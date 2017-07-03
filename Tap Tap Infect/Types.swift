//
//  Types.swift
//  Tap Tap Infect
//
//  Created by Jason Patrick Berry on 2017-06-24.
//  Copyright © 2017 Jason Patrick Berry. All rights reserved.
//

import Foundation
import SpriteKit

public enum humanType: Int {
    case civilian = 0, cop, military
}

public enum attackType: Int {
    case melee = 0, ranged
}

typealias TileCoordinates = (column: Int, row: Int)
