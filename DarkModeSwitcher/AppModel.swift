//
//  AppModel.swift
//  DarkModeSwitcher
//
//  Created by Kuba Suder on 12.06.2019.
//  Copyright © 2019 Kuba Suder. All rights reserved.
//

import Cocoa
import SwiftUI

class AppModel: ObservableObject, CustomStringConvertible {
    enum ModeSwitchSetting {
        case auto
        case light
    }

    let objectWillChange = Signal()

    let name: String
    let bundleURL: URL
    var icon: NSImage?
    var bundleIdentifier: String?

    var requiresLightMode: Bool = false {
        didSet {
            if requiresLightMode != oldValue {
                needsRestart = isRunning
            }
        }
    }

    var needsRestart: Bool = false {
        willSet {
            objectWillChange.send()
        }
    }

    var isRunning: Bool = false {
        willSet {
            objectWillChange.send()
        }
        didSet {
            if !isRunning {
                needsRestart = false
            }
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

            if newValue != modeSwitchSetting {
                requiresLightMode = (newValue == .light)
                print("Mode for \(bundleIdentifier) = \(requiresLightMode)")

                DispatchQueue.global(qos: .userInitiated).async {
                    Defaults().setRequiresLightMode(newValue == .light, for: bundleIdentifier)
                }
            }
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
