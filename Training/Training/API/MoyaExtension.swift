//
//  MoyaExtension.swift
//  EmveepApp
//
//  Created by Fransky on 9/27/17.
//  Copyright © 2017 Emveep. All rights reserved.
//

import Foundation
import Moya
import RxSwift

extension MoyaProvider {
    
    
    func requestJSON(_ target: Target, completion:  @escaping (AnyObject?, MoyaError?) -> Void ) -> Cancellable {
        return self.requestJSON(target, queue: nil, progress: nil, completion: completion);
    }
    
    func requestJSON(_ target: Target, queue: DispatchQueue? , progress: Moya.ProgressBlock?, completion:  @escaping (AnyObject?, MoyaError?) -> Void ) -> Cancellable {
        
        return self.request(target, queue: queue, progress: progress){ (result) in
            
            switch result {
            case let .success(moyaResponse):
                
                do {
                    let data = try moyaResponse.mapJSON()
                    do{
                        try moyaResponse.filterSuccessfulStatusCodes()
                        return completion(data as AnyObject?,nil)
                    }
                    catch {
                        // show an error to your user (misalnya error 500 ntar server ngeluarin message tertentu
                        /*
                        if let data = data as? [String:Any]{
                            AlertHelper.showAlert(title: "Error", message: data["messages"] as! String?)
                        }
                         */
                        
                        return completion(nil,MoyaError.statusCode(moyaResponse))
                    }
                }
                catch {
                    return completion(nil,MoyaError.jsonMapping(moyaResponse))
                }
                
            case let .failure(error):
                return completion(nil,error)
            }
            
        }
    }
    
}


extension RxMoyaProvider{

    /// Designated request-making method.
    open func requestJSON(_ token: Target) -> Observable<AnyObject> {
        
        // Creates an observable that starts a request each time it's subscribed to.
        return Observable.create { observer in
            let cancellableToken = self.requestJSON(token) { result,error in
                
                if let JSON = result {
                   observer.onNext(JSON)
                   observer.onCompleted()
                }
                else if let err = error {
                   observer.onError(err)
                }
                
            }
            
            return Disposables.create {
                cancellableToken.cancel()
            }
    
        }

    }


}

