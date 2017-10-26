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
import Moya

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
        
        return Provider.requestJSON(.login(email: email, password: password)).flatMap{
            json -> Observable<NSDictionary> in
            
            guard let JSONDic = json as? [String:Any] ,let result = JSONDic["user"] as? NSDictionary, let token = result["token"] as? NSString else{
                return Observable.empty()
            }
            
            UserManager.saveAccessToken(token: token)
            return Observable.just(JSONDic as NSDictionary)
            
        }
        
    }

    
    static func MerchantList (request:ListMerchantRequest) -> Observable<MerchantResponse>{
        
        return Provider.requestJSON(.merchantList(request:request)).flatMap{ json -> Observable<MerchantResponse> in
            
            guard let json = json as? [String: AnyObject],let merchants = json["results"] as? [NSDictionary] else {
                return Observable.empty()
            }
            
            let element = merchants.map{Merchant(dictionary:$0)}
            
            let pagination = json["pagination"] as? [String:Any]
            
            return Observable.just(MerchantResponse.init(element,pagination:pagination))
            
            }
            /*
            .do(onError:{error in
                if let err = error as? Moya.MoyaError {
                    switch(err){
                    case .statusCode(let response) :
                         let data = try response.mapJSON()
                        break
                    default : break
                    }
                }
            })*/
        

    }
    
    
    static func MerchantDetail (merchantID:NSNumber) -> Observable<Merchant>{
        
        
        return Provider.requestJSON(.merchantDetail(merchantID: merchantID)).flatMap{ jsonResult -> Observable<Merchant> in
            
            guard let json = jsonResult as? [String: AnyObject],let merchant = json["merchant"] as? NSDictionary else {
                return Observable.empty()
            }
            
            let element = Merchant(dictionary: merchant)
            
            if let products = json["products"] as? NSDictionary {
                element.products = products
            }
            
            return Observable.just(element)
            
        }
        
    }
    
    static func MerchantFavorite (merchantID:NSNumber, isFavorite:Bool) -> Observable<NSDictionary>{
        
        return Provider.requestJSON(.merchantFavorite(merchantID: merchantID, isFavorite: isFavorite)).flatMap{ jsonResult -> Observable<NSDictionary> in
            
            guard let json = jsonResult as? [String: AnyObject] else {
                return Observable.empty()
            }
        
            return Observable.just(json as NSDictionary)
            
        }
        
    }
    
    
    
}
