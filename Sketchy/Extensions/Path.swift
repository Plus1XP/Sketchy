//
//  Path.swift
//  Sketchy
//
//  Created by nabbit on 30/08/2024.
//

import SwiftUI

extension Path {
    init(curving points: [CGPoint]) {
        self = Path { path in
            guard let firstPoint = points.first else { return }

            path.move(to: firstPoint)
            var previous = firstPoint

            for point in points.dropFirst() {
                let middle = CGPoint(x: (point.x + previous.x) / 2, y: (point.y + previous.y) / 2)
                path.addQuadCurve(to: middle, control: previous)
                previous = point
            }

            path.addLine(to: previous)
        }
    }
}
