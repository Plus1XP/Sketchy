//
//  ArtCanvas.swift
//  Sketchy
//
//  Created by nabbit on 02/09/2024.
//

import SwiftUI

struct ArtCanvas: Codable {
    var color = Color.clear
    var fullScreen: Bool = true
    var orientation: OrientationType = .automatic
    var lock: Bool = false
}
