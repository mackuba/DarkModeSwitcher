//
//  ContentView.swift
//  DarkModeSwitcher
//
//  Created by Kuba Suder on 12.06.2019.
//  Copyright © 2019 Kuba Suder. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @ObjectBinding var appList: AppList

    var body: some View {
        List(appList.apps.identified(by: \.bundleURL)) { app in
            AppRowView(app: app)
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
            app.icon = NSImage(named: app.name.lowercased())
            return app
        }

        return ContentView(appList: appList)
    }
}
#endif
