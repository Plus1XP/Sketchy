//
//  Stroke.swift
//  Sketchy
//
//  Created by nabbit on 30/08/2024.
//

import SwiftUI

// StrokeModel v3
struct Stroke: Codable, Identifiable {
    var id = UUID()
    var points = [CGPoint]()
    var color = Color.primary
    var width = 3.0
    var spacing = 0.0
    var blur = 0.0
    var eraserWidth = 3.0
    var eraserBlur = 0.0
    var fill = false
    var fillColor = Color.clear
    var tool = ToolType.brush
}

// StrokeModel v2
struct LegacyStrokeV2: Codable, Identifiable {
    var id = UUID()
    var points = [CGPoint]()
    var color = Color.primary
    var width = 3.0
    var spacing = 0.0
    var blur = 0.0
    var fill = false
    var fillColor = Color.clear
    var tool = ToolType.brush
}

// StrokeModel v1
struct LegacyStrokeV1: Codable {
    var points = [CGPoint]()
    var color = Color.black
    var width = 3.0
    var spacing = 0.0
    var blur = 0.0
}
