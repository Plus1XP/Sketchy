//
//  ClearCanvasButton.swift
//  Sketchy
//
//  Created by nabbit on 11/09/2024.
//

import SwiftUI

struct ClearCanvasButton: View {
    @EnvironmentObject var drawing: Drawing
    @Binding var canShowDeleteAlert: Bool
    
    var body: some View {
        Button(action: {
            self.canShowDeleteAlert.toggle()
            UINotificationFeedbackGenerator().notificationOccurred(.warning)
        }, label: {
            Label("Clear Canvas", systemImage: "trash")
                .symbolEffect(.pulse.wholeSymbol, options: .speed(3), value: self.canShowDeleteAlert)
                .contentTransition(.symbolEffect(.replace))
        })
        .disabled(self.drawing.oldStrokeHistory() == 0)
    }
}

#Preview {
    ClearCanvasButton(canShowDeleteAlert: .constant(false))
        .environmentObject(Drawing())
}
