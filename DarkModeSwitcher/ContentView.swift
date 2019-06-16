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
    @ObjectBinding var appList: AppList
    @State var query: String = ""

    var body: some View {
        let matchingApps = query.isEmpty ?
            appList.apps :
            appList.apps.filter({
                $0.name.lowercased().contains(query.lowercased())
            })

        return VStack(spacing: 0) {
            SearchBar(query: $query)

            Divider()

            List(matchingApps.identified(by: \.bundleURL)) { app in
                AppRowView(app: app)
            }
        }
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

            TextField($query, placeholder: Text("Search"))
                .textFieldStyle(.roundedBorder)
                .padding(8)

            Button(action: clearQuery) {
                Image(nsImage: clearIcon)
                    .opacity(query.count == 0 ? 0.5 : 1.0)
            }
            .disabled(query.count == 0)
            .padding(.trailing, 8)
        }
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
            .overlay(Text("?").color(.white).opacity(0.8))
    }
}

struct AppRowView: View {
    @ObjectBinding var app: AppModel

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

            SegmentedControl(selection: $app.modeSwitchSetting) {
                Text("Auto").tag(AppModel.ModeSwitchSetting.auto)
                Text("Light").tag(AppModel.ModeSwitchSetting.light)
            }
            .disabled(app.bundleIdentifier == nil)
            .frame(width: 200)
        }
    }
}

#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        let names = ["Firefox", "Pages", "Slack", "Twitter"]
        let appList = AppList()
        appList.apps = names.map {
            let app = AppModel(
                bundleURL: URL(string: "/Applications/\($0).app")!
            )
            app.bundleIdentifier = "app.\($0)"
            app.icon = NSImage(named: app.name.lowercased())
            app.needsRestart = (app.name == "Slack")
            return app
        }

        return ContentView(appList: appList)
    }
}
#endif
