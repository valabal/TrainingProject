//
//  MoyaPlugin.swift
//  EmveepApp
//
//  Created by Fransky on 9/27/17.
//  Copyright © 2017 Emveep. All rights reserved.
//

import Foundation
import Moya
import Result
import SwiftyJSON


final class EmveepPlugin: PluginType {
    
    
    func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
   
        var request = request
        request.addValue("en", forHTTPHeaderField: "Language")
        request.addValue("d3ffa5d120918b167ea31b93d9917d", forHTTPHeaderField: "Apptoken")

        if let accessToken = UserManager.accessToken(){
    
            request.addValue(accessToken, forHTTPHeaderField: "Token")
            return request
            
        }
        
        return request
        
    }

    
    func didReceive(_ result: Result<Response, MoyaError>, target: TargetType) {
    
        //bisa test kode error disini.. misal kalo misalnya logout error maka otomatis logout atau kalo offline error keluarkan prompt error
        switch result {
        case let .success(moyaResponse):
            do {
                let data = try moyaResponse.mapJSON()
                do{
                    try moyaResponse.filterSuccessfulStatusCodes()
                }
                catch {
                    if let dic = data as? [String:Any], let status = dic["status"] as? [String:Any], let message = status["message"] as? String{
                        
                        if let code = status["code"] as? Int , code == 401{
                            NotificationCenter.default.post(name:.forceLogout, object: nil)
                        }
                        
                        AlertHelper.showAlert(title: "ALERT", message: message)
                    }
                }
            
            }
            catch {
                AlertHelper.showAlert(title: "ALERT", message: "Something wrong with the server. Try Again Later")
            }
            
        case let .failure(error):
            AlertHelper.showAlert(title: "ALERT", message: "BAD CONNECTION")
        }
        
        
    }
    
    
}


final class CurlPlugin: PluginType {
    
    func willSend(_ request: RequestType, target: TargetType) {
        
        if let requestUrl = request.request{
            //show curl
            if let curl = requestUrl.cURL(){
                print(curl)
            }
        }
        
    }
    
}


extension URLRequest{

    func cURL() -> String? {
        if let url = self.url {
            let length = url.absoluteString.utf16.count
            if (length == 0) {
                return nil
            }
            
            let curlCommand = NSMutableString()
            curlCommand.append("curl")
            
            // append URL
            curlCommand.appendFormat(" '%@'", url as CVarArg)
            
            // append method if different from GET
            if("GET" != self.httpMethod) {
                curlCommand.appendFormat(" -X %@", self.httpMethod!)
            }
            
            // append headers
            if let allHTTPHeaderFields = self.allHTTPHeaderFields {
                let allHeadersKeys = Array(allHTTPHeaderFields.keys)
                let sortedHeadersKeys  = allHeadersKeys.sorted()
                for key in sortedHeadersKeys {
                    curlCommand.appendFormat(" -H '%@: %@'",
                                             key, self.value(forHTTPHeaderField: key)!)
                }
            }
            
            // append HTTP body
            if let httpBody = self.httpBody , httpBody.count > 0 {
                if let body = NSString(data: httpBody,
                                       encoding: String.Encoding.utf8.rawValue) {
                    let escapedHttpBody = URLRequest.escapeAllSingleQuotes(value: body as String)
                    curlCommand.appendFormat(" --data '%@'", escapedHttpBody)
                }
                
            }
            
            return String(curlCommand)
        }
        
        return nil
     }
    
    
    static func escapeAllSingleQuotes(value: String) -> String {
        return value.replacingOccurrences(of: "'", with: "'\\''")
    }


}
