//
//  UIDevice.swift
//  Sketchy
//
//  Created by nabbit on 30/08/2024.
//

import SwiftUI

// The notification we'll send when a shake gesture happens.
extension UIDevice {
    static let deviceDidShakeNotification = Notification.Name(rawValue: "deviceDidShakeNotification")
}
