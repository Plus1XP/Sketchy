//
//  WelcomeModel.swift
//  Sketchy
//
//  Created by nabbit on 05/09/2024.
//

import Foundation

struct WelcomeModel: Decodable, Identifiable {
    var id = UUID()
    let title: String
    let description: String
    let image: String
}
