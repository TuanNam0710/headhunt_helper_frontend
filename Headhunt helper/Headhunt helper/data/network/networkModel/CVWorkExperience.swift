//
//  CVWorkExperience.swift
//  Headhunt helper
//
//  Created by Pham Le Tuan Nam on 11/07/2022.
//

import UIKit

struct CVWorkExperience: Decodable {
    var id: Int
    var idCV: Int
    var companyName: String
    var position: String
    var detail: String
    var startTime: String
    var endTime: String
}
