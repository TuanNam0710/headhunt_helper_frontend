//
//  APIServives.swift
//  Headhunt helper
//
//  Created by Pham Le Tuan Nam on 09/07/2022.
//

import UIKit
import Alamofire

class APIServices: HTTPRequester {
    static let shared = APIServices()
    
    func requestLogin(email: String, password: String, completionHandler: @escaping (Result<Any, AFError>) -> Void) {
        let parameters: [String: Any] = [
            "email": email,
            "password": password
        ]
        request(APIEndpoint.login.getURL(),
                method: .post,
                parameters: parameters) { response in
            completionHandler(response.result)
        }
    }
    
    func requestRegister(name: String, email: String, password: String, completionHandler: @escaping (Result<Any, AFError>) -> Void) {
        let parameters: [String: Any] = [
            "name": name,
            "email": email,
            "password": password
        ]
        request(APIEndpoint.register.getURL(),
                method: .post,
                parameters: parameters) { response in
            completionHandler(response.result)
        }
    }
    
    func requestUserInfo(email: String, completionHandler: @escaping (RecruiterInfo?, Error?) -> Void) {
        let url = APIEndpoint.getUserInfo.getURL() + email
        request(url,
                method: .get) { response in
            switch response.result {
            case .success(_):
                if let data = response.value as? [String: Any] {
                    let recruiterInfo = RecruiterInfo(id: data["id"] as! Int,
                                                      name: data["name"] as! String,
                                                      email: data["email"] as! String,
                                                      password: data["password"] as! String)
                    completionHandler(recruiterInfo, nil)
                } else {
                    completionHandler(nil, nil)
                }
            case .failure(_):
                completionHandler(nil, response.error)
            }
        }
    }
    
    func requestGetAllCV(completionHandler: @escaping ([CVInfo]?, Error?) -> Void) {
        request(APIEndpoint.getAllCV.getURL(),
                method: .get) { response in
            switch response.result {
            case .success(_):
                if let data = response.value as? [[String: Any]] {
                    var cvList: [CVInfo] = []
                    for index in data {
                        let cvInfo = CVInfo(id: index["id"] as! Int,
                                            name: index["name"] as! String,
                                            gender: index["gender"] as! Int,
                                            position: index["position"] as! String,
                                            email: index["email"] as! String,
                                            phone: index["phone"] as! String,
                                            idRecruiter: index["idRecruiter"] as? Int,
                                            status: index["status"] as! Int,
                                            idDepartment: index["idDepartment"] as? Int)
                        cvList.append(cvInfo)
                    }
                    completionHandler(cvList, nil)
                } else {
                    completionHandler(nil, nil)
                }
            case .failure(_):
                completionHandler(nil, response.error)
            }
        }
    }
    
    func requestLogout(id: String, completionHandler: @escaping (Result<Any, AFError>) -> Void) {
        let parameters: [String: Any] = [
            "id": id
        ]
        request(APIEndpoint.logout.getURL(),
                method: .post,
                parameters: parameters) { response in
            completionHandler(response.result)
        }
    }
    
    func requestAllRecruiters(completionHandler: @escaping ([RecruiterInfo]?, Error?) -> Void) {
        request(APIEndpoint.allRecruiters.getURL(),
                method: .get) { response in
            switch response.result {
            case .success:
                if let data = response.value as? [[String: Any]] {
                    var recruiterList: [RecruiterInfo] = []
                    for index in data {
                        let recruiterInfo = RecruiterInfo(id: index["id"] as! Int,
                                                          name: index["name"] as! String,
                                                          email: index["email"] as! String,
                                                          password: index["password"] as! String)
                        recruiterList.append(recruiterInfo)
                    }
                    completionHandler(recruiterList, nil)
                } else {
                    completionHandler(nil, nil)
                }
            case .failure:
                completionHandler(nil, response.error)
            }
        }
    }
    
