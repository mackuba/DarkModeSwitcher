//
//  AppScanner.swift
//  DarkModeSwitcher
//
//  Created by Kuba Suder on 12.06.2019.
//  Copyright © 2019 Kuba Suder. All rights reserved.
//

import Cocoa
import Foundation

class AppScanner {

    var applicationFolders: [URL] {
        return FileManager.default.urls(for: .applicationDirectory, in: .allDomainsMask)
    }

    func findApps() -> [AppModel] {
        var foundApps: [AppModel] = []
        let manager = FileManager.default

        for folder in applicationFolders {
            do {
                var isDirectory: ObjCBool = false
                let exists = manager.fileExists(atPath: folder.path, isDirectory: &isDirectory)

                guard exists && isDirectory.boolValue else {
                    print("Skipping \(folder)")
                    continue
                }

                // TODO: scan subdirectories
                let urls = try manager.contentsOfDirectory(
                    at: folder,
                    includingPropertiesForKeys: [],
                    options: [.skipsHiddenFiles]
                )

                for url in urls {
                    guard url.pathExtension == "app" else { continue }

                    let app = AppModel(bundleURL: url)
                    foundApps.append(app)

                    DispatchQueue.global(qos: .userInitiated).async {
                        self.processApp(app: app)
                    }
                }
            } catch {
                NSLog("Error: couldn't scan applications in %@", "\(folder)")
            }
        }

        return foundApps
    }

    func processApp(app: AppModel) {
        let plist = app.bundleURL.appendingPathComponent("Contents").appendingPathComponent("Info.plist")

        do {
            let contents = try Data(contentsOf: plist)
            let info = try PropertyListDecoder().decode(AppInfo.self, from: contents)
            let defaultsSetting = Defaults().checkRequiresLightMode(for: info.bundleIdentifier)

            DispatchQueue.main.async {
                app.objectWillChange.send()
                app.bundleIdentifier = info.bundleIdentifier

                if let iconFileName = info.iconFileName {
                    let iconFile = app.bundleURL
                        .appendingPathComponent("Contents")
                        .appendingPathComponent("Resources")
                        .appendingPathComponent(iconFileName)

                    app.icon = iconFile.pathExtension.isEmpty ?
                        NSImage(contentsOf: iconFile.appendingPathExtension("icns")) :
                        NSImage(contentsOf: iconFile)
                }

                if let defaultsSetting = defaultsSetting {
                    app.requiresLightMode = defaultsSetting
                }

                print("Updated app info: \(app)")
            }
        } catch let error {
            print("Could not load app info for \(app.name): \(error)")
        }
    }
}
