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

final class EmveepPlugin: PluginType {
    
    
    func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
   
        if let accessToken = UserManager.accessToken(){
        
            var request = request
            request.addValue("Basic "+accessToken, forHTTPHeaderField: "Authorization")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            return request
            
        }
 
        return request
        
    }

    
    func didReceive(_ result: Result<Response, MoyaError>, target: TargetType) {
    
        //bisa test kode error disini.. misal kalo misalnya logout error maka otomatis logout atau kalo offline error keluarkan prompt error
        
    }
    
    
}


final class CurlPlugin: PluginType {
    
    func willSend(_ request: RequestType, target: TargetType) {
        
        if let requestUrl = request.request{
            //show curl
            print(requestUrl.cURL())
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
