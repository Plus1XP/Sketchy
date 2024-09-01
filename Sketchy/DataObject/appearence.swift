//
//  appearence.swift
//  Sketchy
//
//  Created by nabbit on 01/09/2024.
//

import SwiftUI

enum AppearanceType: String, Codable, CaseIterable, Identifiable {
    case automatic
    case dark
    case light

    var id: Self {
        return self
    }

    var label: String {
        switch self {
        case .automatic:
            "Automatic"
        case .dark:
            "Dark"
        case .light:
            "Light"
        }
    }
}

extension AppearanceType {
    var colorScheme: ColorScheme? {
        switch self {
        case .automatic:
            .none
        case .dark:
            .dark
        case .light:
            .light
        }
    }
    
    var userInerfaceStyle: UIUserInterfaceStyle? {
        switch self {
        case .automatic:
            .unspecified
        case .dark:
            .dark
        case .light:
            .light
        }
    }
}
