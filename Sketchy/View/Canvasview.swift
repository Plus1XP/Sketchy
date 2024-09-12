//
//  Canvasview.swift
//  Sketchy
//
//  Created by nabbit on 05/09/2024.
//

import SwiftUI
import Combine

struct CanvasView: View {
    @Environment(\.undoManager) var undoManager
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.verticalSizeClass) var verticalScreenSize
    @EnvironmentObject var drawing: Drawing
    @EnvironmentObject var userConfig: UserConfiguration
    @State private var startPoint: CGPoint = .zero
    @State private var showingToolPreferences: Bool = false
    @State private var canShowSettingsView: Bool = false
    @State private var canShowDeleteAlert: Bool = false
    @State private var canExpandUndoBar: Bool = false
    
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
                if self.userConfig.isCanvasHapticsEnabled {
                    UIImpactFeedbackGenerator(style: .soft).impactOccurred(intensity: self.userConfig.canvasHapticsIntensity)
                }
                if self.drawing.isCurrentStrokeEmpty() {
                    // Initialize the startPoint on the first gesture change
                    self.startPoint = value.startLocation
                }
                switch self.drawing.selectedTool {
                case .brush:
                    self.drawing.addBrush(point: value.location)
                case .circle:
                    self.drawing.addCircle(startPoint: self.startPoint, endPoint: value.location)
                case .diamond:
                    self.drawing.addDiamond(startPoint: self.startPoint, endPoint: value.location)
                case .eraser:
                    self.drawing.useEraser(point: value.location)
                case .hexagon:
                    self.drawing.addHexagon(startPoint: self.startPoint, endPoint: value.location)
                case .line:
                    self.drawing.addLine(startPoint: self.startPoint, endPoint: value.location)
                case .octagon:
                    self.drawing.addOctagon(startPoint: self.startPoint, endPoint: value.location)
                case .pentagon:
                    self.drawing.addPentagon(startPoint: self.startPoint, endPoint: value.location)
                case .star:
                    self.drawing.addStar(startPoint: self.startPoint, endPoint: value.location)
                case .square:
                    self.drawing.addSquare(startPoint: self.startPoint, endPoint: value.location)
                case .triangle:
                    self.drawing.addTriangle(startPoint: self.startPoint, endPoint: value.location)
                }
            }
            .onEnded { value in
                debugPrint("Canvas Color: \(self.drawing.backgroundColor)")
                debugPrint("Brush Color: \(self.drawing.foregroundColor)")
                self.drawing.finishedStroke()
            }
        )
        .ignoresSafeArea(edges: self.setSafeAreas(canIgnoreSafeArea: self.userConfig.canIgnoreSafeArea))
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                HStack {
                    ColorPicker("Color", selection: $drawing.foregroundColor)
                        .labelsHidden()
                        .sensoryFeedback(.selection, trigger: self.drawing.foregroundColor)
                    ToolPreferencesMenuButton(showToolPreferences: $showingToolPreferences)
                    BrushSelectionMenuButton(selectedTool: $drawing.selectedTool)
                }
            }
            if UIDevice.current.userInterfaceIdiom == .phone && self.verticalScreenSize == .regular {
                ToolbarItemGroup(placement: .bottomBar) {
                    ExpandableUndoToolBarGroup(canExpand: $canExpandUndoBar, canShowDeleteAlert: $canShowDeleteAlert)
                        .alert("Are you sure you want to clear the canvas?", isPresented: $canShowDeleteAlert) {
                            Button("OK", role: .destructive) {
                                self.drawing.clearCanvas(colorScheme: self.colorScheme, canIgnoreSafeArea: self.userConfig.canIgnoreSafeArea, orientation: self.userConfig.orientationType)
                                UINotificationFeedbackGenerator().notificationOccurred(.success)
                            }
                            Button("Cancel", role: .cancel) { }
                        }
                }
            } else {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    UndoToolBarGroup(canShowDeleteAlert: $canShowDeleteAlert)
                        .alert("Are you sure you want to clear the canvas?", isPresented: $canShowDeleteAlert) {
                            Button("OK", role: .destructive) {
                                self.drawing.clearCanvas(colorScheme: self.colorScheme, canIgnoreSafeArea: self.userConfig.canIgnoreSafeArea, orientation: self.userConfig.orientationType)
                                UINotificationFeedbackGenerator().notificationOccurred(.success)
                            }
                            Button("cancel", role: .cancel) {
                            }
                        }
                }
            }
        }
        .onAppear {
            self.drawing.undoManager = self.undoManager
            debugPrint("Loading Canvas Preferences")
            self.drawing.setCanvasDefaults(colorScheme: self.colorScheme, canIgnoreSafeArea: self.userConfig.canIgnoreSafeArea, orientation: self.userConfig.orientationType)
            self.setDeviceOrientation(orientation: self.drawing.orientation)
        }
        .onDisappear{
            self.resetDeviceOrientation()
        }
        .onChange(of: self.drawing.orientation, {
            if self.drawing.isOldStrokesEmpty() {
                self.setDeviceOrientation(orientation: self.userConfig.orientationType)
            }
        })
        .onChange(of: self.drawing.orientationOverride, {
            if self.drawing.orientationOverride {
                self.setDeviceOrientation(orientation: self.userConfig.orientationType)
            } else {
                self.setDeviceOrientation(orientation: self.drawing.orientation)
            }
        })
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
}

#Preview {
    CanvasView()
        .environmentObject(Drawing())
        .environmentObject(UserConfiguration())
}
