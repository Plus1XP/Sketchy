//
//  UndoButton.swift
//  Sketchy
//
//  Created by nabbit on 11/09/2024.
//

import SwiftUI

struct UndoButton: View {
    @EnvironmentObject var drawing: Drawing
    @Environment(\.undoManager) var undoManager
    @State var animateUndo: Bool = false

    var body: some View {
        // Repeat behaviour not working unless button is in view directly
        Button(action: {
            self.animateUndo.toggle()
            self.drawing.undo()
            UIImpactFeedbackGenerator(style: .soft).impactOccurred(intensity: 0.8)
        }, label: {
            Label("Undo", systemImage: "arrow.uturn.backward")
                .symbolEffect( .bounce, options: .speed(2), value: self.animateUndo)
        })
        .buttonRepeatBehavior(.enabled)
        .disabled(self.undoManager?.canUndo == false)
    }
}

#Preview {
    UndoButton()
        .environmentObject(Drawing())
}
