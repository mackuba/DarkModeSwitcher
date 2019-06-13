//
//  AppModel.swift
//  DarkModeSwitcher
//
//  Created by Kuba Suder on 12.06.2019.
//  Copyright © 2019 Kuba Suder. All rights reserved.
//

import Cocoa
import SwiftUI

class AppModel: BindableObject, CustomStringConvertible {
    enum ModeSwitchSetting {
        case auto
        case light
    }

    let didChange = Signal()

    let name: String
    let bundleURL: URL
    var icon: NSImage?
    var bundleIdentifier: String?

    var requiresLightMode: Bool = false

    var needsRestart: Bool = false {
        didSet {
            didChange.send(())
        }
    }

    var isRunning: Bool = false {
        didSet {
            if !isRunning {
                needsRestart = false
            }

            didChange.send(())
        }
    }

    var modeSwitchSetting: ModeSwitchSetting {
        get {
            requiresLightMode ? .light : .auto
        }

        set {
            guard let bundleIdentifier = bundleIdentifier else {
                fatalError("No bundleIdentifier set")
            }

            requiresLightMode = (newValue == .light)
            needsRestart = isRunning
            print("Mode for \(bundleIdentifier) = \(requiresLightMode)")
            Defaults().setRequiresLightMode(requiresLightMode, for: bundleIdentifier)
        }
    }

    init(bundleURL: URL) {
        self.name = bundleURL.deletingPathExtension().lastPathComponent
        self.bundleURL = bundleURL
    }

    var description: String {
        return "AppModel(name: \(name), bundleURL: \(bundleURL), identifier: \(bundleIdentifier ?? "?"), " +
            "requiresLightMode: \(requiresLightMode), icon: \(icon == nil ? "not loaded" : "loaded"))"
    }
}
