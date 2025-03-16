//
//  LazyAudioApp.swift
//  LazyAudio
//
//  Created by wentx on 2025/1/23.
//

import SwiftUI

@main
struct LazyAudioApp: App {
    @AppStorage("isDarkMode") private var isDarkMode = false
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @StateObject private var localizationManager = LocalizationManager.shared
    
    var body: some Scene {
        WindowGroup {
            if hasCompletedOnboarding {
                ContentView()
                    .preferredColorScheme(isDarkMode ? .dark : .light)
                    .frame(minWidth: 1080, minHeight: 720)
                    .environmentObject(localizationManager)
            } else {
                LandingView()
                    .preferredColorScheme(isDarkMode ? .dark : .light)
                    .frame(width: 800, height: 600)
                    .environmentObject(localizationManager)
                    .onDisappear {
                        hasCompletedOnboarding = true
                    }
            }
        }
        .windowStyle(HiddenTitleBarWindowStyle())
        .commands {
            // 添加自定义菜单
            CommandGroup(replacing: .appInfo) {
                Button("app.about".localized) {
                    NSApplication.shared.orderFrontStandardAboutPanel(
                        options: [
                            NSApplication.AboutPanelOptionKey.applicationName: "app.name".localized,
                            NSApplication.AboutPanelOptionKey.applicationVersion: "1.0.0",
                            NSApplication.AboutPanelOptionKey.credits: NSAttributedString(
                                string: "app.description".localized,
                                attributes: [
                                    NSAttributedString.Key.font: NSFont.systemFont(ofSize: 11),
                                    NSAttributedString.Key.foregroundColor: NSColor.secondaryLabelColor
                                ]
                            )
                        ]
                    )
                }
            }
            
            CommandGroup(after: .appInfo) {
                Divider()
                
                Button("app.check_updates".localized) {
                    // 检查更新逻辑
                }
                
                Divider()
                
                Button(isDarkMode ? "app.switch_light".localized : "app.switch_dark".localized) {
                    isDarkMode.toggle()
                }
                .keyboardShortcut("d", modifiers: [.command, .option])
                
                Menu("app.language".localized) {
                    ForEach(localizationManager.supportedLanguages, id: \.id) { language in
                        Button(language.displayName) {
                            localizationManager.switchLanguage(to: language)
                        }
                        .disabled(localizationManager.currentLanguage == language)
                    }
                }
            }
            
            CommandMenu("recording.menu".localized) {
                Button("recording.new_session".localized) {
                    // 新建录制会话逻辑
                }
                .keyboardShortcut("n", modifiers: .command)
                
                Button("recording.start".localized) {
                    // 开始录制逻辑
                }
                .keyboardShortcut("r", modifiers: .command)
                
                Button("recording.stop".localized) {
                    // 停止录制逻辑
                }
                .keyboardShortcut("s", modifiers: .command)
            }
        }
    }
} 