//
//  WelcomeViewComponents.swift
//  Sketchy
//
//  Created by nabbit on 05/09/2024.
//

import SwiftUI

struct AppIcon: View {
    var body: some View {
        Bundle.main.iconFileName
            .flatMap { UIImage(named: $0) }
            .map { Image(uiImage: $0) }
    }
}

#Preview {
    AppIcon()
}
