//
//  AppDelegate.swift
//  Headhunt helper
//
//  Created by Phạm Lê Tuấn Nam on 08/07/2022.
//

import UIKit
import DropDown

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        DropDown.startListeningToKeyboard()
        let currentId = UserDefaults.standard.value(forKey: kUserId) as? Int
        if let currentId = currentId {
            UserDefaults.standard.set(nil, forKey: kUserId)
            SecureDataHelper.shared.saveUserInfo(name: kEmptyStr, email: kEmptyStr)
            APIServices.shared.requestLogout(id: "\(currentId)") { _ in }
        }
        return true
    }
}

