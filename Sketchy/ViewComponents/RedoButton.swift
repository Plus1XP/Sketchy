//
//  RedoButton.swift
//  Sketchy
//
//  Created by nabbit on 11/09/2024.
//

import SwiftUI

struct RedoButton: View {
    @EnvironmentObject var drawing: Drawing
    @State var animateRedo: Bool = false

    var body: some View {
        Button(action: {
            self.animateRedo.toggle()
            self.drawing.redo()
            UIImpactFeedbackGenerator(style: .soft).impactOccurred(intensity: 0.8)
        }, label: {
            Label("Redo", systemImage: "arrow.uturn.forward")
                .symbolEffect( .bounce, options: .speed(2), value: self.animateRedo)
        })
        .buttonRepeatBehavior(.enabled)
        .disabled(self.drawing.undoManager.canRedo == false)
    }
}

#Preview {
    RedoButton()
        .environmentObject(Drawing())
}
