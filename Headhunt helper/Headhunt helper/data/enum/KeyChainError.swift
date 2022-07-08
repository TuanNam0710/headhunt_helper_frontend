//
//  KeyChainError.swift
//  Headhunt helper
//
//  Created by Phạm Lê Tuấn Nam on 08/07/2022.
//

import Foundation

enum KeychainError: Error {
    case duplicateEntry
    case unknown(OSStatus)
    case unexpectedStatus(OSStatus)
}
