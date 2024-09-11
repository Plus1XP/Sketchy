//
//  SegmentView.swift
//  Sketchy
//
//  Created by nabbit on 11/09/2024.
//

import SwiftUI

struct SegmentView: View {
    let values: ClosedRange<Int>
    let steps: Int
    let segmentWidth: CGFloat
    let style: SegmentStyle
    
    var body: some View {
        ForEach(values, id: \.self) { index in
            let isPrimary = (index % steps == .zero)
            let middleSteps = Double(steps) / 2
            let isMiddle = (Double(index) - middleSteps).truncatingRemainder(dividingBy: Double(steps)) == .zero
            Rectangle()
                .frame(
                width: segmentWidth,
                height: isPrimary ? 30.0 : (isMiddle ? 18.0 : 8.0)
                )
                .frame(maxHeight: 20.0, alignment: .bottom)
                .foregroundStyle(isPrimary || isMiddle ? .yellow: .gray)
                .overlay {
                    if isPrimary {
                        Text("\(style == .styleOne ? index :(index / steps))")
                            .font(.system(size: 14, design: .monospaced))
                            .fixedSize()
                            .offset(y: 20)
                    }
                }
            }
    }
}
