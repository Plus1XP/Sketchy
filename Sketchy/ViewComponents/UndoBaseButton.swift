//
//  UndoBaseButton.swift
//  Sketchy
//
//  Created by nabbit on 28/09/2024.
//


import SwiftUI

struct UndoBaseButton: View {
    @EnvironmentObject var drawing: Drawing
    @Environment(\.undoManager) var undoManager
    @State var animateUndoBase: Bool = false

    var body: some View {
        Button(action: {
            self.animateUndoBase.toggle()
            self.drawing.removeFirstStroke()
            UIImpactFeedbackGenerator(style: .soft).impactOccurred(intensity: 0.8)
        }, label: {
            Label("Undo Base", image: "custom.arrow.uturn.backward.square.stack")
                .symbolEffect(.bounce.up.byLayer, options: .speed(1), value: self.animateUndoBase)
        })
        .buttonRepeatBehavior(.enabled)
        .disabled(self.drawing.oldStrokeHistory() < 2)
    }
}

#Preview {
    UndoBaseButton()
        .environmentObject(Drawing())
}
