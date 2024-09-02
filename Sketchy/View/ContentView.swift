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
    @Environment(\.colorScheme) private var colorScheme
    @State private var showingBrushOptions: Bool = false
    @State private var showingCanvasOptions: Bool = false
    @State private var canShowSettingsView: Bool = false
    @State private var canShowMoreMenu: Bool = false
    @AppStorage("canIgnoreSafeArea") var canIgnoreSafeArea: Bool = false

    var body: some View {
        Canvas { context, size in
            context.fill(Path(CGRect(origin: .zero, size: size)), with: .color(self.drawing.backgroundColor))
            
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
                    debugPrint("Canvas Color: \(self.drawing.backgroundColor)")
                    debugPrint("Brush Color: \(self.drawing.foregroundColor)")
                    self.drawing.finishedStroke()
                }
        )
        .ignoresSafeArea(edges: self.canIgnoreSafeArea ? .all : [])
        
        .toolbar {
            ToolbarItemGroup(placement: .bottomBar) {
                Spacer()
                // Repeat behaviour not working unless button is in view directly
                Button(action: self.drawing.undo) {
                    Label("Undo", systemImage: "arrow.uturn.backward")
                }
                .buttonRepeatBehavior(.enabled)
                .disabled(self.undoManager?.canUndo == false)
                
                Button(action: self.drawing.redo) {
                    Label("Redo", systemImage: "arrow.uturn.forward")
                }
                .buttonRepeatBehavior(.enabled)
                .disabled(self.undoManager?.canRedo == false)
                
                Button(action: self.drawing.removeOldStroke) {
                    Label("Undo History", image: "custom.arrow.uturn.backward.badge.clock")
                }
                .buttonRepeatBehavior(.enabled)
                .disabled(self.drawing.oldStrokeHistory() == 0 || self.undoManager?.canUndo == true)
                Spacer()
            }

            ToolbarItemGroup(placement: .navigationBarTrailing) {
                ColorPicker("Color", selection: $drawing.foregroundColor)
                    .labelsHidden()
                
                Menu {
                    Button(action: { self.showingBrushOptions.toggle() }) {
                        Label("Brush Preferences", systemImage: "paintbrush.pointed.fill")
                            .foregroundColor(.primary)
                    }
                    
                    Button(action: { self.showingCanvasOptions.toggle() }) {
                        Label("Canvas Preferences", systemImage: "photo")
                            .foregroundColor(.primary)
                    }
                    
                } label: {
                    Label("Show Tools", systemImage: "wrench.and.screwdriver")
                }
                .popover(isPresented: $showingBrushOptions) {
                    BrushesPreferencesView()
                }
                .popover(isPresented: $showingCanvasOptions) {

                }
                
                Menu {
                    Button(action: self.drawing.undo) {
                        Label("Undo", systemImage: "arrow.uturn.backward")
                    }
                    .disabled(self.undoManager?.canUndo == false)
                    
                    Button(action: self.drawing.redo) {
                        Label("Redo", systemImage: "arrow.uturn.forward")
                    }
                    .disabled(self.undoManager?.canRedo == false)
                    Button(action: self.drawing.removeOldStroke) {
                        Label("Undo History", image: "custom.arrow.uturn.backward.badge.clock")
                    }
                    .disabled(self.drawing.oldStrokeHistory() == 0 || self.undoManager?.canUndo == true)
                } label: {
                    Label("Show More", systemImage: "ellipsis.circle")
                }
            }
        }
        .onAppear {
            self.drawing.undoManager = self.undoManager
            debugPrint("Loading Canvas Preferences")
            self.drawing.setCanvasDefaults(colorScheme: self.colorScheme)
        }
        .sheet(isPresented: $canShowSettingsView) {
            SettingsView()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            debugPrint("Moving to the Foreground!")
            self.drawing.removeLastStroke()
            self.drawing.newStroke()
        }
        .onShake {
            let feedbackGenerator: UINotificationFeedbackGenerator? = UINotificationFeedbackGenerator()
            feedbackGenerator?.notificationOccurred(.success)
            self.canShowSettingsView.toggle()
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(Drawing())
}
