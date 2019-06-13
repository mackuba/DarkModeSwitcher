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
            + [URL(fileURLWithPath: "/System/Applications")]
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

            app.bundleIdentifier = info.bundleIdentifier

            let iconFile =  app.bundleURL
                .appendingPathComponent("Contents")
                .appendingPathComponent("Resources")
                .appendingPathComponent(info.iconFileName)

            app.icon = iconFile.pathExtension.isEmpty ?
                NSImage(contentsOf: iconFile.appendingPathExtension("icns")) :
                NSImage(contentsOf: iconFile)

            print("Updated app info: \(app)")

            DispatchQueue.main.async {
                app.didChange.send(())
            }
        } catch let error {
            print("Could not load app info for \(app.name): \(error)")
        }
    }
}
