//
//  SecureDataHelper.swift
//  Headhunt helper
//
//  Created by Phạm Lê Tuấn Nam on 08/07/2022.
//

import Foundation

final class SecureDataHelper {
    static let shared = SecureDataHelper()
    
    func saveUserInfo(name: String, email: String) {
        putString(key: kKeychainName, value: name)
        putString(key: kKeychainEmail, value: email)
    }
    
    func getUserInfo() -> (String, String) {
        let name = getString(key: kKeychainName)
        let email = getString(key: kKeychainEmail)
        return (name, email)
    }

    func getString(key: String) -> String {
        return KeychainManager.getData(key: key) as String
    }

    func putString(key: String, value: String) {
        try? KeychainManager.saveData(key: key, value: value)
    }
}
