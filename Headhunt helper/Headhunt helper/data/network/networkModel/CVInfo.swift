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
}

struct CVDetail: Decodable {
    var basicInfo: CVInfo
    var skill: [CVSkills]
    var workExperience: [CVWorkExperience]
    var additionalInfo: [CVAdditionalInfo]
}
