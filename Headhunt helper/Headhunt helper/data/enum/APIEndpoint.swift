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
    case getAllCV = "/cv"
    case logout = "/logout"
    case allRecruiters = "/users"
    case allDepts = "/depts"
    case cvBasicInfo = "/cv/basicInfo/"
    case cvSkills = "/cv/skills/"
    case cvWorkExperience = "/cv/workExperience/"
    case cvAdditionalInfo = "/cv/additionalInfo/"
    case assignAndUpdate = "/cv/"
    case cvDetail = "/cv/detail"
    case jd = "/jds"
    case position = "/positions"
    case deleteJD = "/jd/delete"
    case createJD = "/jd/create"
    case updateJD = "/jd/update"
    case updateCV = "/cv/changeDetail"
    
    func getURL() -> String {
        return kBaseAPI + self.rawValue
    }
    
    func getURLAssignToDept(id1: String, id2: String) -> String {
        return kBaseAPI + self.rawValue + id1 + "/assignToDept/" + id2
    }
    
    func getURLAssignToRecruiter(id1: String, id2: String) -> String {
        return kBaseAPI + self.rawValue + id1 + "/assignToRecruiter/" + id2
    }
    
    func getURLUpdateCVStatus(id1: String, status: String) -> String {
        return kBaseAPI + self.rawValue + id1 + "/updateCVStatus/" + status
    }
}
