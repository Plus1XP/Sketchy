//
//  ToolPreferencesMenuButton.swift
//  Sketchy
//
//  Created by nabbit on 11/09/2024.
//

import SwiftUI

struct ToolPreferencesMenuButton: View {
    @Binding var showToolPreferences: Bool
    
    var body: some View {
        Button(action: {
            self.showToolPreferences.toggle()
            UISelectionFeedbackGenerator().selectionChanged()
        }) {
            Label("Tool Preferences", systemImage: "slider.horizontal.3")
                .foregroundColor(.accentColor)
                .symbolEffect( .bounce, options: .speed(2), value: self.showToolPreferences)
        }    }
}

#Preview {
    ToolPreferencesMenuButton(showToolPreferences: .constant(false))
}
