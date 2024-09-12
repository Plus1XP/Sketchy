//
//  ContentView.swift
//  Sketchy
//
//  Created by nabbit on 30/08/2024.
//

import SwiftUI
import Combine

struct ContentView: View {
    @EnvironmentObject var userConfig: UserConfiguration

    var body: some View {
        if self.userConfig.canShowOnBoarding {
            WelcomeView()
        } else {
            CanvasView()
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(Drawing())
        .environmentObject(UserConfiguration())
}
