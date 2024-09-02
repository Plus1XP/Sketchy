//
//  Stroke.swift
//  Sketchy
//
//  Created by nabbit on 30/08/2024.
//

import SwiftUI

struct Stroke: Codable {
    var points = [CGPoint]()
    var color = Color.primary
    var width = 3.0
    var spacing = 0.0
    var blur = 0.0
}
