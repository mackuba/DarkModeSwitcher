//
//  Defaults.swift
//  DarkModeSwitcher
//
//  Created by Kuba Suder on 13.06.2019.
//  Copyright © 2019 Kuba Suder. All rights reserved.
//

import Foundation
import ShellOut

private let RequiresAquaSetting = "NSRequiresAquaSystemAppearance"

class Defaults {
    func checkRequiresLightMode(for bundleIdentifier: String) -> Bool? {
        do {
            let value = try shellOut(
                to: "defaults",
                arguments: ["read", bundleIdentifier, RequiresAquaSetting]
            )

            return (value == "1")
        } catch let error as ShellOutError {
            let errorMessage = String(decoding: error.errorData, as: UTF8.self)

            if errorMessage != "" && !errorMessage.contains("does not exist") {
                print("Error checking defaults for \(bundleIdentifier): \(error)")
            }
        } catch {
            print("Error checking defaults for \(bundleIdentifier): \(error)")
        }

        return nil
    }

    func setRequiresLightMode(_ lightMode: Bool, for bundleIdentifier: String) {
        do {
            let arguments = lightMode ?
                ["write", bundleIdentifier, RequiresAquaSetting, "-bool", "true"] :
                ["delete", bundleIdentifier, RequiresAquaSetting]

            try shellOut(to: "defaults", arguments: arguments)
        } catch let error {
            print("Error setting default for \(bundleIdentifier): \(error)")
        }
    }
}
