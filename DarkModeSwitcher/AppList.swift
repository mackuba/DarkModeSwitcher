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
            }
        }
    }
}
