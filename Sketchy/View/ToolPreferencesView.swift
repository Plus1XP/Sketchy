//
//  BrushesPreferencesView.swift
//  Sketchy
//
//  Created by nabbit on 30/08/2024.
//

import SwiftUI

struct ToolPreferencesView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var drawing: Drawing
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Button {
                    withAnimation {
                        self.drawing.lineWidth = 3.0
                        self.drawing.blurAmount = 0.0
                        self.drawing.lineSpacing = 0.0
                        UINotificationFeedbackGenerator().notificationOccurred(.success)
                    }
                } label: {
                    Image(systemName: "arrow.counterclockwise.circle.fill")
                        .font(.title)
                }
                .disabled(self.drawing.lineWidth == 3.0 && self.drawing.blurAmount == 0.0 && self.drawing.lineSpacing == 0.0)
                Spacer()
                Text("Tool Preferences")
                    .fontWeight(.semibold)
                Spacer()
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.gray, self.colorScheme == .light ? Color(UIColor.tertiarySystemFill) : Color(UIColor.tertiarySystemBackground))
                        .font(.title)
                }
            }
            .padding(.leading, 20)
            .padding(.trailing, 20)
            
            Form {
                Section(header: Text("\(Image(systemName: "pencil.tip")) Line Width")) {
                    Group {
                        HStack {
                            Text("Thickness: ") +
                            Text(Int(self.drawing.lineWidth).description)
                                .fontWeight(.medium)
                            Slider(value: $drawing.lineWidth, in: 1...100)
                                .sensoryFeedback(.increase, trigger: self.drawing.lineWidth)
                        }
                    }
                }
                Section(header: Text("\(Image(systemName: "scribble.variable")) Line blur")) {
                    Group {
                        HStack {
                            Text("Softness: ") +
                            Text(Int(self.drawing.blurAmount).description)
                                .fontWeight(.medium)
                            Slider(value: $drawing.blurAmount, in: 0...50)
                                .sensoryFeedback(.increase, trigger: self.drawing.blurAmount)
                        }
                    }
                }
                Section(header: Text("\(Image(systemName: "circle.dashed")) Line Spacing")) {
                    Group {
                        HStack {
                            Text("Distance: ") +
                            Text(self.drawing.lineSpacing, format: .percent)
                                .fontWeight(.medium)
                            Slider(value: $drawing.lineSpacing, in: 0...5, step: 0.1)
                                .sensoryFeedback(.increase, trigger: self.drawing.lineSpacing)
                        }
                    }
                }
            }
        }
        .padding(.top)
        .background(self.colorScheme == .light ? Color(UIColor.secondarySystemBackground) : Color(UIColor.systemBackground))
    }
}

#Preview {
    ToolPreferencesView()
        .environmentObject(Drawing())
}
