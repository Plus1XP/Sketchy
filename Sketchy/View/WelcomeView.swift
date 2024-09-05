//
//  WelcomeView.swift
//  Sketchy
//
//  Created by nabbit on 05/09/2024.
//

import SwiftUI

struct WelcomeView: View {
    @Environment(\.presentationMode) var presentationMode
    @AppStorage("canShowOnBoarding") var canShowOnBoarding: Bool = true
    @AppStorage("canIgnoreSafeArea") var canIgnoreSafeArea: Bool = true
    @AppStorage("isCanvasHapticsEnabled") var isCanvasHapticsEnabled: Bool = true

    let appName = "Sketchy"
    let welcomeModel = [
        WelcomeModel(title: "Undo Histroy", description: "Undo and Redo lasts for the entire session, when you exit it'll forget. Undo history will keep track of changes from the last session", image: "custom.arrow.uturn.backward.badge.clock"),
        WelcomeModel(title: "One last thing", description: "If you get stuck and need some help, or you want to change some settings. Just give give the device a little shake!", image: "phone.shake")
    ]
    
    var body: some View {
        VStack(spacing: 20) {
            ScrollView {
                VStack(spacing: 20) {
                    AppIcon()
                        .cornerRadius(10)
                        .accessibilityHidden(true)
                    
                    Text("Welcome to\n\(Text(appName).foregroundColor(.accentColor))")
                        .multilineTextAlignment(.center)
                        .font(.largeTitle.bold())
                    
                    HStack {
                        Image(systemName: "pencil.and.ruler")
                            .frame(width: 44)
                            .font(.title)
                            .foregroundColor(.accentColor)
                            .accessibilityHidden(true)
                        VStack(alignment: .leading) {
                            Text("Exceed Safe Area")
                                .font(.headline)
                            Text("Would you like to use the entire screen as the canvas?")
                                .foregroundColor(.secondary)
                        }
                        .accessibilityElement(children: .combine)
                        Spacer()
                        Toggle("Exceed Safe Area", isOn: $canIgnoreSafeArea)
                            .labelsHidden()
                            .toggleStyle(.switch)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.trailing)
                    
                    HStack {
                        Image("custom.hand.draw.trianglebadge.exclamationmark")
                            .frame(width: 44)
                            .font(.title)
                            .foregroundStyle(.yellow, Color.accentColor)
                            .accessibilityHidden(true)
                        VStack(alignment: .leading) {
                            Text("Canvas Haptics")
                                .font(.headline)
                            Text("would you like to Simulates the feeling of moving your finger across a surface?")
                                .foregroundColor(.secondary)
                        }
                        .accessibilityElement(children: .combine)
                        Spacer()
                        Toggle("Canvas Haptics", isOn: $isCanvasHapticsEnabled)
                            .labelsHidden()
                            .toggleStyle(.switch)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.trailing)

                    
                    ForEach(welcomeModel) { feature in
                        HStack {
                            // Image will replace symbol if available
                            ZStack {
                                Image(systemName: feature.image)
                                    .frame(width: 44)
                                    .font(.title)
                                    .foregroundColor(.accentColor)
                                    .accessibilityHidden(true)
                                
                                Image(feature.image)
                                    .resizable()
                                    .frame(width: 44, height: 44)
                                    .font(.title)
                                    .foregroundColor(.accentColor)
                                    .accessibilityHidden(true)
                            }
                            
                            VStack(alignment: .leading) {
                                Text(feature.title)
                                    .font(.headline)
                                
                                Text(feature.description)
                                    .foregroundColor(.secondary)
                            }
                            .accessibilityElement(children: .combine)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
            
            Text("Subscription and Ad free.")
                .font(.footnote)
                .foregroundColor(.secondary)
            
            Button("Continue", action: {
                canShowOnBoarding = false
                close()
            })
            .frame(maxWidth: .infinity, minHeight: 44)
            .background(Color.accentColor)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .padding()
    }
    
    func close() {
        presentationMode.wrappedValue.dismiss()
    }
}

#Preview {
    WelcomeView()
        .preferredColorScheme(.light)
}

#Preview {
    WelcomeView()
        .preferredColorScheme(.dark)
}
