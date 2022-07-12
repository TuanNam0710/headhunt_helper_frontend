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
}
