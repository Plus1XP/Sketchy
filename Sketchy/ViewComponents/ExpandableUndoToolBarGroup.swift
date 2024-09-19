//
//  ExpandableUndoToolBarGroup.swift
//  Sketchy
//
//  Created by nabbit on 11/09/2024.
//

import SwiftUI

struct ExpandableUndoToolBarGroup: View {
    @EnvironmentObject var drawing: Drawing
    @Environment(\.undoManager) var undoManager
    @Binding var canExpand: Bool
    @Binding var canShowDeleteAlert: Bool
    
    var body: some View {
        Spacer()
        if canExpand {
            HStack {
                Button(action: {
                    self.canExpand.toggle()
                    UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
                }, label: {
                    Label("Collapse", systemImage: "chevron.right.circle")
                })
                UndoButton()
                RedoButton()
                HistoricUndoButton()
                ClearCanvasButton(canShowDeleteAlert: $canShowDeleteAlert)
            }
            .background(.ultraThinMaterial)
            .frame(width: 170, height: 30)
            .cornerRadius(100)
            .transition(.move(edge: .trailing))
        } else {
            Button(action: {
                self.canExpand.toggle()
                UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
            }, label: {
                Label("Expand", systemImage: "chevron.left.circle")
            })
            .frame(height: 30)
        }
    }
}

#Preview {
    ExpandableUndoToolBarGroup(canExpand: .constant(true), canShowDeleteAlert: .constant(false))
        .environmentObject(Drawing())
}
