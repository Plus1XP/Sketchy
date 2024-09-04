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
    @State private var showingToolPreferences: Bool = false
    @State private var canShowSettingsView: Bool = false
    @State private var canShowDeleteAlert: Bool = false
    @State private var startPoint: CGPoint = .zero
    @AppStorage("canIgnoreSafeArea") var canIgnoreSafeArea: Bool = false

    var body: some View {
        Canvas { context, size in
            context.fill(Path(CGRect(origin: .zero, size: size)), with: .color(self.drawing.backgroundColor))
            
            // Draw all strokes
            for stroke in self.drawing.strokes {
                self.drawStroke(stroke, in: context)
            }
        }
        .sensoryFeedback(.impact(flexibility: .soft, intensity: 0.28), trigger: self.drawing.currentStroke.points)
//        .sensoryFeedback(.impact(weight: .light, intensity: 0.26), trigger: self.drawing.currentStroke.points)
        .gesture(DragGesture(minimumDistance: 0)
            .onChanged { value in
                if drawing.currentStroke.points.isEmpty {
                    // Initialize the startPoint on the first gesture change
                    startPoint = value.startLocation
                }
                switch self.drawing.selectedTool {
                case .brush:
                    self.drawing.addBrush(point: value.location)
                case .circle:
                    self.drawing.addCircle(startPoint: startPoint, endPoint: value.location)
                case .eraser:
                    self.drawing.useEraser(point: value.location)
                case .fill:
                    // Using as filler atm
                    self.drawing.addBrush(point: value.location)
                case .line:
                    self.drawing.addLine(startPoint: startPoint, endPoint: value.location)
                case .square:
                    self.drawing.addSquare(startPoint: startPoint, endPoint: value.location)
                }
            }
            .onEnded { value in
                debugPrint("Canvas Color: \(self.drawing.backgroundColor)")
                debugPrint("Brush Color: \(self.drawing.foregroundColor)")
                self.drawing.finishedStroke()
            }
        )
        .ignoresSafeArea(edges: self.canIgnoreSafeArea ? .all : [])
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                ColorPicker("Color", selection: $drawing.foregroundColor)
                    .labelsHidden()
                    .sensoryFeedback(.selection, trigger: drawing.foregroundColor)
                Button(action: {
                    self.showingToolPreferences.toggle()
                    UISelectionFeedbackGenerator().selectionChanged()
                }) {
                    Label("Tool Preferences", systemImage: "slider.horizontal.3")
                        .foregroundColor(.primary)
                }
                .popover(isPresented: $showingToolPreferences) {
                    ToolPreferencesView()
                }
                
                Menu {
                    Button(action: {
                        self.drawing.selectedTool = .brush
                        UISelectionFeedbackGenerator().selectionChanged()
                    }, label: {
                        Label("Brush", systemImage: "paintbrush.pointed")
                    })
                    
                    Button(action: {
                        self.drawing.selectedTool = .line
                        UISelectionFeedbackGenerator().selectionChanged()
                    }, label: {
                        Label("Line", systemImage: "line.diagonal")
                    })
                    
                    Button(action: {
                        self.drawing.selectedTool = .circle
                        UISelectionFeedbackGenerator().selectionChanged()
                    }, label: {
                        Label("Circle", systemImage: "circle")
                    })
                    
                    Button(action: {
                        self.drawing.selectedTool = .square
                        UISelectionFeedbackGenerator().selectionChanged()
                    }, label: {
                        Label("Retangle", systemImage: "square")
                    })
                    
                    Button(action: {
                        self.drawing.selectedTool = .eraser
                        UISelectionFeedbackGenerator().selectionChanged()
                    }, label: {
                        Label("Eraser", systemImage: "eraser")
                    })
                    
                } label: {
                    Label("Tools", systemImage: self.drawing.selectedTool.symbolChoice)
                }
            }
            
            ToolbarItemGroup(placement: .bottomBar) {
                Spacer()
                // Repeat behaviour not working unless button is in view directly
                Button(action: {
                    self.drawing.undo()
                    UIImpactFeedbackGenerator(style: .soft).impactOccurred(intensity: 0.8)
                }, label: {
                    Label("Undo", systemImage: "arrow.uturn.backward")
                })
                .buttonRepeatBehavior(.enabled)
                .disabled(self.undoManager?.canUndo == false)
                Spacer()
                Button(action: {
                    self.drawing.redo()
                    UIImpactFeedbackGenerator(style: .soft).impactOccurred(intensity: 0.8)
                }, label: {
                    Label("Redo", systemImage: "arrow.uturn.forward")
                })
                .buttonRepeatBehavior(.enabled)
                .disabled(self.undoManager?.canRedo == false)
                Spacer()
                Button(action: {
                    self.drawing.removeOldStroke()
                    UIImpactFeedbackGenerator(style: .soft).impactOccurred(intensity: 0.8)
                }, label: {
                    Label("Undo History", image: "custom.arrow.uturn.backward.badge.clock")
                })
                .buttonRepeatBehavior(.enabled)
                .disabled(self.drawing.oldStrokeHistory() == 0 || self.undoManager?.canUndo == true)
                Spacer()
                Button(action: {
                    self.canShowDeleteAlert.toggle()
                    UINotificationFeedbackGenerator().notificationOccurred(.warning)
                }, label: {
                    Label("Clear Canvas", systemImage: "trash")
                })
                .disabled(self.drawing.oldStrokeHistory() == 0)
                .alert("Are you sure you want to clear the canvas?", isPresented: $canShowDeleteAlert) {
                    Button("OK", role: .destructive) {
                        self.drawing.clearCanvas()
                        UINotificationFeedbackGenerator().notificationOccurred(.success)
                    }
                    Button("cancel", role: .cancel) {
                    }
                }
                Spacer()
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
    
    private func drawStroke(_ stroke: Stroke, in context: GraphicsContext) {
        switch stroke.tool {
        case .brush:
            self.drawBrush(stroke, in: context)
        case .circle:
            self.drawCircle(stroke, in: context)
        case .eraser:
            self.drawEraser(stroke, in: context)
        case .fill:
            // Using as filler atm
            drawBrush(stroke, in: context)
        case .line:
            self.drawLine(stroke, in: context)
        case .square:
            self.drawSquare(stroke, in: context)
        }
    }
    
    // Method to draw brush strokes
    private func drawBrush(_ stroke: Stroke, in context: GraphicsContext) {
        let path = Path(curving: stroke.points)
        
        var contextCopy = context
        if stroke.blur > 0 {
            contextCopy.addFilter(.blur(radius: stroke.blur))
        }
        contextCopy.stroke(path, with: .color(stroke.color), style: StrokeStyle(lineWidth: stroke.width, lineCap: .round, lineJoin: .round, dash: [1, stroke.spacing * stroke.width])
        )
    }
    
    // Method to draw eraser strokes
    private func drawEraser(_ stroke: Stroke, in context: GraphicsContext) {
        let path = Path(curving: stroke.points)
        
        var contextCopy = context
        if stroke.blur > 0 {
            contextCopy.addFilter(.blur(radius: stroke.blur))
        }
        contextCopy.stroke(path, with: .color(self.drawing.backgroundColor), style: StrokeStyle(lineWidth: stroke.width, lineCap: .round, lineJoin: .round, dash: [1, stroke.spacing * stroke.width])
        )
    }
    
    // Method to draw circles
    private func drawCircle(_ stroke: Stroke, in context: GraphicsContext) {
        guard let center = stroke.points.first, let radiusPoint = stroke.points.last else { return }
        let radius = hypot(radiusPoint.x, radiusPoint.y)
        let circlePath = Path(ellipseIn: CGRect(x: center.x - radius, y: center.y - radius, width: radius * 2, height: radius * 2))
        
        var contextCopy = context
        if stroke.blur > 0 {
            contextCopy.addFilter(.blur(radius: stroke.blur))
        }
        contextCopy.stroke(circlePath, with: .color(stroke.color), style: StrokeStyle(lineWidth: stroke.width, lineCap: .round, lineJoin: .round, dash: [1, stroke.spacing * stroke.width])
        )
    }
    
    // Method to draw lines
    private func drawLine(_ stroke: Stroke, in context: GraphicsContext) {
        var path = Path()
        guard let startPoint = stroke.points.first, let endPoint = stroke.points.last else { return }
        path.move(to: startPoint)
        path.addLine(to: endPoint)
        
        var contextCopy = context
        if stroke.blur > 0 {
            contextCopy.addFilter(.blur(radius: stroke.blur))
        }
        contextCopy.stroke(path, with: .color(stroke.color), style: StrokeStyle(lineWidth: stroke.width, lineCap: .round, lineJoin: .round, dash: [1, stroke.spacing * stroke.width])
        )
    }
    
    // Method to draw squares
    private func drawSquare(_ stroke: Stroke, in context: GraphicsContext) {
        var path = Path()
        path.addLines(stroke.points)
        
        var contextCopy = context
        if stroke.blur > 0 {
            contextCopy.addFilter(.blur(radius: stroke.blur))
        }
        contextCopy.stroke(path, with: .color(stroke.color), style: StrokeStyle(lineWidth: stroke.width, lineCap: .round, lineJoin: .round, dash: [1, stroke.spacing * stroke.width])
        )
    }
}

#Preview {
    ContentView()
        .environmentObject(Drawing())
}
