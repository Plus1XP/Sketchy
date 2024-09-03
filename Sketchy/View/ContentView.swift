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
    @State private var canShowSettingsView: Bool = false
    @State private var startPoint: CGPoint?
    @AppStorage("canIgnoreSafeArea") var canIgnoreSafeArea: Bool = false

    var body: some View {
        Canvas { context, size in
            context.fill(Path(CGRect(origin: .zero, size: size)), with: .color(self.drawing.backgroundColor))
            
            // Draw all strokes
            for stroke in self.drawing.strokes {
                drawStroke(stroke, in: context)
            }
            
            // Draw current stroke
            drawStroke(drawing.currentStroke, in: context)
            
        }
        .gesture(DragGesture(minimumDistance: 0)
            .onChanged { value in
                if let start = startPoint {
                    switch self.drawing.selectedTool {
                    case .circle:
                        self.drawing.addCircle(startPoint: start, endPoint: value.location)
                    case .eraser:
                        self.drawing.useEraser(point: value.location)
                    case .line:
                        self.drawing.addLine(startPoint: start, endPoint: value.location)
                    case .square:
                        self.drawing.addSquare(startPoint: start, endPoint: value.location)
                    default:
                        self.drawing.addBrush(point: value.location)
                    }
                } else {
                    startPoint = value.location
                }
            }
            .onEnded { _ in
                debugPrint("Canvas Color: \(self.drawing.backgroundColor)")
                debugPrint("Brush Color: \(self.drawing.foregroundColor)")
                self.drawing.finishedStroke()
                startPoint = nil
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
                
                Button(action: { self.showingBrushOptions.toggle() }) {
                    Label("Tool Preferences", systemImage: "slider.vertical.3")
                        .foregroundColor(.primary)
                }
                .popover(isPresented: $showingBrushOptions) {
                    BrushesPreferencesView()
                }
                
                Menu {
                    Button(action: {
                        self.drawing.selectedTool = .brush
                    }, label: {
                        Label("Brush", systemImage: "paintbrush.pointed")
                    })
                    
                    Button(action: {
                        self.drawing.selectedTool = .line
                    }, label: {
                        Label("Line", systemImage: "line.diagonal")
                    })
                    
                    Button(action: {
                        self.drawing.selectedTool = .circle
                    }, label: {
                        Label("Circle", systemImage: "circle")
                    })
                    
                    Button(action: {
                        self.drawing.selectedTool = .square
                    }, label: {
                        Label("Retangle", systemImage: "square")
                    })
                    
                    Button(action: {
                        self.drawing.selectedTool = .eraser
                    }, label: {
                        Label("Eraser", systemImage: "eraser")
                    })
                    
                } label: {
                    Label("Tools", systemImage: drawing.selectedTool.symbolChoice)
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
    
    private func drawStroke(_ stroke: Stroke, in context: GraphicsContext) {
        switch stroke.tool {
        case .brush:
            drawBrush(stroke, in: context)
        case .circle:
            drawCircle(stroke, in: context)
        case .eraser:
            drawEraser(stroke, in: context)
        case .fill:
            // Using as filler atm
            drawBrush(stroke, in: context)
        case .line:
            drawLine(stroke, in: context)
        case .square:
            drawSquare(stroke, in: context)
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
