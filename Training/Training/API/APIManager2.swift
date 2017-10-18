//
//  APIManager2.swift
//  Training
//
//  Created by Valbal on 10/16/17.
//  Copyright © 2017 Emveep. All rights reserved.
//

import Foundation
import Alamofire
import RxCocoa
import RxSwift
import RxAlamofire

struct MerchantResponse{
   
    let result : [Merchant]
    let pagination : [String:Any]?
    
    init(_ result:[Merchant], pagination : [String:Any]? = nil) {
        self.result = result
        self.pagination = pagination
    }
    
}

class APIManager2: NSObject {
    
    
    static func Login (email:String,password:String) -> Observable<NSDictionary>{
        
        let URL = ROOT_URL+"login/"
        
        let param = ["email":email,"password":password]
        
        let request = json(.post, URL, parameters: param).flatMap{ json -> Observable<NSDictionary> in
            
            guard let JSONDic = json as? [String:Any] ,let result = JSONDic["user"] as? NSDictionary, let token = result["token"] as? NSString else{
                return Observable.empty()
            }
            
            UserManager.saveAccessToken(token: token)
            return Observable.just(JSONDic as NSDictionary)
            
        }
        
        return request
        
    }

    
    static func MerchantList (request:ListMerchantRequest) -> Observable<MerchantResponse>{
        
        let URL = ROOT_URL+"merchants/search"
        
        let param = request.toDictionary() as? Parameters
        
        let request = json(.post, URL, parameters: param).flatMap{ json -> Observable<MerchantResponse> in
            
            guard let json = json as? [String: AnyObject],let merchants = json["results"] as? [NSDictionary] else {
                return Observable.empty()
            }
            
            let element = merchants.map{Merchant(dictionary:$0)}
            
            let pagination = json["pagination"] as? [String:Any]
            
            return Observable.just(MerchantResponse.init(element,pagination:pagination))
            
        }
        
        return request

    }
    
    static func MerchantDetail (merchantID:NSNumber) -> Observable<Merchant>{
       
        let URL = ROOT_URL+"merchants/detail/\(merchantID)"
        
        let request = json(.get, URL).flatMap{ json -> Observable<Merchant> in
            
            guard let json = json as? [String: AnyObject],let merchant = json["merchant"] as? NSDictionary else {
                return Observable.empty()
            }
            
            let element = Merchant(dictionary: merchant)
            
            if let products = json["products"] as? NSDictionary {
              element.products = products
            }
            
            return Observable.just(element)

            }
        
        return request
        
    }
    
    
}
