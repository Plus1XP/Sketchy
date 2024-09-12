//
//  SettingsView.swift
//  Sketchy
//
//  Created by nabbit on 30/08/2024.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var drawing: Drawing
    @EnvironmentObject var userConfig: UserConfiguration
    @State var showConfetti: Bool = false
    @State var canShowOrientationInfo: Bool = false
    @State var canShowSafeAreaInfo: Bool = false
    @State var canShowCanvasHapticsInfo: Bool = false
    @State var canShowLockCanvasInfo: Bool = false
    // Fill in App ID when app is added to appstore connect!
    private let appName: String = "Sketchy App"
    private let appID: String = "6670319622"
    private let mailURL: String = "mailto:evlbrains@protonmail.ch"
    private let supportURL: String = "https://plus1xp.github.io/Sketchy/"
    private let githubURL: String = "https://github.com/Plus1XP"
    private let appURL: String = "https://apps.apple.com/us/app/id"
    private let reviewForwarder: String = "?action=write-review"
    private let versionString: String = {
            let version: String = (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String) ?? "_error"
            let build: String = (Bundle.main.infoDictionary?["CFBundleVersion"] as? String) ?? "_error"
            return version + " (" + build + ")"
    }()
    
    var body: some View {
        Form {
            HStack {
                Image(systemName: "questionmark.circle")
                    .foregroundStyle(.blue)
                    .font(.title)
                Text("Help")
                    .foregroundColor(.primary)
                    .font(.title)
                    .fontWeight(.bold)
                Spacer()
                Button {
                    self.dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.gray, self.colorScheme == .light ? Color(UIColor.tertiarySystemFill) : Color(UIColor.tertiarySystemBackground))
                        .font(.title)
                }
            }
            // Removes white form section backgroung
            .listRowBackground(Color.clear)
            
            Section(header: Text("\(Image(systemName: "gearshape")) Settings"), footer: Text("\(Image(systemName: "exclamationmark.circle")) Any changes to canvas orientation & fullscreen canvas will take effect on new sketches only.\nThis can be bypassed using the override buttons.")) {
                Group {
                    HStack {
                        Image(systemName: self.userConfig.appearanceType.symbolChoice)
                            .foregroundStyle(self.userConfig.appearanceType.primarySymbolColor, self.userConfig.appearanceType.secondarySymbolColor)
                        Picker(selection: $userConfig.appearanceType, label: Text("System Appearence")) {
                            Text("Auto").tag(AppearanceType.automatic)
                            Text("Light").tag(AppearanceType.light)
                            Text("Dark").tag(AppearanceType.dark)
                        }
                    }
                    HStack {
                        Image(systemName: "photo.artframe")
                            .foregroundStyle(self.colorScheme == .light ? .black : .white , .cyan)
                        ColorPicker("Canvas Color", selection: $drawing.backgroundColor, supportsOpacity: true)
                    }
                    HStack {
                        Image(systemName: self.userConfig.orientationType.symbolChoice)
                            .foregroundStyle(self.userConfig.orientationType.primarySymbolColor, self.userConfig.orientationType.secondarySymbolColor)
                        Picker(selection: $userConfig.orientationType, label: Text("Canvas Orientation")) {
                            Text("Auto").tag(OrientationType.automatic)
                            Text("Portrait").tag(OrientationType.portrait)
                            Text("Landscape").tag(OrientationType.landscape)
                        }
                        .onChange(of: self.userConfig.orientationType, {
                            if self.drawing.isOldStrokesEmpty() {
                                self.drawing.setOrientation(orientation: self.userConfig.orientationType)
                            }
                        })
                    }
                    HStack {
                        Image(systemName: "pencil.and.ruler")
                            .foregroundStyle(.brown)
                        Text("Fullscreen Canvas")
                        Button(action: {
                            self.canShowSafeAreaInfo.toggle()
                        }, label: {
                            Image(systemName: "info.circle")
                        })
                        .popover(isPresented:  $canShowSafeAreaInfo) {
                            Text("Uses the fullscreen as the canvas, including painting over the toolbar.")
                                .font(.footnote)
                                .padding()
                                .presentationCompactAdaptation(.popover)
                        }
                        Spacer()
                        Toggle("Exceed Safe Area", isOn: $userConfig.canIgnoreSafeArea)
                            .labelsHidden()
                            .onChange(of: self.userConfig.canIgnoreSafeArea, {
                                if self.drawing.isOldStrokesEmpty() {
                                    self.drawing.setSafeArea(canIgnoreSafeArea: self.userConfig.canIgnoreSafeArea)
                                }
                            })
                    }
                    HStack {
                        VStack {
                            HStack {
                                Image("custom.hand.draw.trianglebadge.exclamationmark")
                                    .foregroundStyle(.yellow, .primary)
                                Text("Canvas Vibrations")
                                Button(action: {
                                    self.canShowCanvasHapticsInfo.toggle()
                                }, label: {
                                    Image(systemName: "info.circle")
                                })
                                .popover(isPresented:  $canShowCanvasHapticsInfo) {
                                    Text("Uses the haptic engine to simulate the feeling of moving your finger across a surface.")
                                        .font(.footnote)
                                        .padding()
                                        .presentationCompactAdaptation(.popover)
                                }
                                Spacer()
                                Toggle("Canvas Haptics", isOn: $userConfig.isCanvasHapticsEnabled)
                                    .labelsHidden()
                            }
                            if self.userConfig.isCanvasHapticsEnabled {
                                HStack {
                                    Text("Intensity: ") +
                                    Text(String(format: "%.2f", self.userConfig.canvasHapticsIntensity))
                                        .fontWeight(.medium)
                                    Slider(value: $userConfig.canvasHapticsIntensity, in: 0.28...0.8)
                                }
                            }
                        }
                    }
                    HStack {
                        Text("Override:")
                        Toggle("Fullscreen", isOn: $drawing.safeAreaOverride)
                            .toggleStyle(.button)
                        Toggle("Orientation", isOn: $drawing.orientationOverride)
                            .toggleStyle(.button)
                    }
                }
            }
            Section(header: Text("\(Image(systemName: "message")) FeedBack")) {
                Group {
                    HStack {
                        Link(destination: URL(string: self.mailURL)!) {
                            HStack {
                                Image(systemName: "envelope")
                                    .foregroundStyle(.blue)
                                Text("Get in Touch")
                                    .foregroundColor(.primary)
                            }
                        }
                    }
                    HStack {
                        Link(destination: URL(string: self.supportURL)!) {
                            HStack {
                                Image(systemName: "safari")
                                    .foregroundStyle(.red, .blue)
                                    .font(.title2)
                                Text("Discover More")
                                    .foregroundColor(.primary)
                            }
                        }
                    }
                    HStack {
                        ShareLink(
                            item: URL(string: self.appURL + self.appID)!,
                            preview: SharePreview( self.appName,
                                                   image: Image(uiImage: UIImage(named: "AppIcon60x60") ?? UIImage())
                                                 )
                        ) {
                            HStack {
                                Image(systemName: "square.and.arrow.up")
                                    .foregroundStyle(.blue)
                                    .font(.title2)
                                Text("Share with Friends")
                                    .foregroundColor(.primary)
                            }
                        }
                    }
                    HStack {
                        Link(destination: URL(string: self.appURL + self.appID + self.reviewForwarder)!) {
                            HStack {
                                Image(systemName: "star.fill")
                                    .foregroundStyle(.yellow)
                                    .font(.title3)
                                Text("Rate and Review")
                                    .foregroundColor(.primary)
                            }
                        }
                    }
                }
            }
//            Section(header: Text("\(Image(systemName: "info.circle")) About"), footer: HStack{
//                Spacer()
//                Text("For Ruby \(Image(systemName: "heart"))")
//                Spacer()}) {
            Section(header: Text("\(Image(systemName: "info.circle")) About")) {
                Group {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundStyle(.black, .yellow)
                        Text("Version \(self.versionString)")
                    }
                    HStack {
                        Link(destination: URL(string: self.githubURL)!) {
                            HStack {
                                Image(systemName: "paintbrush.fill")
                                    .foregroundStyle(.green)
                                Text("Designed by Plus1XP")
                                    .foregroundColor(.primary)
                            }
                        }
                    }
                    HStack {
                        Link(destination: URL(string: self.githubURL)!) {
                            HStack {
                                Image(systemName: "hammer.fill")
                                    .foregroundStyle(.gray)
                                Text("Developed by Plus1XP")
                                    .foregroundColor(.primary)
                            }
                        }
                    }
                    HStack {
                        Image(systemName: "c.circle")
                            .foregroundStyle(.primary)
                        Text("Copyright 2023 Plus1XP")
                    }
                }
            }
            if checkTodayIsSpecialDay(day: 22, month: 3) {
                HStack {
                    Spacer()
                    Button("🎁", action: {
                        self.showConfetti = true
                    })
                    .buttonStyle(GrowingIconButtonStyle())
                    Spacer()
                }
                // Needed to fix bug of section acting as a big button.
                .buttonStyle(BorderlessButtonStyle())
                // Removes white form section backgroung
                .listRowBackground(Color.clear)
            }
            HStack {
                Spacer()
                Text("For Ruby \(Image(systemName: "heart"))")
                    .foregroundColor(.secondary)
                    .font(.caption)
                Spacer()
            }
            // Removes white form section backgroung
            .listRowBackground(Color.clear)
        }
        .presentationDragIndicator(.visible)
        .displayConfetti(isActive: $showConfetti)
    }
}

#Preview {
    SettingsView()
        .environmentObject(Drawing())
        .environmentObject(UserConfiguration())
        .preferredColorScheme(.light)
}

#Preview {
    SettingsView()
        .environmentObject(Drawing())
        .environmentObject(UserConfiguration())
        .preferredColorScheme(.dark)
}
