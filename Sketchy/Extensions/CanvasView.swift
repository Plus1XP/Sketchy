//
//  CanvasView.swift
//  Sketchy
//
//  Created by nabbit on 12/09/2024.
//

import SwiftUI

extension CanvasView {
    func setSafeAreas(canIgnoreSafeArea: Bool) -> Edge.Set {
        if self.drawing.overideFullSizeCanvas(userPrefs: canIgnoreSafeArea) {
            Edge.Set.all
        } else {
            []
        }
    }
    
    func setDeviceOrientation(orientation: OrientationType) {
        DispatchQueue.main.async {
            switch orientation {
            case .automatic:
                AppDelegate.orientationLock = UIInterfaceOrientationMask.all
            case .portrait:
                AppDelegate.orientationLock = UIInterfaceOrientationMask.portrait
            case .landscape:
                AppDelegate.orientationLock = UIInterfaceOrientationMask.landscape
            }
            UIViewController.attemptRotationToDeviceOrientation()
        }
    }
    
    func resetDeviceOrientation() {
        DispatchQueue.main.async {
            AppDelegate.orientationLock = UIInterfaceOrientationMask.allButUpsideDown
            UIViewController.attemptRotationToDeviceOrientation()
        }
    }
    
    func drawStroke(_ stroke: Stroke, in context: GraphicsContext) {
        switch stroke.tool {
        case .brush:
            self.drawBrush(stroke, in: context)
        case .circle:
            self.drawCircle(stroke, in: context)
        case .diamond:
            self.drawPolygon(stroke, in: context)
        case .eraser:
            self.drawEraser(stroke, in: context)
        case .hexagon:
            self.drawPolygon(stroke, in: context)
        case .line:
            self.drawLine(stroke, in: context)
        case .octagon:
            self.drawPolygon(stroke, in: context)
        case .pentagon:
            self.drawPolygon(stroke, in: context)
        case .star:
            self.drawPolygon(stroke, in: context)
        case .square:
            self.drawPolygon(stroke, in: context)
        case .triangle:
            self.drawPolygon(stroke, in: context)
        }
    }
    
    // Method to draw brush strokes
    func drawBrush(_ stroke: Stroke, in context: GraphicsContext) {
        let path = Path(curving: stroke.points)
        
        var contextCopy = context
        if stroke.blur > 0 {
            contextCopy.addFilter(.blur(radius: stroke.blur))
        }
        contextCopy.stroke(path, with: .color(stroke.color), style: StrokeStyle(lineWidth: stroke.width, lineCap: .round, lineJoin: .round, dash: [1, stroke.spacing * stroke.width])
        )
    }
    
    // Method to draw eraser strokes
    func drawEraser(_ stroke: Stroke, in context: GraphicsContext) {
        let path = Path(curving: stroke.points)
        
        var contextCopy = context
        if stroke.blur > 0 {
            contextCopy.addFilter(.blur(radius: stroke.blur))
        }
        contextCopy.stroke(path, with: .color(self.drawing.backgroundColor), style: StrokeStyle(lineWidth: stroke.width, lineCap: .round, lineJoin: .round, dash: [1, stroke.spacing * stroke.width])
        )
    }
    
    // Method to draw circles
    func drawCircle(_ stroke: Stroke, in context: GraphicsContext) {
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
    func drawLine(_ stroke: Stroke, in context: GraphicsContext) {
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
    
    func drawPolygon(_ stroke: Stroke, in context: GraphicsContext) {
        var path = Path()
        path.addLines(stroke.points)
        
        var contextCopy = context
        if stroke.blur > 0 {
            contextCopy.addFilter(.blur(radius: stroke.blur))
        }
        if stroke.fill {
            contextCopy.fill(path, with: .color(stroke.fillColor))
        }
        contextCopy.stroke(path, with: .color(stroke.color), style: StrokeStyle(lineWidth: stroke.width, lineCap: .round, lineJoin: .round, dash: [1, stroke.spacing * stroke.width])
        )
    }
}
