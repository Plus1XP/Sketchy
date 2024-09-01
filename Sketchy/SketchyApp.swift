//
//  SketchyApp.swift
//  Sketchy
//
//  Created by nabbit on 30/08/2024.
//

import SwiftUI

@main
struct SketchyApp: App {
    @AppStorage("appearance") var appearance: AppearanceType = .automatic

    var body: some Scene {
        DocumentGroup(newDocument: Drawing.init) { file in
            ContentView()
                .preferredColorScheme(appearance.colorScheme)
                .environment(\.colorScheme, appearance.colorScheme ?? .light)
                .onChange(of: appearance, {
                    debugPrint("Apperance changed")
                    let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene
                    if let firstWindow = scene?.windows.first {
                        firstWindow.overrideUserInterfaceStyle = appearance.userInerfaceStyle ?? .unspecified
                    }
                })
                .onAppear {
                    let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene
                    if let firstWindow = scene?.windows.first {
                        firstWindow.overrideUserInterfaceStyle = appearance.userInerfaceStyle ?? .unspecified
                    }
                }
        }
    }
}