    func requestAllDepts(completionHandler: @escaping ([Department]?, Error?) -> Void) {
        request(APIEndpoint.allDepts.getURL(),
                method: .get) { response in
            switch response.result {
            case .success:
                if let data = response.value as? [[String: Any]] {
                    var departmentList: [Department] = []
                    for index in data {
                        let departmentInfo = Department(id: index["id"] as! Int,
                                                          name: index["name"] as! String)
                        departmentList.append(departmentInfo)
                    }
                    completionHandler(departmentList, nil)
                } else {
                    completionHandler(nil, nil)
                }
            case .failure:
                completionHandler(nil, response.error)
            }
        }
    }
    
    func requestBasicInfoCV(id: String, completionHandler: @escaping ([CVInfo]?, Error?) -> Void) {
        request(APIEndpoint.cvBasicInfo.getURL() + id,
                method: .get) { response in
            switch response.result {
            case .success:
                if let data = response.value as? [[String: Any]] {
                    var basicInfoList: [CVInfo] = []
                    for index in data {
                        let basicInfo = CVInfo(id: index["id"] as! Int,
                                                    name: index["name"] as! String,
                                                    gender: index["gender"] as! Int,
                                                    position: index["position"] as! String,
                                                    email: index["email"] as! String,
                                                    phone: index["phone"] as! String,
                                                    idRecruiter: index["idRecruiter"] as? Int,
                                                    status: index["status"] as! Int,
                                                    idDepartment: index["idDepartment"] as? Int)
                        basicInfoList.append(basicInfo)
                    }
                    completionHandler(basicInfoList, nil)
                } else {
                    completionHandler(nil, nil)
                }
            case .failure:
                completionHandler(nil, response.error)
            }
        }
    }
    
    func requestSkillsCV(id: String, completionHandler: @escaping ([CVSkills]?, Error?) -> Void) {
        request(APIEndpoint.cvSkills.getURL() + id,
                method: .get) { response in
            switch response.result {
            case .success:
                if let data = response.value as? [[String: Any]] {
                    var skillList: [CVSkills] = []
                    for index in data {
                        let skill = CVSkills(id: index["id"] as! Int,
                                                 idCV: index["idCV"] as! Int,
                                                 detail: index["detail"] as! String)
                        skillList.append(skill)
                    }
                    completionHandler(skillList, nil)
                } else {
                    completionHandler(nil, nil)
                }
            case .failure:
                completionHandler(nil, response.error)
            }
        }
    }
    
    func requestWorkExperienceCV(id: String, completionHandler: @escaping ([CVWorkExperience]?, Error?) -> Void) {
        request(APIEndpoint.cvWorkExperience.getURL() + id,
                method: .get) { response in
            switch response.result {
            case .success:
                if let data = response.value as? [[String: Any]] {
                    var workExperienceList: [CVWorkExperience] = []
                    for index in data {
                        let workExperience = CVWorkExperience(id: index["id"] as! Int,
                                                              idCV: index["idCV"] as! Int,
                                                              companyName: index["companyName"] as! String,
                                                              position: index["position"] as! String,
                                                              detail: index["detail"] as! String,
                                                              startTime: index["startTime"] as! String,
                                                              endTime: index["endTime"] as! String)
                        workExperienceList.append(workExperience)
                    }
                    completionHandler(workExperienceList, nil)
                } else {
                    completionHandler(nil, nil)
                }
            case .failure:
                completionHandler(nil, response.error)
            }
        }
    }
    
    func requestAdditionalInfoCV(id: String, completionHandler: @escaping ([CVAdditionalInfo]?, Error?) -> Void) {
        request(APIEndpoint.cvAdditionalInfo.getURL() + id,
                method: .get) { response in
            switch response.result {
            case .success:
                if let data = response.value as? [[String: Any]] {
                    var additionalInfoList: [CVAdditionalInfo] = []
                    for index in data {
                        let additionalInfo = CVAdditionalInfo(id: index["id"] as! Int,
                                                              idCV: index["idCV"] as! Int,
                                                              title: index["title"] as! String,
                                                              detail: index["detail"] as! String)
                        additionalInfoList.append(additionalInfo)
                    }
                    completionHandler(additionalInfoList, nil)
                } else {
                    completionHandler(nil, nil)
                }
            case .failure:
                completionHandler(nil, response.error)
            }
        }
    }
}
