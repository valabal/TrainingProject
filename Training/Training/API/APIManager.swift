//
//  APIManager.swift
//  EmveepApp
//
//  Created by Valbal on 12/7/16.
//  Copyright © 2016 Emveep. All rights reserved.
//

import UIKit
import Alamofire
import EVReflection

enum API_ENVIRONTMENT{
   case APIARY
   case STAGING
   case PRODUCTION
}

let CURRENT_ENV : API_ENVIRONTMENT = API_ENVIRONTMENT.APIARY

var ROOT_URL : String {
    
    switch CURRENT_ENV {
    case .APIARY :
        return "http://private-1aa5a-alacarteapiary.apiary-mock.com/"
    case .STAGING :
        return "http://alacarte.stagingapps.net/api/v1/"
    case .PRODUCTION :
        return "http://alacarte.stagingapps.net/api/v1/"
    }
    
}


let URI_LOGIN = "auth/login/"


class APIManager: NSObject {
    
    public typealias ResultCallback = (_ result:NSDictionary?) -> Swift.Void
    public typealias ErrorCallback = (_ error:Error?) -> Swift.Void
    public typealias CallBack = (_ result:Result<Any>?) -> Swift.Void
    
    public enum APIError: Error {
        case NO_DATA_FOUND
    }
    
    
    static func getAuthHeader() -> HTTPHeaders?{
        
        let accessToken : String? = UserManager.accessToken()
        
        if(accessToken != nil){
            
            let headers: HTTPHeaders = [
                "Token": accessToken!,
                "Language": "en",
                "AppToken" : "d3ffa5d120918b167ea31b93d9917d"
            ]
            
            return headers;
            
        }
        
        return nil;
    }
    
    
    static func Login (authDic:NSDictionary, callback:@escaping APIManager.ResultCallback, failure:APIManager.ErrorCallback? = nil){
        
        let URL = ROOT_URL+URI_LOGIN
        
        let param = authDic as? Parameters
        
        Alamofire.request(URL, method: .post,parameters:param).responseJSON { response in
            
            switch response.result {
            case  .success(let JSON):
                
                guard let JSONDic = JSON as? NSDictionary else{
                    callback(nil)
                    return
                }
                
                if let result = JSONDic["user"] as? NSDictionary, let token = result["token"] as? NSString{
                    UserManager.saveAccessToken(token: token)
                }
                
                callback(JSONDic)
                break
                
            case .failure(let error):
                failure?(error)
                break
            }
        
        }
    }
    
    
    static func MerchantList (request:ListMerchantRequest, callback:@escaping APIManager.ResultCallback, failure:APIManager.ErrorCallback? = nil){
        
        let URL = ROOT_URL+"merchants/search"
        
        let param = request.toDictionary() as? Parameters
        
        Alamofire.request(URL, method: .post,parameters:param).responseJSON { response in
            
            switch response.result {
            case  .success(let JSON):
                
                guard let JSONDic = JSON as? NSDictionary else{
                    callback(nil)
                    return
                }
                
                callback(JSONDic)
                break
                
            case .failure(let error):
                failure?(error)
                break
            }
            
        }
    }
    
    
    static func insertParameterToMultipartForm(multipartFormData:MultipartFormData, parameters:Parameters?,data:Data? ){
        
        if let data = data {
            multipartFormData.append(data, withName: "attachment")
        }
        
        guard let parameters = parameters else{
            return;
        }
        
        for (key, value) in parameters {
            
            var valueString = value
            
            if let result_number = value as? NSNumber
            {
                valueString = "\(result_number)"
            }
            else if let result_date = value as? NSDate
            {
                valueString = Date.stringFromDate(dateInput: result_date as Date, dateFormat: "dd-MM-yyyy")
            }
            
            if let dataParam = (valueString as AnyObject).data(using: String.Encoding.utf8.rawValue){
                multipartFormData.append(dataParam, withName: key)
            }
        }
        
    }

    
    
    
}
