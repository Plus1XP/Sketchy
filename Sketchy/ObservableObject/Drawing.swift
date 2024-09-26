//
//  Drawing.swift
//  Sketchy
//
//  Created by nabbit on 30/08/2024.
//

import SwiftUI
import UniformTypeIdentifiers

class Drawing: ObservableObject, ReferenceFileDocument {
    private var currentStroke = Stroke()
    private var sketchModel = SketchModel(artCanvas: ArtCanvas(), oldStrokes: [Stroke]())
    static var readableContentTypes = [UTType(exportedAs: "io.plus1xp.sketchy")]
    var undoManager: UndoManager?
    var strokes: [Stroke] {
        var all = self.sketchModel.oldStrokes
        all.append(self.currentStroke)
        return all
    }
    
    @Published var canSetCanvasDefaults = false
        
    @Published var safeAreaOverride = false
    
    @Published var orientationOverride = false
    
    @Published var ignoreSafeArea = true {
        didSet {
            self.sketchModel.artCanvas.fullscreen = self.ignoreSafeArea
            debugPrint("Canvas Size changed: \(self.ignoreSafeArea)")
        }
    }
    
    @Published var orientation = OrientationType.automatic {
        didSet {
            self.sketchModel.artCanvas.orientation = self.orientation
            debugPrint("Portrait changed: \(self.orientation)")
        }
    }
    
    @Published var lock = false {
        didSet {
            self.sketchModel.artCanvas.lock = self.lock
            debugPrint("Lock changed: \(self.lock)")
        }
    }
    
    @Published var backgroundColor = Color.clear {
        didSet {
            self.sketchModel.artCanvas.color = self.backgroundColor
            debugPrint("Canvas Color changed: \(self.backgroundColor)")
        }
    }

    @Published var foregroundColor = Color.primary {
        didSet {
            self.currentStroke.color = self.foregroundColor
            newStroke()
            debugPrint("Brush Color changed: \(self.foregroundColor)")
        }
    }

    @Published var lineWidth = 3.0 {
        didSet {
            self.currentStroke.width = self.lineWidth
            debugPrint("Brush Width changed: \(self.lineWidth)")
        }
    }

    @Published var lineSpacing = 0.0 {
        didSet {
            self.currentStroke.spacing = self.lineSpacing
            debugPrint("Brush Spacing changed: \(self.lineSpacing)")
        }
    }

    @Published var blurAmount = 0.0 {
        didSet {
            self.currentStroke.blur = self.blurAmount
            debugPrint("Brush Blur changed: \(self.blurAmount)")
        }
    }
    
    @Published var canFill = false {
        didSet {
            self.currentStroke.fill = self.canFill
            debugPrint("Shape Fill changed: \(self.canFill)")
            if canFill {
                self.fillColor = self.foregroundColor
            } else {
                self.fillColor = Color.clear
            }
        }
    }
    
    @Published var fillColor = Color.clear {
        didSet {
            self.currentStroke.fillColor = self.fillColor
            debugPrint("Fill Color changed: \(String(describing: self.fillColor))")
        }
    }
    
    @Published var selectedTool = ToolType.brush {
        didSet {
            self.currentStroke.tool = self.selectedTool
            debugPrint("Tool Selection changed: \(self.selectedTool)")
        }
    }

    init() {}

    // MARK: Loading from and saving to a file
    
