//
//  LegacyStroke.swift
//  Sketchy
//
//  Created by nabbit on 06/09/2024.
//

import SwiftUI

struct LegacyStroke: Codable {
    var points = [CGPoint]()
    var color = Color.black
    var width = 3.0
    var spacing = 0.0
    var blur = 0.0
}
