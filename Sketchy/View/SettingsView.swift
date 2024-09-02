//
//  SettingsView.swift
//  Sketchy
//
//  Created by nabbit on 30/08/2024.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.colorScheme) private var colorScheme
    @State var showConfetti: Bool = false
    @State var canShowSafeAreaInfo: Bool = false
    @AppStorage("canIgnoreSafeArea") var canIgnoreSafeArea: Bool = true
    @AppStorage("appearance") var appearance: AppearanceType = .automatic
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
            }
            // Removes white form section backgroung
            .listRowBackground(Color.clear)
            
            Section(header: Text("\(Image(systemName: "slider.horizontal.3")) Preferences")) {
                Group {
                    HStack {
                        Image(systemName: "pencil.and.ruler")
                            .foregroundStyle(.brown)
                        Text("Exceed Safe Area")
                        Button(action: {
                            self.canShowSafeAreaInfo.toggle()
                        }, label: {
                            Image(systemName: "info.circle")
                        })
                        .popover(isPresented:  $canShowSafeAreaInfo) {
                            Text("Uses the entire screen as the canvas.")
                                .font(.footnote)
                                .padding()
                                .presentationCompactAdaptation(.popover)
                        }
                        Spacer()
                        Toggle("Exceed Safe Area", isOn: $canIgnoreSafeArea)
                            .labelsHidden()
                    }
                    HStack {
                        Image(systemName: appearance.symbolChoice)
                            .foregroundStyle(appearance.primarySymbolColor, appearance.secondarySymbolColor)
                        Picker(selection: $appearance, label: Text("System Appearence")) {
                            Text("Auto").tag(AppearanceType.automatic)
                            Text("Light").tag(AppearanceType.light)
                            Text("Dark").tag(AppearanceType.dark)
                        }
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
            if checkTodayIsSpecialDay(day: 16, month: 4) {
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
        }
        .presentationDragIndicator(.visible)
        .displayConfetti(isActive: $showConfetti)
    }
}

#Preview {
    SettingsView()
}