    // Initialize from FileWrapper (decode JSON)
    required init(configuration: ReadConfiguration) throws {
        if let decodedData = configuration.file.regularFileContents {
            // Try decoding with the new v2 model first
            do {
                self.sketchModel = try JSONDecoder().decode(SketchModel.self, from: decodedData)
                debugPrint("Read New File Type: \(self.sketchModel)")
                // Use the artCanvas information from the new format
                self.backgroundColor = self.sketchModel.artCanvas.color
                self.ignoreSafeArea = self.sketchModel.artCanvas.fullscreen
                self.orientation = self.sketchModel.artCanvas.orientation
                self.lock = self.sketchModel.artCanvas.lock
                if let lastStroke = self.sketchModel.oldStrokes.last {
                    self.foregroundColor = lastStroke.color
                    self.lineWidth = lastStroke.width
                    self.lineSpacing = lastStroke.spacing
                    self.blurAmount = lastStroke.blur
                    self.canFill = lastStroke.fill
                    self.fillColor = lastStroke.fillColor
                    self.selectedTool = lastStroke.tool
                }
                debugPrint("Successfully decoded new format")
            } catch {
                // Fallback: Handle the old format
                // If decoding fails, try decoding with the old model
                do {
                    // Try to decode the old v1 format
                    let oldStrokes = try JSONDecoder().decode([LegacyStroke].self, from: decodedData)
                    debugPrint("Read Old File Type: \(oldStrokes)")
                    // Map old strokes to new strokes
                    let newStrokes = oldStrokes.map { oldStroke in
                        Stroke(
                            id: UUID(), // Assign a new UUID
                            points: oldStroke.points,
                            color: oldStroke.color,
                            width: oldStroke.width,
                            spacing: oldStroke.spacing,
                            blur: oldStroke.blur,
                            fill: false, // Default value for new fields
                            fillColor: Color.clear, // Default value for new fields
                            tool: .brush // Default value for new fields
                        )
                    }
                    // Choice of using customArtCanvas or a new Init with defaults.
                    self.sketchModel = SketchModel(artCanvas: ArtCanvas(), oldStrokes: newStrokes)
                    debugPrint("Successfully decoded and migrated old format")
                } catch {
                    debugPrint("Decoding error: \(error)")
                    throw CocoaError(.fileReadCorruptFile)
                }
            }
        } else {
            debugPrint("Failed to read before loading")
            throw CocoaError(.fileReadCorruptFile)
        }
        self.canSetCanvasDefaults = true
    }
    
    
    func snapshot(contentType: UTType) throws -> SketchModel {
        return self.sketchModel
    }
    
    // Encode JSON and save it in FileWrapper
    func fileWrapper(snapshot: SketchModel, configuration: WriteConfiguration) throws -> FileWrapper {
        let encodedData = try JSONEncoder().encode(snapshot)
        debugPrint("Save File: \(snapshot)")
        return FileWrapper(regularFileWithContents: encodedData)
       }

    // MARK: Drawing interactions
    
    func setCanvasDefaults(colorScheme: ColorScheme, canIgnoreSafeArea: Bool, orientation: OrientationType) {
        if self.isOldStrokesEmpty() {
            debugPrint("Color Scheme: \(colorScheme)")
            if colorScheme == .light {
                self.setCanvasColor(colorScheme: colorScheme)
                self.setBrushColor(colorScheme: colorScheme)
            } else {
                self.setCanvasColor(colorScheme: colorScheme)
                self.setBrushColor(colorScheme: colorScheme)
            }
            self.setSafeArea(canIgnoreSafeArea: canIgnoreSafeArea)
            self.setOrientation(orientation: orientation)
            self.safeAreaOverride = false
            self.orientationOverride = false
        }
    }
    
    func isCurrentStrokeEmpty() -> Bool {
        return self.currentStroke.points.isEmpty
    }
    
    func isOldStrokesEmpty() -> Bool {
        return self.sketchModel.oldStrokes.isEmpty
    }
    
    func setSafeArea(canIgnoreSafeArea: Bool) {
        self.ignoreSafeArea = canIgnoreSafeArea
    }
    
    func setOrientation(orientation: OrientationType) {
        self.orientation = orientation
    }
    
    func setCanvasColor(colorScheme: ColorScheme) {
        self.backgroundColor = colorScheme == .light ? .white : .black
    }
    
    func setBrushColor(colorScheme: ColorScheme) {
        self.foregroundColor = colorScheme == .light ? .black : .white
    }
    
    func overideFullSizeCanvas(userPrefs: Bool) -> Bool {
        if self.safeAreaOverride {
            return userPrefs
        } else {
            return self.ignoreSafeArea
        }
    }
    
    func overideOrientation(userPrefs: OrientationType) -> OrientationType {
        if self.orientationOverride {
            return userPrefs
        } else {
            return self.orientation
        }
    }

    // Functions to generate shape points
    func generatePolygonPoints(sides: Int, center: CGPoint, radius: CGFloat) -> [CGPoint] {
        guard sides >= 3 else { return [] } // A polygon must have at least 3 sides
        var points: [CGPoint] = []
        for i in 0..<sides {
            let angle = (CGFloat(i) * 2 * .pi / CGFloat(sides)) - .pi / 2
            let point = CGPoint(x: center.x + cos(angle) * radius, y: center.y + sin(angle) * radius)
            points.append(point)
        }

        // Close the path by adding the first point at the end
        points.append(points.first!)
        return points
    }
   
