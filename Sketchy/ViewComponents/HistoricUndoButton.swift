//
//  HistoricUndoButton.swift
//  Sketchy
//
//  Created by nabbit on 11/09/2024.
//

import SwiftUI

struct HistoricUndoButton: View {
    @EnvironmentObject var drawing: Drawing
    @Environment(\.undoManager) var undoManager
    @State var animateHistoricUndo: Bool = false

    var body: some View {
        Button(action: {
            self.animateHistoricUndo.toggle()
            self.drawing.removeOldStroke()
            UIImpactFeedbackGenerator(style: .soft).impactOccurred(intensity: 0.8)
        }, label: {
            Label("Historic Undo", image: "custom.arrow.uturn.backward.badge.clock")
                .symbolEffect(.bounce.up.byLayer, options: .speed(1), value: self.animateHistoricUndo)
        })
        .buttonRepeatBehavior(.enabled)
        .disabled(self.drawing.oldStrokeHistory() == 0 || self.undoManager?.canUndo == true)
    }
}

#Preview {
    HistoricUndoButton()
        .environmentObject(Drawing())
}
