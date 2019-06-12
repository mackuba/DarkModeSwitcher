//
//  AppModel.swift
//  DarkModeSwitcher
//
//  Created by Kuba Suder on 12.06.2019.
//  Copyright © 2019 Kuba Suder. All rights reserved.
//

import Cocoa

class AppModel: CustomStringConvertible {
    let name: String
    let bundleURL: URL
    var icon: NSImage?
    var bundleIdentifier: String?
    var requiresLightMode: Bool = false

    init(bundleURL: URL) {
        self.name = bundleURL.deletingPathExtension().lastPathComponent
        self.bundleURL = bundleURL
    }

    var description: String {
        return "AppModel(name: \(name), bundleURL: \(bundleURL), identifier: \(bundleIdentifier ?? "?"), " +
            "requiresLightMode: \(requiresLightMode), icon: \(icon == nil ? "not loaded" : "loaded"))"
    }
}
