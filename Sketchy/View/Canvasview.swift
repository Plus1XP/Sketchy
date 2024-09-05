//
//  Canvasview.swift
//  Sketchy
//
//  Created by nabbit on 05/09/2024.
//

import SwiftUI
import Combine

struct CanvasView: View {
    @EnvironmentObject var drawing: Drawing
    @Environment(\.undoManager) var undoManager
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.verticalSizeClass) var verticalScreenSize
    @State private var showingToolPreferences: Bool = false
    @State private var canShowSettingsView: Bool = false
    @State private var canShowDeleteAlert: Bool = false
    @State private var startPoint: CGPoint = .zero
    @State private var lastOrientation: UIDeviceOrientation? = nil
    @State private var orientation: UIDeviceOrientation? = nil
    @State private var orientationChangePublisher: AnyCancellable?
    @State var animateUndo: Bool = false
    @State var animateRedo: Bool = false
    @State var animateUndoHistory: Bool = false
    @State var animateTrash: Bool = false
    @AppStorage("canIgnoreSafeArea") var canIgnoreSafeArea: Bool = true
    @AppStorage("isCanvasHapticsEnabled") var isCanvasHapticsEnabled: Bool = true
    @AppStorage("canvasHapticsIntensity") var canvasHapticsIntensity: Double = 0.38

    var body: some View {
        Canvas { context, size in
            context.fill(Path(CGRect(origin: .zero, size: size)), with: .color(self.drawing.backgroundColor))
            
            // Draw all strokes
            for stroke in self.drawing.strokes {
                self.drawStroke(stroke, in: context)
            }
        }
        .gesture(DragGesture(minimumDistance: 0)
            .onChanged { value in
                debugPrint("Drawing..\(value.location)")
                if isCanvasHapticsEnabled {
                    UIImpactFeedbackGenerator(style: .soft).impactOccurred(intensity: canvasHapticsIntensity)
                }
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
        .ignoresSafeArea(edges: self.drawing.ignoreSafeArea ? .all : [])
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                HStack {
                    ColorPicker("Color", selection: $drawing.foregroundColor)
                        .labelsHidden()
                        .sensoryFeedback(.selection, trigger: drawing.foregroundColor)
                    Button(action: {
                        self.showingToolPreferences.toggle()
                        UISelectionFeedbackGenerator().selectionChanged()
                    }) {
                        Label("Tool Preferences", systemImage: "slider.horizontal.3")
                            .foregroundColor(.accentColor)
                            .symbolEffect( .bounce, options: .speed(2), value: self.showingToolPreferences)
                    }
                    Menu {
                        Button(action: {
                            self.drawing.selectedTool = .brush
                            UISelectionFeedbackGenerator().selectionChanged()
                        }, label: {
                            Label(ToolType.brush.label, systemImage: ToolType.brush.symbolChoice)
                        })
                        
                        Button(action: {
                            self.drawing.selectedTool = .line
                            UISelectionFeedbackGenerator().selectionChanged()
                        }, label: {
                            Label(ToolType.line.label, systemImage: ToolType.line.symbolChoice)
                        })
                        
                        Button(action: {
                            self.drawing.selectedTool = .circle
                            UISelectionFeedbackGenerator().selectionChanged()
                        }, label: {
                            Label(ToolType.circle.label, systemImage: ToolType.circle.symbolChoice)
                        })
                        
                        Button(action: {
                            self.drawing.selectedTool = .square
                            UISelectionFeedbackGenerator().selectionChanged()
                        }, label: {
                            Label(ToolType.square.label, systemImage: ToolType.square.symbolChoice)
                        })
                        
                        Button(action: {
                            self.drawing.selectedTool = .eraser
                            UISelectionFeedbackGenerator().selectionChanged()
                        }, label: {
                            Label(ToolType.eraser.label, systemImage: ToolType.eraser.symbolChoice)
                        })
                    } label: {
                        Label("Tools", systemImage: self.drawing.selectedTool.symbolChoice)
                    }
                }
            }
            if UIDevice.current.userInterfaceIdiom == .phone && verticalScreenSize == .regular {
                ToolbarItemGroup(placement: .bottomBar) {
                    HStack() {
                        Spacer()
                        // Repeat behaviour not working unless button is in view directly
                        Button(action: {
                            self.animateUndo.toggle()
                            self.drawing.undo()
                            UIImpactFeedbackGenerator(style: .soft).impactOccurred(intensity: 0.8)
                        }, label: {
                            Label("Undo", systemImage: "arrow.uturn.backward")
                                .symbolEffect( .bounce, options: .speed(2), value: self.animateUndo)
                        })
                        .buttonRepeatBehavior(.enabled)
                        .disabled(self.undoManager?.canUndo == false)
                        Button(action: {
                            self.animateRedo.toggle()
                            self.drawing.redo()
                            UIImpactFeedbackGenerator(style: .soft).impactOccurred(intensity: 0.8)
                        }, label: {
                            Label("Redo", systemImage: "arrow.uturn.forward")
                                .symbolEffect( .bounce, options: .speed(2), value: self.animateRedo)
                        })
                        .buttonRepeatBehavior(.enabled)
                        .disabled(self.undoManager?.canRedo == false)
                        Button(action: {
                            self.animateUndoHistory.toggle()
                            self.drawing.removeOldStroke()
                            UIImpactFeedbackGenerator(style: .soft).impactOccurred(intensity: 0.8)
                        }, label: {
                            Label("Undo History", image: "custom.arrow.uturn.backward.badge.clock")
                                .symbolEffect(.bounce.up.byLayer, options: .speed(1), value: self.animateUndoHistory)
                        })
                        .buttonRepeatBehavior(.enabled)
                        .disabled(self.drawing.oldStrokeHistory() == 0 || self.undoManager?.canUndo == true)
                        Button(action: {
                            self.canShowDeleteAlert.toggle()
                            UINotificationFeedbackGenerator().notificationOccurred(.warning)
                        }, label: {
                            Label("Clear Canvas", systemImage: "trash")
                                .symbolEffect(.pulse.wholeSymbol, options: .speed(3), value: self.canShowDeleteAlert)
                                .contentTransition(.symbolEffect(.replace))
                        })
                        .disabled(self.drawing.oldStrokeHistory() == 0)
                        .alert("Are you sure you want to clear the canvas?", isPresented: $canShowDeleteAlert) {
                            Button("OK", role: .destructive) {
                                self.drawing.clearCanvas(colorScheme: colorScheme, canIgnoreSafeArea: self.canIgnoreSafeArea)
                                UINotificationFeedbackGenerator().notificationOccurred(.success)
                            }
                            Button("cancel", role: .cancel) {

                            }
                        }
                    }
                }
            } else {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    HStack {
                        Divider()
//                            .frame(width: 1)
//                            .overlay(.secondary)
                        // Repeat behaviour not working unless button is in view directly
                        Button(action: {
                            self.animateUndo.toggle()
                            self.drawing.undo()
                            UIImpactFeedbackGenerator(style: .soft).impactOccurred(intensity: 0.8)
                        }, label: {
                            Label("Undo", systemImage: "arrow.uturn.backward")
                                .symbolEffect( .bounce, options: .speed(2), value: self.animateUndo)
                        })
                        .buttonRepeatBehavior(.enabled)
                        .disabled(self.undoManager?.canUndo == false)
                        Button(action: {
                            self.animateRedo.toggle()
                            self.drawing.redo()
                            UIImpactFeedbackGenerator(style: .soft).impactOccurred(intensity: 0.8)
                        }, label: {
                            Label("Redo", systemImage: "arrow.uturn.forward")
                                .symbolEffect( .bounce, options: .speed(2), value: self.animateRedo)
                        })
                        .buttonRepeatBehavior(.enabled)
                        .disabled(self.undoManager?.canRedo == false)
                        Button(action: {
                            self.animateUndoHistory.toggle()
                            self.drawing.removeOldStroke()
                            UIImpactFeedbackGenerator(style: .soft).impactOccurred(intensity: 0.8)
                        }, label: {
                            Label("Undo History", image: "custom.arrow.uturn.backward.badge.clock")
                                .symbolEffect(.bounce.up.byLayer, options: .speed(1), value: self.animateUndoHistory)
                        })
                        .buttonRepeatBehavior(.enabled)
                        .disabled(self.drawing.oldStrokeHistory() == 0 || self.undoManager?.canUndo == true)
                        Button(action: {
                            self.canShowDeleteAlert.toggle()
                            UINotificationFeedbackGenerator().notificationOccurred(.warning)
                        }, label: {
                            Label("Clear Canvas", systemImage: "trash")
                                .symbolEffect(.pulse.wholeSymbol, options: .speed(3), value: self.canShowDeleteAlert)
                                .contentTransition(.symbolEffect(.replace))
                        })
                        .disabled(self.drawing.oldStrokeHistory() == 0)
                        .alert("Are you sure you want to clear the canvas?", isPresented: $canShowDeleteAlert) {
                            Button("OK", role: .destructive) {
                                self.drawing.clearCanvas(colorScheme: colorScheme, canIgnoreSafeArea: self.canIgnoreSafeArea)
                                UINotificationFeedbackGenerator().notificationOccurred(.success)
                            }
                            Button("cancel", role: .cancel) {
                            }
                        }
                    }
                }
            }
        }
        .onAppear {
            self.drawing.undoManager = self.undoManager
            debugPrint("Loading Canvas Preferences")
            self.drawing.setCanvasDefaults(colorScheme: self.colorScheme, canIgnoreSafeArea: self.canIgnoreSafeArea)
            self.orientationChangePublisher = NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)
                .compactMap { notification in
                    UIDevice.current.orientation
                }
                .sink { newOrientation in
                    orientation = newOrientation
                    print("isLandscape: \(orientation?.isLandscape ?? false))")
                    print("isPortrait: \(orientation?.isPortrait ?? false))")
                    print("isFlat: \(orientation?.isFlat ?? false))")
                }
        }
        .onDisappear{
            orientationChangePublisher?.cancel()
        }
        .sheet(isPresented: $showingToolPreferences) {
            ToolPreferencesView()
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
        if stroke.fill {
            context.fill(circlePath, with: .color(stroke.fillColor))
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
        if stroke.fill {
            context.fill(path, with: .color(stroke.fillColor))
        }
        contextCopy.stroke(path, with: .color(stroke.color), style: StrokeStyle(lineWidth: stroke.width, lineCap: .round, lineJoin: .round, dash: [1, stroke.spacing * stroke.width])
        )
    }
}

#Preview {
    CanvasView()
        .environmentObject(Drawing())
}
