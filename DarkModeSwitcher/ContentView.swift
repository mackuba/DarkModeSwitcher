//
//  ContentView.swift
//  DarkModeSwitcher
//
//  Created by Kuba Suder on 12.06.2019.
//  Copyright © 2019 Kuba Suder. All rights reserved.
//

import SwiftUI

private let iconSize: CGFloat = 32

struct ContentView: View {
    @ObservedObject var appList: AppList
    @State var query: String = ""

    var matchingApps: [AppModel] {
        if query.isEmpty {
            return appList.apps
        } else {
            return appList.apps.filter({
                $0.name.lowercased().contains(query.lowercased())
            })
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            SearchBar(query: $query)

            Divider()

            List(matchingApps, id: \.bundleURL) { app in
                AppRowView(app: app)
            }
        }
        .frame(minWidth: 450, minHeight: 300)
    }
}

struct SearchBar: View {
    @Binding var query: String

    var clearIcon: NSImage {
        NSImage(named: "NSStopProgressFreestandingTemplate")!
    }

    var body: some View {
        HStack(spacing: 0) {
            Spacer()

            Text("🔍")

            TextField("Search", text: $query)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(8)

            Button(action: clearQuery) {
                Image(nsImage: clearIcon)
                    .opacity(query.count == 0 ? 0.5 : 1.0)
            }
            .disabled(query.count == 0)
            .padding(.trailing, 8)
        }
        .onExitCommand(perform: clearQuery)
    }

    func clearQuery() {
        self.query = ""
    }
}

struct MissingAppIcon: View {
    var body: some View {
        Circle()
            .fill(Color.gray)
            .padding(.all, 2)
            .frame(width: iconSize, height: iconSize)
            .opacity(0.5)
            .overlay(Text("?").foregroundColor(.white).opacity(0.8))
    }
}

struct AppRowView: View {
    @ObservedObject var app: AppModel

    var body: some View {
        HStack {
            if app.icon != nil {
                Image(nsImage: app.icon!)
                    .resizable()
                    .frame(width: iconSize, height: iconSize)
            } else {
                MissingAppIcon()
            }

            Text(app.name)

            Spacer()

            if app.needsRestart {
                Image(nsImage: NSImage(named: "NSCaution")!)
                    .resizable()
                    .frame(width: 28, height: 28)
                    .padding(.trailing, 5)
                    .accessibility(
                        label: Text("App requires restart")
                    )
            }

            Picker("", selection: $app.modeSwitchSetting) {
                Text("Auto").tag(AppModel.ModeSwitchSetting.auto)
                Text("Light").tag(AppModel.ModeSwitchSetting.light)
            }
            .pickerStyle(SegmentedPickerStyle())
            .disabled(app.bundleIdentifier == nil)
            .frame(width: 200)
        }
    }
}

struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        let names = ["App Store", "Music", "Numbers", "Photos", "Safari"]
        let appList = AppList()
        appList.apps = names.map {
            let app = AppModel(
                bundleURL: URL(fileURLWithPath: "/System/Applications/\($0).app")
            )
            app.bundleIdentifier = "app.\($0)"
            app.icon = NSImage(
                contentsOf: app.bundleURL
                    .appendingPathComponent("Contents")
                    .appendingPathComponent("Resources")
                    .appendingPathComponent("AppIcon.icns")
            )
            app.needsRestart = (app.name == "Slack")
            return app
        }

        return Group {
            AppRowView(app: appList.apps[0])
                .previewLayout(.fixed(width: 500, height: 50))
                .padding(.all, 5)

            ContentView(appList: appList)
        }
    }
}
