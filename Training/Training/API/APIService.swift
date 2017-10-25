//
//  APIService.swift
//  Training
//
//  Created by Valbal on 10/17/17.
//  Copyright © 2017 Emveep. All rights reserved.
//

import Foundation

import Moya

let Provider = RxMoyaProvider<APIService>(plugins: [EmveepPlugin(),CurlPlugin()])

enum API_ENVIRONTMENT{
    case APIARY
    case STAGING
    case PRODUCTION
}

let CURRENT_ENV : API_ENVIRONTMENT = API_ENVIRONTMENT.PRODUCTION

var ROOT_URL : String {
    
    switch CURRENT_ENV {
    case .APIARY :
        return "https://private-1aa5a-alacarteapiary.apiary-mock.com/"
    case .STAGING :
        return "http://alacarte.stagingapps.net/api/v1/"
    case .PRODUCTION :
        return "http://clubalacarte.com/api/v1/"
    }
    
}

private extension String {
    var urlEscaped: String {
        return addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
    }
    
    var utf8Encoded: Data {
        return data(using: .utf8)!
    }
}

enum APIService {
    case login(email:String,password:String)
    case merchantList(request:ListMerchantRequest)
    case merchantDetail(merchantID:NSNumber)
}


extension APIService: TargetType {
    
    var baseURL: URL { return URL(string: ROOT_URL)!}
    
    var path: String {
        switch self {
        case .login:
            return "auth/login/"
        case .merchantList:
            return "merchants/search"
        case .merchantDetail(let merchantID):
            return "merchants/detail/\(merchantID)"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .login, .merchantList :
            return .post
        case .merchantDetail :
            return .get
        }
    }
    
    var task: Task {
        return .request
    }
    
    var parameters:[String:Any]?{
        switch self {
        case .login(let email, let password):
            return ["email":email,"password":password]
        case .merchantList(let request):
            let dic = request.toDictionary()
            return dic as? [String:Any]
        case .merchantDetail :
            return nil
        }
    }
    
    var parameterEncoding: ParameterEncoding {return URLEncoding.default}
    
    var sampleData: Data {
        return "Test Data".utf8Encoded
    }
    

}

