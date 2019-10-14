//
//  NetworkWorker.swift
//  Test
//
//  Created by Kazhenbayeva Gulnaz on 12/6/18.
//  Copyright © 2018 --. All rights reserved.
//

import Alamofire
import SwiftyJSON

class NetworkWorker {

    static let shared = NetworkWorker()
    
    func sendRequest(command: URLRequestConvertible, isUpdateSession: Bool = false, completion: @escaping (_ json: JSON?, _ error: APIError?) -> ()) {
        
       Alamofire.request(command).response
        { [weak self] (response) in
            if Features.log {
                print("API HEADER - ", response.request?.allHTTPHeaderFields)
            }
            self?.handleResponse(command: command,
                                 response: response,
                                 isUpdateSession: isUpdateSession,
                                 completion: completion)
        }
    }

    
    
    // MARK: - Upload
    func sendFile(request: URLRequestConvertible, file: UIImage, parameters: [String : Any], isUpdateSession: Bool = false, completion: @escaping (_ json: JSON?, _ error: APIError?) -> ()) {
        
        print("SEND FILE")
       
        Alamofire.upload(multipartFormData:
        { (formData) in
            
//            let description = files["description"] as? String ?? ""
//            let document = files["document"] as! UIImage
//            formData.append(files.data(using: .utf8)!, withName: "description")
            let description = parameters["description"] as? String ?? "document"
            for param in parameters {
                if let value = param.value as? String {
                    formData.append(value.data(using: .utf8)!, withName: param.key)
                }
            }
            formData.append(file.jpegData(compressionQuality: 0.1)!, withName: "document", fileName: "\(description).jpeg", mimeType: "image/jpeg")

        }, with: request)
        { (encodingResult) in
            switch encodingResult
            {
            case .success(let upload, _, _):
                
//                    upload.uploadProgress(closure: { (progress) in
//                        print(progress)
//                    })
                upload.response { [weak self]  response in
                    self?.handleResponse(command: request,
                                         response: response,
                                         isUpdateSession: isUpdateSession,
                                         completion: completion)
                }
                
            case .failure(let encodingError):
                print(encodingError)
                completion(nil, APIError.validationError(encodingError.localizedDescription))
            }
        }
    }
        
    

    
    // MARK: - Download
    func dowloadFile(request: URLRequestConvertible, name: String, isUpdateSession: Bool = false, completion: @escaping (_ data: URL?, _ error: APIError?) -> ()) {
        
        
        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            
            var tempDirectoryURL = NSURL.fileURL(withPath: NSTemporaryDirectory(), isDirectory: true)
            tempDirectoryURL.appendPathComponent(name)
            return (tempDirectoryURL, [.removePreviousFile])
        }
        print("API URL ", request.urlRequest?.url?.absoluteString ?? "--")
        
        Alamofire.download(request, to: destination).response
        { [weak self] response in
            let statuscode = response.response?.statusCode ?? 0
            
            if let localURL = response.destinationURL, statuscode == 200 {
                
                completion(localURL, nil)
                
            } else {
                
                self?.handleError(code: statuscode, isUpdateSession: isUpdateSession, json: JSON())
                { (error) in
                    if error != nil {
                        if Features.log {
                            print("API ERROR ", JSON(), error?.localizedDescription ?? "")
                        }
                        
                        completion(nil, error)
                    } else {
                        NetworkWorker.shared.dowloadFile(request: request, name: name, completion: completion)
                    }
                }
            }
        }
    }
    
        
    // MARK: Handle RESPONSE
    func handleResponse(command: URLRequestConvertible,
                        response: DefaultDataResponse,
                        isUpdateSession: Bool = false,
                        completion: @escaping (_ json: JSON?, _ error: APIError?) -> ())
    {
        let statuscode = response.response?.statusCode ?? 0
        
        print("API URL ", command.urlRequest?.url?.absoluteString ?? "--")
        if let data = response.data {
            do {
                let json = try JSON(data: data)
                if Features.log {
                    print("API RESPONSE ", json)
                }
                if statuscode == 200 || statuscode == 201 {
                    completion(json, nil)
                } else {
                    self.handleError(code: statuscode, isUpdateSession: isUpdateSession, json: json)
                    { (error) in
                        if error != nil {
                            if Features.log {
                                print("API ERROR ", json, error?.localizedDescription ?? "")
                            }
                            completion(nil, error)
                        } else {
                            NetworkWorker.shared.sendRequest(command: command, isUpdateSession: true, completion: completion)
                        }
                    }
                }
                
            } catch {
                if statuscode == 200 || statuscode == 201 {
                    if Features.log {
                        print("API RESPONSE ", JSON())
                    }
                    completion(JSON(), nil)
                } else if statuscode == APIError.serverError.code {
                    completion(nil, APIError.serverError)
                }  else if statuscode == APIError.appVersionError.code {
                    completion(nil, APIError.appVersionError)
                } else {
                    completion(nil, APIError.unexpectedError)
                }
            }
            
        } else {
            Connectivity.isConnectedToInternet { (isConnected) in
                if isConnected {
                    completion(nil, APIError.serverError)
                } else {
                    completion(nil, APIError.networkError)
                }
            }
            
        }
    }
        
    
    // MARK: Handle ERROR
    func handleError(code: Int, isUpdateSession: Bool, json: JSON, completion: @escaping (_ error: APIError?) -> ()) {
        let errorCode = json["errorCode"].int ?? code
        let errorMessage = json["errorMessage"].string
        
        if !isUpdateSession && errorCode == APIError.sessionExpired.code {
            let token = User.shared.refreshToken ?? ""
            let endpoint: AuthEndpoint = .update(token: token)
            NetworkWorker.shared.sendRequest(command: endpoint, isUpdateSession: true) { (json, error) in
                if json != nil {
                    _ =  AuthModel(json: json!)
                    completion(nil)
                } else {
                    completion(error!)
                }
            }
        } else if errorMessage != nil {
            completion(APIError.badRequest(json))
        } else if isUpdateSession {
            completion(APIError.sessionExpired)
        } else {
            completion(APIError.unexpectedError)
        }
    }

}


class Connectivity: NSObject {
    
    class func isConnectedToInternet(_ completion: @escaping(Bool)->()) {
        return checkAccessToGoogle(completion)
    }
    
    class func checkAccessToGoogle(_ completion: @escaping(Bool)->()){
        let googleBaseURL = "https://google.com"
        var request = URLRequest(url: URL(string: googleBaseURL)!)
        request.timeoutInterval = 5
        Alamofire.request(request).response { (response) in
            if response.response != nil {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
}

