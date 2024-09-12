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
                    self.dismiss()
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
                            ModernSlider(systemImage: "pencil.tip", value: $drawing.lineWidth)
                                .sensoryFeedback(.increase, trigger: self.drawing.lineWidth)
                            
                            Text(Int(self.drawing.lineWidth).description)
                                .fontWeight(.medium)
                        }
                    }
                }
                Section(header: Text("\(Image(systemName: "scribble.variable")) Line blur")) {
                    Group {
                        HStack {
                            ModernSlider(systemImage: "scribble.variable", value: $drawing.blurAmount)
                                .sensoryFeedback(.increase, trigger: self.drawing.blurAmount)
                            
                            Text(Int(self.drawing.blurAmount).description)
                                .fontWeight(.medium)
                        }
                    }
                }
                Section(header: Text("\(Image(systemName: "ellipsis")) Line Spacing")) {
                    Group {
                        HStack {
                            ModernSlider(systemImage: "ellipsis", value: $drawing.lineSpacing)
                                .sensoryFeedback(.increase, trigger: self.drawing.lineSpacing)
                            
                            Text("\(Int(self.drawing.lineSpacing).description)")
                                .fontWeight(.medium)
//                                .scaledToFill()
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
                                .sensoryFeedback(.selection, trigger: self.drawing.fillColor)
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
        .preferredColorScheme(.light)
        .environmentObject(Drawing())
}

#Preview {
    ToolPreferencesView()
        .preferredColorScheme(.dark)
        .environmentObject(Drawing())
}
