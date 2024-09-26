//
//  SketchModel.swift
//  Sketchy
//
//  Created by nabbit on 02/09/2024.
//

import SwiftUI

// SketchModel v3
struct SketchModel: Codable {
    var artCanvas: ArtCanvas
    var oldStrokes: [Stroke]
}

// SketchModel v2
struct LegacySketchModelV2: Codable {
    var artCanvas: ArtCanvas
    var oldStrokes: [LegacyStrokeV2]
}
