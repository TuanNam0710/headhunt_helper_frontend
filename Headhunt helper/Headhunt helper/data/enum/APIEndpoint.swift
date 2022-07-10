//
//  APIEndpoint.swift
//  Headhunt helper
//
//  Created by Pham Le Tuan Nam on 09/07/2022.
//

import UIKit

enum APIEndpoint: String {
    case login = "/login"
    case register = "/register"
    case getUserInfo = "/getUserInfo/"
    case getAllCV = "/cv/all"
    
    func getURL() -> String {
        return kBaseAPI + self.rawValue
    }
}
