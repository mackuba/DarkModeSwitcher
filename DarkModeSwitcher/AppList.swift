//
//  AppList.swift
//  DarkModeSwitcher
//
//  Created by Kuba Suder on 12.06.2019.
//  Copyright © 2019 Kuba Suder. All rights reserved.
//

import Combine
import Foundation
import SwiftUI

typealias Signal = PassthroughSubject<Void, Never>

class AppList: BindableObject {
    let didChange = Signal()

    var runningAppsObservation: NSKeyValueObservation?

    var apps: [AppModel] = [] {
        didSet {
            didChange.send(())
        }
    }

    func loadApps() {
        DispatchQueue.global(qos: .userInitiated).async {
            let foundApps = AppScanner().findApps()
            let sortedApps = foundApps.sorted(by: { (app1, app2) -> Bool in
                return app1.name.localizedCaseInsensitiveCompare(app2.name) == .orderedAscending
            })

            DispatchQueue.main.async {
                self.apps = sortedApps
                self.startObservingRunningApps()
            }
        }
    }

    func startObservingRunningApps() {
        runningAppsObservation = NSWorkspace.shared.observe(\.runningApplications) { _, _ in
            self.updateRunningApps()
        }

        updateRunningApps()
    }

    func updateRunningApps() {
        let runningApps = NSWorkspace.shared.runningApplications
        let runningIds = Set(runningApps.compactMap({ $0.bundleIdentifier }))

        for app in self.apps {
            if let bundleId = app.bundleIdentifier {
                app.isRunning = runningIds.contains(bundleId)
            }
        }
    }
}
