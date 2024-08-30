//
//  View.swift
//  Sketchy
//
//  Created by nabbit on 30/08/2024.
//

import SwiftUI

// A View extension to make the modifier easier to use.
extension View {
    func onShake(perform action: @escaping () -> Void) -> some View {
        self.modifier(DeviceShakeViewModifier(action: action))
    }
    
    func displayConfetti(isActive: Binding<Bool>) -> some View {
        self.modifier(DisplayConfettiModifier(isActive: isActive))
    }
}
