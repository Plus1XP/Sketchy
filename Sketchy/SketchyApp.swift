//
//  SketchyApp.swift
//  Sketchy
//
//  Created by nabbit on 30/08/2024.
//

import SwiftUI

@main
struct SketchyApp: App {
    @Environment(\.scenePhase) private var scenePhase
    @AppStorage("appearance") var appearance: AppearanceType = .automatic

    var body: some Scene {
        DocumentGroup(newDocument: Drawing.init) { file in
            ContentView()
        }
        .onChange(of: scenePhase) {
            print("Scene Changed")
            self.setAppearance()
        }
        .onChange(of: appearance) {
            print("Appearance settings changed")
            self.setAppearance()
        }
    }
    
    private func setAppearance() {
        // We do this via the window so we can access UIKit components too.
        // Replace depreciated code with new code below.
        
//        let window = UIApplication.shared.windows.first
//        window?.overrideUserInterfaceStyle = appearance.userInerfaceStyle ?? .unspecified
        let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        if let firstWindow = scene?.windows.first {
            firstWindow.overrideUserInterfaceStyle = appearance.userInerfaceStyle ?? .unspecified
        }
    }
}
