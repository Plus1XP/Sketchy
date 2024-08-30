//
//  SketchyApp.swift
//  Sketchy
//
//  Created by nabbit on 30/08/2024.
//

import SwiftUI

@main
struct SketchyApp: App {
    var body: some Scene {
        DocumentGroup(newDocument: Drawing.init) { file in
            ContentView()
        }
    }
}
