//
//  KeychainManager.swift
//  Headhunt helper
//
//  Created by Phạm Lê Tuấn Nam on 08/07/2022.
//

import Foundation
import Security

/// Save and retrieve data under encrypted
class KeychainManager {

    static func saveData(key: String, value: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: value.data(using: String.Encoding.utf8) as Any ]
        SecItemDelete(query as CFDictionary )
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status != errSecDuplicateItem else {
            throw  KeychainError.duplicateEntry
        }
        guard status == errSecSuccess else {
            throw KeychainError.unknown(status)
        }
    }

    static func getData(key: String) -> NSString {

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne ]
        var dataTypeRef: AnyObject?
        let status: OSStatus = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        if status == noErr {
            if let retrieveData = dataTypeRef as? NSData {
                return NSString(data: retrieveData as Data, encoding: String.Encoding.utf8.rawValue) ?? ""
            }
        }
        return ""
    }

    static func removeData(key: String, value: String) throws {
        let query: [String: AnyObject] = [
            // kSecAttrAccount, and kSecClass
            // uniquely identify the item to delete in Keychain
            kSecAttrAccount as String: key as AnyObject,
            kSecClass as String: kSecClassGenericPassword
        ]
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess else {
            throw KeychainError.unexpectedStatus(status)
        }
    }
}
