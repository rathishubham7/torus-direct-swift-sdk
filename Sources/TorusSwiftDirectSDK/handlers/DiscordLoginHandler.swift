//
//  DiscordLoginHandler.swift
//  
//
//  Created by Shubham on 13/11/20.
//

import Foundation
import PromiseKit

class DiscordLoginHandler: AbstractLoginHandler{
    let loginType: SubVerifierType
    let clientID: String
    let redirectURL: String
    var userInfo: [String: Any]?
    let extraQueryParams: [String: String]
    let defaultParams: [String:String] = ["scope": "email identify", "response_type": "token"]
    
    public init(loginType: SubVerifierType = .web, clientID: String, redirectURL: String, extraQueryParams: [String: String] = [:]){
        self.loginType = loginType
        self.clientID = clientID
        self.redirectURL = redirectURL
        self.extraQueryParams = extraQueryParams
    }
    
    func getUserInfo(responseParameters: [String : String]) -> Promise<[String : Any]> {
        return self.handleLogin(responseParameters: responseParameters)
    }
    
    func getLoginURL() -> String{
        // left join
        var tempParams = self.defaultParams
        tempParams.merge(["redirect_uri": self.redirectURL, "client_id": self.clientID]){(_, new ) in new}
        tempParams.merge(self.extraQueryParams){(_, new ) in new}
        
        // Reconstruct URL
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "discord.com"
        urlComponents.path = "/api/oauth2/authorize"
        urlComponents.setQueryItems(with: tempParams)
        
        return urlComponents.url!.absoluteString
        //      return "https://discord.com/api/oauth2/authorize?response_type=token" + "&client_id=\(self.clientId)&scope=email identify&redirect_uri=\(newRedirectURL)".addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
    }
    
    func getVerifierFromUserInfo() -> String {
        return self.userInfo!["id"] as! String
    }
    
    func handleLogin(responseParameters: [String : String]) -> Promise<[String : Any]> {
        let (tempPromise, seal) = Promise<[String:Any]>.pending()
        
        if let accessToken = responseParameters["access_token"]{
            var request = makeUrlRequest(url: "https://discordapp.com/api/users/@me", method: "GET")
            request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            
            URLSession.shared.dataTask(.promise, with: request).map{
                try JSONSerialization.jsonObject(with: $0.data) as! [String:Any]
            }.done{ data in
                var json = data
                self.userInfo = json
                json["tokenForKeys"] = accessToken
                json["verifierId"] = self.getVerifierFromUserInfo()
                seal.fulfill(json)
                
            }.catch{err in
                seal.reject(TSDSError.getUserInfoFailed)
            }
        }else{
            seal.reject(TSDSError.accessTokenNotProvided)
        }
        
        return tempPromise
    }
    
    
}

