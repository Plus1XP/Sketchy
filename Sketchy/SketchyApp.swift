//
//  SketchyApp.swift
//  Sketchy
//
//  Created by nabbit on 30/08/2024.
//

import SwiftUI

@main
struct SketchyApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @Environment(\.scenePhase) private var scenePhase
    @AppStorage("appearance") var appearanceType: AppearanceType = .automatic

    var body: some Scene {
        DocumentGroup(newDocument: Drawing.init) { file in
            ContentView()
        }
        .onChange(of: scenePhase) {
            print("Scene Changed")
            self.setAppearance()
        }
        .onChange(of: appearanceType) {
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
            firstWindow.overrideUserInterfaceStyle = appearanceType.userInerfaceStyle ?? .unspecified
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    
    static var orientationLock = UIInterfaceOrientationMask.all
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // something to do
        return true
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window:UIWindow?) -> UIInterfaceOrientationMask {
        return AppDelegate.orientationLock
    }
}
