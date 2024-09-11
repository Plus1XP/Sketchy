//
//  BrushSelectionMenuButton.swift
//  Sketchy
//
//  Created by nabbit on 11/09/2024.
//

import SwiftUI

struct BrushSelectionMenuButton: View {
    @Binding var selectedTool: ToolType
    
    var body: some View {
        Menu {
            Button(action: {
                self.selectedTool = .brush
                UISelectionFeedbackGenerator().selectionChanged()
            }, label: {
                Label(ToolType.brush.label, systemImage: ToolType.brush.symbolChoice)
            })
            
            Button(action: {
                self.selectedTool = .line
                UISelectionFeedbackGenerator().selectionChanged()
            }, label: {
                Label(ToolType.line.label, systemImage: ToolType.line.symbolChoice)
            })
            
            Button(action: {
                self.selectedTool = .circle
                UISelectionFeedbackGenerator().selectionChanged()
            }, label: {
                Label(ToolType.circle.label, systemImage: ToolType.circle.symbolChoice)
            })
            
            Button(action: {
                self.selectedTool = .triangle
                UISelectionFeedbackGenerator().selectionChanged()
            }) {
                Label(ToolType.triangle.label, systemImage: ToolType.triangle.symbolChoice)
            }
            
            Button(action: {
                self.selectedTool = .square
                UISelectionFeedbackGenerator().selectionChanged()
            }, label: {
                Label(ToolType.square.label, systemImage: ToolType.square.symbolChoice)
            })
            
            Button(action: {
                self.selectedTool = .diamond
                UISelectionFeedbackGenerator().selectionChanged()
            }) {
                Label(ToolType.diamond.label, systemImage: ToolType.diamond.symbolChoice)
            }
            
            Button(action: {
                self.selectedTool = .pentagon
                UISelectionFeedbackGenerator().selectionChanged()
            }) {
                Label(ToolType.pentagon.label, systemImage: ToolType.pentagon.symbolChoice)
            }
            
            Button(action: {
                self.selectedTool = .hexagon
                UISelectionFeedbackGenerator().selectionChanged()
            }) {
                Label(ToolType.hexagon.label, systemImage: ToolType.hexagon.symbolChoice)
            }
            
            Button(action: {
                self.selectedTool = .octagon
                UISelectionFeedbackGenerator().selectionChanged()
            }) {
                Label(ToolType.octagon.label, systemImage: ToolType.octagon.symbolChoice)
            }
            
            Button(action: {
                self.selectedTool = .star
                UISelectionFeedbackGenerator().selectionChanged()
            }) {
                Label(ToolType.star.label, systemImage: ToolType.star.symbolChoice)
            }
            
            Button(action: {
                self.selectedTool = .eraser
                UISelectionFeedbackGenerator().selectionChanged()
            }, label: {
                Label(ToolType.eraser.label, systemImage: ToolType.eraser.symbolChoice)
            })
        } label: {
            Label("Tools", systemImage: self.selectedTool.symbolChoice)
        }    }
}

#Preview {
    @State var selectedTool = ToolType.brush
    return BrushSelectionMenuButton(selectedTool: $selectedTool)
}
