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
            .frame(width: 235)
            .cornerRadius(35)
            .transition(.move(edge: .trailing))
        } else {
            Button(action: {
                self.canExpand.toggle()
                UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
            }, label: {
                Label("Expand", systemImage: "chevron.left.circle")
            })
        }
    }
}

#Preview {
    ExpandableUndoToolBarGroup(canExpand: .constant(false), canShowDeleteAlert: .constant(false))
        .environmentObject(Drawing())
}
