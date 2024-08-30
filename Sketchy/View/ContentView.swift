//
//  ContentView.swift
//  Sketchy
//
//  Created by nabbit on 30/08/2024.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var drawing: Drawing
    @Environment(\.undoManager) var undoManager
    @State private var showingBrushOptions: Bool = false
    @State private var canShowSettingsView: Bool = false

    var body: some View {
        Canvas { context, size in
            for stroke in self.drawing.strokes {
                let path = Path(curving: stroke.points)

                var contextCopy = context

                if stroke.blur > 0 {
                    contextCopy.addFilter(.blur(radius: stroke.blur))
                }

                contextCopy.stroke(
                    path,
                    with: .color(stroke.color),
                    style: StrokeStyle(lineWidth: stroke.width,
                                       lineCap: .round, lineJoin: .round,
                                       dash: [1, stroke.spacing * stroke.width])
                )
            }
        }
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    self.drawing.add(point: value.location)
                }
                .onEnded { _ in
                    self.drawing.finishedStroke()
                }
        )
        .ignoresSafeArea()
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarLeading) {
                Button(action: self.drawing.undo) {
                    Label("Undo", systemImage: "arrow.uturn.backward")
                }
                .disabled(undoManager?.canUndo == false)

                Button(action: self.drawing.redo) {
                    Label("Redo", systemImage: "arrow.uturn.forward")
                }
                .disabled(undoManager?.canRedo == false)
            }

            ToolbarItemGroup(placement: .navigationBarTrailing) {
                ColorPicker("Color", selection: $drawing.foregroundColor)
                    .labelsHidden()

                Button(action: { showingBrushOptions.toggle() }) {
                    Label("Brush", systemImage: "paintbrush.pointed.fill")
                        .foregroundColor(.primary)
                }
                .popover(isPresented: $showingBrushOptions) {
                    BrushesView()
                }
            }
        }
        .onAppear {
            self.drawing.undoManager = undoManager
        }
        .sheet(isPresented: $canShowSettingsView) {
            SettingsView()
        }
        .onShake {
            let feedbackGenerator: UINotificationFeedbackGenerator? = UINotificationFeedbackGenerator()
            feedbackGenerator?.notificationOccurred(.success)
            canShowSettingsView.toggle()
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(Drawing())
}
