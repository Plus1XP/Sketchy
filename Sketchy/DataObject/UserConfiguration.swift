//
//  UserConfiguration.swift
//  Sketchy
//
//  Created by nabbit on 11/09/2024.
//

import SwiftUI

class UserConfiguration: ObservableObject {
    @AppStorage("canShowOnBoarding") var canShowOnBoarding: Bool = true
    @AppStorage("appearanceType") var appearanceType: AppearanceType = .automatic
    @AppStorage("orientationType") var orientationType: OrientationType = .automatic
    @AppStorage("canIgnoreSafeArea") var canIgnoreSafeArea: Bool = true
    @AppStorage("isCanvasHapticsEnabled") var isCanvasHapticsEnabled: Bool = true
    @AppStorage("canvasHapticsIntensity") var canvasHapticsIntensity: Double = 0.38
}
