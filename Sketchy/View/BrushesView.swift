//
//  BrushesView.swift
//  Sketchy
//
//  Created by nabbit on 30/08/2024.
//

import SwiftUI

struct BrushesView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var drawing: Drawing
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Button {
                    self.drawing.lineWidth = 3.0
                    self.drawing.blurAmount = 0.0
                    self.drawing.lineSpacing = 0.0
                } label: {
                    Image(systemName: "arrow.counterclockwise.circle.fill")
                }
                Spacer()
                Text("Brush")
                    .fontWeight(.semibold)
                Spacer()
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.gray, self.colorScheme == .light ? Color(UIColor.systemBackground) : Color(UIColor.tertiarySystemBackground))
                        .font(.title2)
                }
            }
            .padding(.leading, 20)
            .padding(.trailing, 20)
            
            Form {
                Section(header: Text("\(Image(systemName: "pencil.tip")) Line Width")) {
                    Group {
                        HStack {
                            Text("Width: \(Int(self.drawing.lineWidth))")
                            Slider(value: $drawing.lineWidth, in: 1...100)
                        }
                    }
                }
                Section(header: Text("\(Image(systemName: "scribble.variable")) Line blur")) {
                    Group {
                        HStack {
                            Text("Softness: \(Int(self.drawing.blurAmount))")
                            Slider(value: $drawing.blurAmount, in: 0...50)
                        }
                    }
                }
                Section(header: Text("\(Image(systemName: "circle.dashed")) Line Spacing")) {
                    Group {
                        HStack {
                            Text("Spacing: \(drawing.lineSpacing, format: .percent)")
                            Slider(value: $drawing.lineSpacing, in: 0...5, step: 0.1)
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
    BrushesView()
        .environmentObject(Drawing())
}
