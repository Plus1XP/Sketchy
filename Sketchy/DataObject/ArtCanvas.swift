//
//  ArtCanvas.swift
//  Sketchy
//
//  Created by nabbit on 02/09/2024.
//

import SwiftUI

struct ArtCanvas: Codable {
    var color = Color.clear
    var fullSize: Bool = true
    var orientation: OrientationType = .automatic
}
