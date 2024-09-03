//
//  MinusButtonComponent.swift
//  Sketchy
//
//  Created by nabbit on 03/09/2024.
//

import SwiftUI

struct MinusButtonComponent: View {
    @State private var minusAnimation: Bool = false
    @Binding var count: Double
    var minimumCount: Double
    
    var body: some View {
        Button(action: {
            if count > minimumCount {
                count -= 1
                self.minusAnimation.toggle()
            }
        }) {
            Image(systemName: "minus.circle.fill")
                .symbolEffect(.bounce, options: .speed(2), value: self.minusAnimation)
                .font(.callout)
        }
//        .padding()
        .foregroundStyle(.white, count <= minimumCount ? .gray : .blue)
        .buttonRepeatBehavior(.enabled)
        .sensoryFeedback(.decrease, trigger: minusAnimation)
        .disabled(count <= minimumCount)
    }
}

#Preview {
    MinusButtonComponent(count: .constant(5), minimumCount: 0)
}