    func generateOctagonPoints(center: CGPoint, radius: CGFloat) -> [CGPoint] {
        var result: [CGPoint] = []
        let adjustment = CGFloat.pi / 8 // Adjusting for proper rotation of octagon
        for i in 0..<8 {  // 8 points for the octagon
            let angle = (CGFloat(i) * CGFloat.pi / 4) - adjustment  // Each angle is 45 degrees (pi/4 radians)
            let point = CGPoint( x: center.x + cos(angle) * radius, y: center.y + sin(angle) * radius)
            result.append(point)
        }

        // Close the path by adding the first point at the end
        result.append(result.first!)
        return result
    }

    func generateStarPoints(center: CGPoint, radius: CGFloat, points: Int = 5) -> [CGPoint] {
        var result: [CGPoint] = []
        let adjustment = CGFloat.pi / 2
        for i in 0..<(points * 2) {
            let angle = (CGFloat(i) * .pi / CGFloat(points)) - adjustment
            let length = i % 2 == 0 ? radius : radius / 2
            let point = CGPoint(x: center.x + cos(angle) * length, y: center.y + sin(angle) * length)
            result.append(point)
        }

        // Close the path by adding the first point at the end
        result.append(result.first!)
        return result
    }
    
    func addBrush(point: CGPoint) {
        objectWillChange.send()
        self.currentStroke.points.append(point)
    }
    
    func addLine(startPoint: CGPoint, endPoint: CGPoint) {
        objectWillChange.send()
        self.currentStroke.points = [startPoint, endPoint]
    }
    
    func addCircle(startPoint: CGPoint, endPoint: CGPoint) {
        objectWillChange.send()
        let center = CGPoint(x: (startPoint.x + endPoint.x) / 2, y: (startPoint.y + endPoint.y) / 2)
        let radius = hypot(endPoint.x - startPoint.x, endPoint.y - startPoint.y) / 2
        self.currentStroke.points = [center, CGPoint(x: radius, y: 0)] // Storing center and radius
    }
    
    func addTriangle(startPoint: CGPoint, endPoint: CGPoint) {
        objectWillChange.send()
        let center = CGPoint(x: (startPoint.x + endPoint.x) / 2, y: (startPoint.y + endPoint.y) / 2)
        let radius = hypot(endPoint.x - startPoint.x, endPoint.y - startPoint.y) / 2
        self.currentStroke.points = generatePolygonPoints(sides: 3, center: center, radius: radius)
    }
    
    func addSquare(startPoint: CGPoint, endPoint: CGPoint) {
        objectWillChange.send()
        let origin = CGPoint(x: min(startPoint.x, endPoint.x), y: min(startPoint.y, endPoint.y))
        let size = CGSize(width: abs(startPoint.x - endPoint.x), height: abs(startPoint.y - endPoint.y))
        let topRight = CGPoint(x: origin.x + size.width, y: origin.y)
        let bottomRight = CGPoint(x: origin.x + size.width, y: origin.y + size.height)
        let bottomLeft = CGPoint(x: origin.x, y: origin.y + size.height)
        self.currentStroke.points = [origin, topRight, bottomRight, bottomLeft, origin]
    }

    func addPentagon(startPoint: CGPoint, endPoint: CGPoint) {
        objectWillChange.send()
        let center = CGPoint(x: (startPoint.x + endPoint.x) / 2, y: (startPoint.y + endPoint.y) / 2)
        let radius = hypot(endPoint.x - startPoint.x, endPoint.y - startPoint.y) / 2
        self.currentStroke.points = generatePolygonPoints(sides: 5, center: center, radius: radius)
    }

    func addHexagon(startPoint: CGPoint, endPoint: CGPoint) {
        objectWillChange.send()
        let center = CGPoint(x: (startPoint.x + endPoint.x) / 2, y: (startPoint.y + endPoint.y) / 2)
        let radius = hypot(endPoint.x - startPoint.x, endPoint.y - startPoint.y) / 2
        self.currentStroke.points = generatePolygonPoints(sides: 6, center: center, radius: radius)
    }
    
