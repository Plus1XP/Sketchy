//
//  CustomSlider.swift
//  Sketchy
//
//  Created by nabbit on 11/09/2024.
//

import SwiftUI

public enum SegmentStyle {
    case styleOne
    case styleTwo
}

struct CustomSlider: View {
    @State var isScrolling: Bool = false
    @Binding var count: Int
    var segmentWidth: CGFloat = 1.0
    var values: ClosedRange<Int>
    var spacing: Double
    var steps: Int
    var style: SegmentStyle
    
    init(count: Binding<Int>, from: Int, to: Int, spacing: Double = 8.0, steps: Int, style: SegmentStyle) {
        _count = count
        self.values = from...(style == .styleTwo ? (to * steps) : to)
        self.spacing = spacing
        self.steps = steps
        self.style = style
    }
    
    var body: some View {
        ZStack {
            GeometryReader { geo in
                ScrollViewReader { proxy in
                    ScrollView(.horizontal) {
                        ZStack {
                            ScrollViewOffsetReader {
                                isScrolling = true
                            } onScrollingFinished: {
                                isScrolling = false
                            }
                            HStack(spacing: spacing) {
                                SegmentView(values: values, steps: steps, segmentWidth: segmentWidth, style: style)
                            }
                            .frame(height: geo.size.height)
                            .scrollTargetLayout()
                        }
                    }
                    .overlay {
                        Rectangle().foregroundStyle(.red)
                            .frame(width: 3, height: 20)
//                            .padding(.bottom, 20)
                    }
                    .scrollIndicators(.hidden)
                    .safeAreaPadding(.horizontal, geo.size.width / 2.0)
                    .scrollTargetBehavior(.viewAligned)
                    .scrollPosition(
                        id: .init(get: {
                            return count
                        }, set: {
                            value, transition in
                            if let value {
                                count = value
                            }
                        })
                    )
                    .onChange(of: isScrolling, { oldValue, newValue in
                        if newValue == false && style == .styleTwo {
                            let indexValue: Double = Double(count) / Double(steps)
                            let nextItem = indexValue.rounded()
                            let newIndex = nextItem * Double(steps)
                            withAnimation {
                                if count != Int(newIndex) {
                                    count = Int(newIndex)
                                }
                            }
                        }
                        
                    })
                }
            }
        }
        .frame(height: 20)
    }
}

#Preview {
    CustomSlider(count: .constant(50), from: 0, to: 100, steps: 10, style: .styleOne)
}
