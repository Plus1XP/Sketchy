//
//  Tool.swift
//  Sketchy
//
//  Created by nabbit on 02/09/2024.
//

import Foundation
import SwiftUI
import Combine

enum ToolType: String, Codable, CaseIterable, Identifiable  {
    case brush
    case circle
    case diamond
    case eraser
    case hexagon
    case line
    case octagon
    case pentagon
    case star
    case square
    case triangle
    
    var id: Self {
        return self
    }
    
    var label: String {
        switch self {
        case .brush:
            "Brush"
        case .circle:
            "Circle"
        case .diamond:
            "Diamond"
        case .eraser:
            "Eraser"
        case .hexagon:
            "Hexagon"
        case .line:
            "Line"
        case .octagon:
            "Octagon"
        case .pentagon:
            "Pentagon"
        case .star:
            "Star"
        case .square:
            "Square"
        case .triangle:
            "Triangle"
        }
    }
}

extension ToolType {
    var symbolChoice: String {
        switch self {
        case .brush:
            "paintbrush.pointed"
        case .circle:
            "circle"
        case .diamond:
            "diamond"
        case .eraser:
            "eraser.line.dashed"
        case .hexagon:
            "hexagon"
        case .line:
            "line.diagonal"
        case .octagon:
            "octagon"
        case .pentagon:
            "pentagon"
        case .star:
            "star"
        case .square:
            "square"
        case .triangle:
            "triangle"
        }
    }
}
