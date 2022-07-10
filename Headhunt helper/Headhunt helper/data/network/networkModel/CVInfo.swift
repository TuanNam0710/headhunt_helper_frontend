//
//  CVInfo.swift
//  Headhunt helper
//
//  Created by Pham Le Tuan Nam on 10/07/2022.
//

import UIKit

struct CVInfo: Decodable {
    var id: Int
    var name: String
    var gender: Int
    var position: String
    var email: String
    var phone: String
    var idRecruiter: Int?
    var status: Int
    var idDepartment: Int?
    
    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case gender
        case position
        case email
        case phone
        case idRecruiter = "id_recruiter"
        case status
        case idDepartment = "id_department"
    }
}