    func addOctagon(startPoint: CGPoint, endPoint: CGPoint) {
        objectWillChange.send()
        let center = CGPoint(x: (startPoint.x + endPoint.x) / 2, y: (startPoint.y + endPoint.y) / 2)
        let radius = hypot(endPoint.x - startPoint.x, endPoint.y - startPoint.y) / 2
        self.currentStroke.points = generateOctagonPoints(center: center, radius: radius)
    }
    
    func addDiamond(startPoint: CGPoint, endPoint: CGPoint) {
        objectWillChange.send()
        let center = CGPoint(x: (startPoint.x + endPoint.x) / 2, y: (startPoint.y + endPoint.y) / 2)
        let width = abs(endPoint.x - startPoint.x)
        let height = abs(endPoint.y - startPoint.y)
        let halfWidth = width / 2
        let halfHeight = height / 2
        let top = CGPoint(x: center.x, y: center.y - halfHeight)
        let right = CGPoint(x: center.x + halfWidth, y: center.y)
        let bottom = CGPoint(x: center.x, y: center.y + halfHeight)
        let left = CGPoint(x: center.x - halfWidth, y: center.y)
        self.currentStroke.points = [top, right, bottom, left, top]
    }
    
    func addStar(startPoint: CGPoint, endPoint: CGPoint) {
        objectWillChange.send()
        let center = CGPoint(x: (startPoint.x + endPoint.x) / 2, y: (startPoint.y + endPoint.y) / 2)
        let radius = hypot(endPoint.x - startPoint.x, endPoint.y - startPoint.y) / 2
        self.currentStroke.points = generateStarPoints(center: center, radius: radius)
    }
    
    func useEraser(point: CGPoint) {
          objectWillChange.send()
          self.currentStroke.points.append(point)
      }
    
    func removeLastStroke() {
        objectWillChange.send()
        if !currentStroke.points.isEmpty {
            self.currentStroke.points.removeLast()
        }
    }

    func finishedStroke() {
        objectWillChange.send()
        if undoManager == nil {
            print("No undoManager")
        }
        self.addStrokeWithUndo(self.currentStroke)
    }

    func newStroke() {
        self.currentStroke = Stroke(color: self.foregroundColor, width: self.lineWidth, spacing: self.lineSpacing, blur: self.blurAmount, fill: self.canFill, fillColor: self.fillColor, tool: self.selectedTool)
    }
    
    func removeOldStroke() {
        objectWillChange.send()
        self.sketchModel.oldStrokes.removeLast()
        self.newStroke()
    }
    
    func oldStrokeHistory() -> Int {
        return self.sketchModel.oldStrokes.count
    }
    
    func clearCanvas(colorScheme: ColorScheme, canIgnoreSafeArea: Bool, orientation: OrientationType) {
        if !self.sketchModel.oldStrokes.isEmpty {
            objectWillChange.send()
            self.sketchModel.oldStrokes.removeAll()
            self.undoManager?.removeAllActions()
            self.lineWidth = 3.0
            self.lineSpacing = 0.0
            self.blurAmount = 0.0
            self.canFill = false
            self.fillColor = .clear
            self.selectedTool = .brush
            self.setCanvasDefaults(colorScheme: colorScheme, canIgnoreSafeArea: canIgnoreSafeArea, orientation: orientation)
            self.newStroke()
        }
    }
    
    // MARK: Undo & Redo support

    func undo() {
        objectWillChange.send()
        self.undoManager?.undo()
    }

    func redo() {
        objectWillChange.send()
        self.undoManager?.redo()
    }

    private func addStrokeWithUndo(_ stroke: Stroke) {
        self.undoManager?.registerUndo(withTarget: self, handler: { drawing in
            drawing.removeStrokeWithUndo(stroke)
        })

        self.sketchModel.oldStrokes.append(stroke)
        self.newStroke()
    }

    private func removeStrokeWithUndo(_ stroke: Stroke) {
        self.undoManager?.registerUndo(withTarget: self, handler: { drawing in
            drawing.addStrokeWithUndo(stroke)
        })
        if !sketchModel.oldStrokes.isEmpty {
            self.sketchModel.oldStrokes.removeLast()
        }
    }
}
