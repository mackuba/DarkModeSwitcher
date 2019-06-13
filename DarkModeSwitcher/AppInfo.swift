//
//  AppInfo.swift
//  DarkModeSwitcher
//
//  Created by Kuba Suder on 12.06.2019.
//  Copyright © 2019 Kuba Suder. All rights reserved.
//

import Foundation

struct AppInfo: Codable {
    let iconFileName: String?
    let bundleIdentifier: String

    enum CodingKeys: String, CodingKey {
        case iconFileName = "CFBundleIconFile"
        case bundleIdentifier = "CFBundleIdentifier"
    }
}
