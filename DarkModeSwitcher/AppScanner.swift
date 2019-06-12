//
//  AppScanner.swift
//  DarkModeSwitcher
//
//  Created by Kuba Suder on 12.06.2019.
//  Copyright © 2019 Kuba Suder. All rights reserved.
//

import Foundation

class AppScanner {

    var applicationFolders: [URL] {
        return FileManager.default.urls(for: .applicationDirectory, in: [.userDomainMask, .localDomainMask])
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
                }
            } catch {
                NSLog("Error: couldn't scan applications in %@", "\(folder)")
            }
        }

        return foundApps
    }
}
