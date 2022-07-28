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
            if let data = response.value as? [String: Any] {
                if let currentDept = data["idDepartment"] as? Int {
                    SharedPreference.shared.putString(key: kCurrentDept, value: "\(currentDept)")
                    SharedPreference.shared.putString(key: kUserId, value: "\(data["id"] as! Int)")
                    SharedPreference.shared.putString(key: kKeychainName, value: data["name"] as! String)
                    SharedPreference.shared.putString(key: kRole, value: data["role"] as! String)
                }
            }
            completionHandler(response.result)
        }
    }
    
    func requestRegister(name: String, email: String, password: String, idDept: Int, role: String, completionHandler: @escaping (Result<Any, AFError>) -> Void) {
        let parameters: [String: Any] = [
            "name": name,
            "email": email,
            "password": password,
            "idDepartment": idDept,
            "role": role
        ]
        request(APIEndpoint.register.getURL(),
                method: .post,
                parameters: parameters) { response in
            completionHandler(response.result)
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
                                                          idDepartment: index["idDepartment"] as! Int,
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
    
    func requestDetailCV(id: String, completionHandler: @escaping (CVDetail?, Error?) -> Void) {
        let param: [String: Any] = [
            "id": id
        ]
        request(APIEndpoint.cvDetail.getURL(), method: .post, parameters: param) { response in
            switch response.result {
            case .success:
                if let data = try? JSONDecoder().decode(CVDetail.self, from: response.data!) {
                    completionHandler(data, nil)
                }
            case .failure:
                completionHandler(nil, response.error)
            }
        }
    }
    
    func requestUpdateDetailCV(id: Int, idDepartment: Int, idRecruiter: Int, status: Int, completionHandler: @escaping (Error?) -> Void) {
        let parameters: [String: Any] = [
            "id": id,
            "idDept": idDepartment,
            "idRecruiter": idRecruiter,
            "status": status
        ]
        request(APIEndpoint.updateCV.getURL(), method: .post, parameters: parameters) { response in
            switch response.result {
            case .success:
                completionHandler(nil)
            case .failure:
                completionHandler(response.error)
            }
        }
    }
    
    func requestJD(completionHandler: @escaping ([JobDescription]?, Error?) -> Void) {
        request(APIEndpoint.jd.getURL(), method: .get) { response in
            switch response.result {
            case .success:
                if let data = try? JSONDecoder().decode([JobDescription].self, from: response.data!) {
                    completionHandler(data, nil)
                } else {
                    completionHandler([], nil)
                }
            case .failure:
                completionHandler(nil, response.error)
            }
        }
    }
    
    func requestPosition(completionHandler: @escaping ([Position]?, Error?) -> Void) {
        let param: [String: Any] = [
            "id": SharedPreference.shared.getString(key: kCurrentDept)
        ]
        request(APIEndpoint.position.getURL(), method: .post, parameters: param) { response in
            switch response.result {
            case .success:
                if let data = try? JSONDecoder().decode([Position].self, from: response.data!) {
                    completionHandler(data, nil)
                } else {
                    completionHandler([], nil)
                }
            case .failure:
                completionHandler(nil, response.error)
            }
        }
    }
    
    func requestDeleteJD(id: Int, completionHandler: @escaping (Error?) -> Void) {
        let param: [String: Any] = [
            "id": id
        ]
        request(APIEndpoint.deleteJD.getURL(), method: .post, parameters: param) { response in
            switch response.result {
            case .success:
                completionHandler(nil)
            case .failure:
                completionHandler(response.error)
            }
        }
    }
    
    func requestCreateJD(idPosition: Int, description: String, noOfJobs: Int, dueDate: String, completionHandler: @escaping (Error?) -> Void) {
        let parameters: [String: Any] = [
            "idPosition": idPosition,
            "description": description,
            "noOfJobs": noOfJobs,
            "dueDate": dueDate
        ]
        request(APIEndpoint.createJD.getURL(), method: .post, parameters: parameters) { response in
            switch response.result {
            case .success:
                completionHandler(nil)
            case .failure:
                completionHandler(response.error)
            }
        }
    }
    
    func requestUpdateJD(id: Int, idPosition: Int, description: String, noOfJobs: Int, dueDate: String, completionHandler: @escaping (Error?) -> Void) {
        let parameters: [String: Any] = [
            "id": id,
            "idPosition": idPosition,
            "description": description,
            "noOfJobs": noOfJobs,
            "dueDate": dueDate
        ]
        request(APIEndpoint.updateJD.getURL(), method: .post, parameters: parameters) { response in
            switch response.result {
            case .success:
                completionHandler(nil)
            case .failure:
                completionHandler(response.error)
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
    
    func requestAssignCVToDepartment(id: String, idDepartment: String, completionHandler: @escaping (Result<Any, AFError>) -> Void) {
        request(APIEndpoint.assignAndUpdate.getURLAssignToDept(id1: id, id2: idDepartment),
                method: .post) { response in
            completionHandler(response.result)
        }
    }
    
    func requestAssignCVToRecruiter(id: String, idRecruiter: String, completionHandler: @escaping (Result<Any, AFError>) -> Void) {
        request(APIEndpoint.assignAndUpdate.getURLAssignToRecruiter(id1: id, id2: idRecruiter),
                method: .post) { response in
            completionHandler(response.result)
        }
    }
    
    func requestUpdateCVStatus(id: String, status: String, completionHandler: @escaping (Result<Any, AFError>) -> Void) {
        request(APIEndpoint.assignAndUpdate.getURLUpdateCVStatus(id1: id, status: status),
                method: .post) { response in
            completionHandler(response.result)
        }
    }
}
