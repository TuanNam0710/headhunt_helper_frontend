//
//  HTTPRequester.swift
//  Headhunt helper
//
//  Created by Pham Le Tuan Nam on 09/07/2022.
//

import UIKit
import Alamofire

class HTTPRequester {
    func request(_ convertible: URLConvertible,
                 method: HTTPMethod = .get,
                 parameters: Parameters? = nil,
                 encoding: ParameterEncoding = JSONEncoding.default,
                 headers: HTTPHeaders? = nil,
                 completionHandler: @escaping (AFDataResponse<Any>) -> Void) {
        let headers: HTTPHeaders = [.authorization(username: kUsername, password: kPassword)]
        AF.request(convertible,
                   method: method,
                   parameters: parameters,
                   encoding: encoding,
                   headers: headers)
        .validate(statusCode: 200..<300)
        .responseJSON { response in
            completionHandler(response)
        }
    }
}
