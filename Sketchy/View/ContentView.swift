//
//  ContentView.swift
//  Sketchy
//
//  Created by nabbit on 30/08/2024.
//

import SwiftUI
import Combine

struct ContentView: View {
    @AppStorage("canShowOnBoarding") var canShowOnBoarding: Bool = true
    
    var body: some View {
        if self.canShowOnBoarding {
            WelcomeView()
        } else {
            CanvasView()
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(Drawing())
}
