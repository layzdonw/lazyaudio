//
//  LazyMeetingApp.swift
//  LazyMeeting
//
//  Created by wentx on 2025/1/23.
//

import SwiftUI

@main
struct LazyMeetingApp: App {
    @AppStorage("isDarkMode") private var isDarkMode = false
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    
    var body: some Scene {
        WindowGroup {
            if hasCompletedOnboarding {
                ContentView()
                    .preferredColorScheme(isDarkMode ? .dark : .light)
                    .frame(minWidth: 1080, minHeight: 720)
            } else {
                LandingView()
                    .preferredColorScheme(isDarkMode ? .dark : .light)
                    .frame(width: 800, height: 600)
                    .onDisappear {
                        hasCompletedOnboarding = true
                    }
            }
        }
        .windowStyle(HiddenTitleBarWindowStyle())
        .commands {
            // 添加自定义菜单
            CommandGroup(replacing: .appInfo) {
                Button("关于 LazyMeeting") {
                    NSApplication.shared.orderFrontStandardAboutPanel(
                        options: [
                            NSApplication.AboutPanelOptionKey.applicationName: "LazyMeeting",
                            NSApplication.AboutPanelOptionKey.applicationVersion: "1.0.0",
                            NSApplication.AboutPanelOptionKey.credits: NSAttributedString(
                                string: "智能会议转录与分析工具",
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
                
                Button("检查更新...") {
                    // 检查更新逻辑
                }
                
                Divider()
                
                Button(isDarkMode ? "切换到浅色模式" : "切换到深色模式") {
                    isDarkMode.toggle()
                }
                .keyboardShortcut("d", modifiers: [.command, .option])
            }
            
            CommandMenu("录制") {
                Button("新建录制会话") {
                    // 新建录制会话逻辑
                }
                .keyboardShortcut("n", modifiers: .command)
                
                Button("开始录制") {
                    // 开始录制逻辑
                }
                .keyboardShortcut("r", modifiers: .command)
                
                Button("停止录制") {
                    // 停止录制逻辑
                }
                .keyboardShortcut("s", modifiers: .command)
            }
        }
    }
}
