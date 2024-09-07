//
//  OrientationType.swift
//  Sketchy
//
//  Created by nabbit on 06/09/2024.
//

import SwiftUI

enum OrientationType: String, Codable, CaseIterable, Identifiable {
    case automatic
    case portrait
    case landscape

    var id: Self {
        return self
    }

    var label: String {
        switch self {
        case .automatic:
            "Automatic"
        case .portrait:
            "Portrait"
        case .landscape:
            "Landscape"
        }
    }
}

extension OrientationType {
    var orientationMask: UIInterfaceOrientationMask {
        switch self {
        case .automatic:
                .all
        case .portrait:
                .portrait
        case .landscape:
                .landscape
        }
    }
    
    var interfaceOrientation: UIInterfaceOrientation {
        switch self {
        case .automatic:
                .unknown
        case .portrait:
                .portrait
        case .landscape:
                .landscapeLeft
        }
    }
    
    var symbolChoice: String {
        switch self {
        case .automatic:
            "arrow.triangle.2.circlepath"
        case .portrait:
            "iphone"
        case .landscape:
            "iphone.landscape"
        }
    }
    
    var primarySymbolColor: Color {
        switch self {
        case .automatic:
            Color.primary
        case .portrait:
            Color.accentColor
        case .landscape:
            Color.accentColor
        }
    }
    
    var secondarySymbolColor: Color {
        switch self {
        case .automatic:
            Color.primary
        case .portrait:
            Color.white
        case .landscape:
            Color.white
        }
    }
}
