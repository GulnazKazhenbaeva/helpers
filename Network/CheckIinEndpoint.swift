//
//  CheckIinEndpoint.swift
//  arm_rbk
//
//  Created by Kazhenbayeva Gulnaz on 1/30/19.
//  Copyright © 2019 --. All rights reserved.
//

import Foundation
import Alamofire

enum CheckIinEndpoint: URLRequestConvertible {
    
    case check(iin: String)
    
    func asURLRequest() throws -> URLRequest {
        let url = try baseURL.asURL()
        var request = URLRequest(url: url.appendingPathComponent(path))
        request.httpMethod = method.rawValue
        request.timeoutInterval = TimeInterval(30)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        //        addAuthHeader(&request)
        return try URLEncoding.default.encode(request, with: parameters)
    }
    
}


extension CheckIinEndpoint {
    var baseURL: URL { return URL(string: "https://baseUrl.kz")! }
    
    var method: HTTPMethod{
        switch self {
        case .check:
            return .get
        }
    }
    var path: String {
        switch self {
        case .check:
            return  "/checkIin"
        }
    }
    
    var headers: [String:String]? {
        return nil
    }
    var parameters: Parameters? {
        switch self {
        case .check(iin: let iin):
            return ["checkIin":iin]
        }
    }
}
