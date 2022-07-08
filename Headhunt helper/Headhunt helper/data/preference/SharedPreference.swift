//
//  SharedPreference.swift
//  Headhunt helper
//
//  Created by Phạm Lê Tuấn Nam on 08/07/2022.
//

import Foundation

class SharedPreference {
    static let shared = SharedPreference()
    let secureDataHelper = SecureDataHelper.shared

    func getString(key: String) -> String {
        return UserDefaults.standard.string(forKey: key) ?? kEmptyStr
    }

    func getInt(key: String) -> Int {
        return UserDefaults.standard.integer(forKey: key)
    }

    func getBoolean(key: String) -> Bool {
        return UserDefaults.standard.bool(forKey: key)
    }

    func putString(key: String, value: String) {
        UserDefaults.standard.set(value, forKey: key)
    }

    func putBoolean(key: String, value: Bool) {
        UserDefaults.standard.set(value, forKey: key)
    }

    func putInt(key: String, value: Int) {
        UserDefaults.standard.set(value, forKey: key)
    }
}
