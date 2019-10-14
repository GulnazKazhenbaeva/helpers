//
//  ConnectionHelper.swift
//
//  Created by Kazhenbayeva Gulnaz on 10/23/18.
//

import UIKit
import Alamofire

class AFManager {
    
    static func shared(_ request: AFRouter)->SessionManager {
        switch request {
        case .identification:
            
            let manager = Alamofire.SessionManager.default
            manager.delegate.sessionDidReceiveChallengeWithCompletion = { session, challenge, completion in
                AFManager.urlSession(session, didReceive: challenge, completionHandler: completion)
            }
            return manager
        default:
            return Alamofire.SessionManager.default
        }
    }
    
    static func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
            var secresult = SecTrustResultType.invalid
            let serverTrust = challenge.protectionSpace.serverTrust!
            if (SecTrustEvaluate(serverTrust, &secresult) != errSecSuccess){
                return;
            }
            //if we want to ignore invalid server for certificates, we just accept the server
            if secresult == SecTrustResultType.proceed || secresult == SecTrustResultType.unspecified {
                //When testing this against a trusted server I got kSecTrustResultUnspecified every time. But the other two match the description of a trusted server
//                completionHandler
                let credential = URLCredential(trust: challenge.protectionSpace.serverTrust!)
                return completionHandler(URLSession.AuthChallengeDisposition.useCredential, credential)
            }
        } else if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodClientCertificate {
            //this handles authenticating the client certificate
            
            let identityApp = KeychainManager.shared().selectedIdentity
            
            if let identityApp = identityApp {
                var certRef: SecCertificate?
                guard SecIdentityCopyCertificate(identityApp, &certRef) == errSecSuccess else {
                   return print("Error in SecIdentityCopyCertificate")
                }
                let certArray = [certRef]
                let myCers: [CFArray] = (certArray as? [CFArray])!
                
                let credential = URLCredential.init(identity: identityApp, certificates: myCers, persistence: .forSession)
                challenge.sender!.use(credential, for: challenge)
                return completionHandler(URLSession.AuthChallengeDisposition.useCredential, credential)
            }

        } else if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodDefault || challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodNTLM {
            print("BASIC AUTHENTICATION")
            return completionHandler(URLSession.AuthChallengeDisposition.performDefaultHandling, nil)
        }
        challenge.sender!.cancel(challenge)
        print("cancel")
        return completionHandler(URLSession.AuthChallengeDisposition.cancelAuthenticationChallenge, nil)
        
    }
   
    
}

