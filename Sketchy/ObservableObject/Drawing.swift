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
    
    @Published var backgroundColor = Color.clear {
        didSet {
            self.sketchModel.artCanvas.color = self.backgroundColor
            debugPrint("Canvas Color changed: \(self.backgroundColor)")
        }
    }

    @Published var foregroundColor = Color.primary {
        didSet {
            self.currentStroke.color = self.foregroundColor
            debugPrint("Brush Color changed: \(self.foregroundColor)")
        }
    }

    @Published var lineWidth = 3.0 {
        didSet {
            self.currentStroke.width = self.lineWidth
        }
    }

    @Published var lineSpacing = 0.0 {
        didSet {
            self.currentStroke.spacing = self.lineSpacing
        }
    }

    @Published var blurAmount = 0.0 {
        didSet {
            self.currentStroke.blur = self.blurAmount
        }
    }

    init() {}

    // MARK: Loading from and saving to a file
    
    // Initialize from FileWrapper (decode JSON)
    required init(configuration: ReadConfiguration) throws {
        if let decodedData = configuration.file.regularFileContents {
            self.sketchModel = try JSONDecoder().decode(SketchModel.self, from: decodedData)
            debugPrint("Read File: \(self.sketchModel)")
            
            self.backgroundColor = self.sketchModel.artCanvas.color
            if let lastStroke = self.sketchModel.oldStrokes.last {
                self.foregroundColor = lastStroke.color
                self.lineWidth = lastStroke.width
                self.lineSpacing = lastStroke.spacing
                self.blurAmount = lastStroke.blur
            }
        } else {
            throw CocoaError(.fileReadCorruptFile)
        }
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
    
    func setCanvasDefaults(colorScheme: ColorScheme) {
        if self.sketchModel.oldStrokes.isEmpty {
            debugPrint("Color Scheme: \(colorScheme)")
            if colorScheme == .light {
                self.setCanvasColor(colorScheme: colorScheme)
                self.setBrushColor(colorScheme: colorScheme)
            } else {
                self.setCanvasColor(colorScheme: colorScheme)
                self.setBrushColor(colorScheme: colorScheme)
            }
        }
    }
    
    func setCanvasColor(colorScheme: ColorScheme) {
        self.backgroundColor = colorScheme == .light ? .white : .black
    }
    
    func setBrushColor(colorScheme: ColorScheme) {
        self.foregroundColor = colorScheme == .light ? .black : .white
    }

    func add(point: CGPoint) {
        objectWillChange.send()
        self.currentStroke.points.append(point)
    }
    
    func removeLastStroke() {
        objectWillChange.send()
        self.currentStroke.points.removeLast()
    }

    func finishedStroke() {
        objectWillChange.send()
        self.addStrokeWithUndo(self.currentStroke)
    }

    func newStroke() {
        self.currentStroke = Stroke(color: self.foregroundColor, width: self.lineWidth, spacing: self.lineSpacing, blur: self.blurAmount)
    }
    
    func removeOldStroke() {
        objectWillChange.send()
        self.sketchModel.oldStrokes.removeLast()
        self.newStroke()
    }
    
    func oldStrokeHistory() -> Int {
        return self.sketchModel.oldStrokes.count
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

        self.sketchModel.oldStrokes.removeLast()
    }
}
