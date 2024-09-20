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
            HStack(spacing: 10) {
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
            .padding([.leading, .trailing], 3)
            .background(RoundedRectangle(cornerRadius: 40).fill(.ultraThinMaterial))
            .frame(width: 210, height: 40)
        } else {
            Button(action: {
                self.canExpand.toggle()
                UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
            }, label: {
                Label("Expand", systemImage: "chevron.left.circle")
            })
            .frame(height: 40)
        }
    }
}

#Preview {
    ExpandableUndoToolBarGroup(canExpand: .constant(true), canShowDeleteAlert: .constant(false))
        .environmentObject(Drawing())
}
