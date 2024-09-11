//
//  ColorScheme.swift
//  Sketchy
//
//  Created by nabbit on 11/09/2024.
//

import SwiftUI

extension ColorScheme {
    var trackFill: Color {
        self == .dark ? Colors.darkTrackFill : Colors.lightTrackFill
    }

    var trackStroke: Color {
        self == .light ? Colors.lightTrackStroke : .clear
    }

    var thumbFill: Color {
        self == .dark ? Colors.darkThumbFill : Colors.lightThumbFill
    }

    var thumbShadow: Color {
        self == .dark ? Colors.thumbShadowDark : Colors.thumbShadowLight
    }
}
