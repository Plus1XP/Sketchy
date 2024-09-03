//
//  PlusButtonComponent.swift
//  Sketchy
//
//  Created by nabbit on 03/09/2024.
//

import SwiftUI

struct PlusButtonComponent: View {
    @State private var plusAnimation: Bool = false
    @Binding var count: Double
    var maximumCount: Double
    
    var body: some View {
        Button(action: {
            if count < maximumCount {
                count += 1
                self.plusAnimation.toggle()
            }
        }) {
            Image(systemName: "plus.circle.fill")
                .symbolEffect(.bounce, options: .speed(2), value: self.plusAnimation)
                .font(.callout)
        }
//        .padding()
        .foregroundStyle(.white, count >= maximumCount ? .gray : .blue)
        .buttonRepeatBehavior(.enabled)
        .sensoryFeedback(.increase, trigger: plusAnimation)
        .disabled(count >= maximumCount)
    }
}

#Preview {
    PlusButtonComponent(count: .constant(5), maximumCount: 20)
}
