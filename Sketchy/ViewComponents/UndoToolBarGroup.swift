//
//  UndoToolBarGroup.swift
//  Sketchy
//
//  Created by nabbit on 11/09/2024.
//

import SwiftUI

struct UndoToolBarGroup: View {
    @EnvironmentObject var drawing: Drawing
    @Environment(\.undoManager) var undoManager
    @Binding var canShowDeleteAlert: Bool
    
    var body: some View {
        HStack {
            Divider()
            UndoButton()
            RedoButton()
            HistoricUndoButton()
            ClearCanvasButton(canShowDeleteAlert: $canShowDeleteAlert)
        }
    }
}

#Preview {
    UndoToolBarGroup(canShowDeleteAlert: .constant(false))
        .environmentObject(Drawing())
}
