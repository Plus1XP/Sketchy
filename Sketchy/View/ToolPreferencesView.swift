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
    @State var animate: Bool = false
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Button {
                    withAnimation {
                        self.animate.toggle()
                        self.drawing.lineWidth = 3.0
                        self.drawing.blurAmount = 0.0
                        self.drawing.lineSpacing = 0.0
                        UINotificationFeedbackGenerator().notificationOccurred(.success)
                    }
                } label: {
                    Image(systemName: "slider.horizontal.2.gobackward")
                        .font(.title)
                        .symbolEffect(
                            .bounce.up.byLayer,
                            options: .speed(1).repeat(1),
                            value: self.animate
                        )
                        .contentTransition(.symbolEffect(.replace))
                        .rotationEffect(.degrees(self.animate ? -360 : 0))
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
                Section(header: Text("\(Image(systemName: "ellipsis")) Line Spacing")) {
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
                Section(header: Text("\(Image(systemName: "slider.horizontal.below.square.and.square.filled")) Shape Presets")) {
                    Group {
                        HStack {
                            Text("Fill Shape: ")
                            Toggle("Fill Shape:", isOn: $drawing.canFill)
                                .labelsHidden()
                                .sensoryFeedback(.increase, trigger: self.drawing.canFill)
                            Spacer()
                            Text("Fill Color: ")
                            ColorPicker("Fill Color", selection: $drawing.fillColor)
                                .labelsHidden()
                                .sensoryFeedback(.selection, trigger: drawing.fillColor)
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
