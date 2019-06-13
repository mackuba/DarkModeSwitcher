//
//  AppRowView.swift
//  DarkModeSwitcher
//
//  Created by Kuba Suder on 13.06.2019.
//  Copyright © 2019 Kuba Suder. All rights reserved.
//

import SwiftUI

private let iconSize: CGFloat = 32

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

            SegmentedControl(selection: $app.modeSwitchSetting) {
                Text("Auto").tag(AppModel.ModeSwitchSetting.auto)
                Text("Light").tag(AppModel.ModeSwitchSetting.light)
            }
            .frame(width: 200)
        }
    }
}

#if DEBUG
struct AppRowView_Previews: PreviewProvider {
    static var previews: some View {
        let app = AppModel(
            bundleURL: URL(string: "/Applications/Firefox.app")!
        )
        app.icon = NSImage(named: "firefox")

        return AppRowView(app: app)
            .previewLayout(.fixed(width: 300, height: 50))
    }
}
#endif
