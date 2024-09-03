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
    case eraser
    case fill
    case line
    case square
    
    var id: Self {
        return self
    }
    
    var label: String {
        switch self {
        case .brush:
            "Brush"
        case .circle:
            "Circle"
        case .eraser:
            "Eraser"
        case .fill:
            "Fill"
        case .line:
            "Line"
        case .square:
            "Square"
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
        case .eraser:
            "eraser"
        case .fill:
            "paintbrush"
        case .line:
            "line.diagonal"
        case .square:
            "square"
        }
    }
}
