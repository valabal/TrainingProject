//
//  MainVCViewCell.swift
//  Training
//
//  Created by Valbal on 10/26/17.
//  Copyright © 2017 Emveep. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class MainVCCell : BasicViewCell{
    
    @IBOutlet var starImage : UIImageView?
    @IBOutlet var favButton : UIButton?
    
    var refreshMerchant: PublishSubject<Merchant>!
    
    deinit {
        print("VIEW CELL DEINIT")
    }
    
    override func fillCellWithObject(object:BasicCellObject){
        super.fillCellWithObject(object: object)
        
        if let merchant = object.other as? Merchant{
            
            var favImgae = UIImage(named:"favorit_grey")
            
            if let favorite = merchant.is_favorite?.boolValue , favorite == true {
                favImgae = UIImage(named:"favorit")
            }
            
            starImage?.image = favImgae
        
            refreshMerchant = PublishSubject<Merchant>()
        
            let request = self.favButton?.rx.tap.asObservable().throttle(0.4, scheduler:MainScheduler.instance).flatMap{_ -> Observable<NSDictionary> in
                return APIManager2.MerchantFavorite(merchantID: merchant.merchant_id!, isFavorite: !merchant.is_favorite!.boolValue)
                    .catchError({error -> Observable<NSDictionary> in
                        return Observable.empty()
                    })
            }
            
            request?.map{_ -> Merchant in
                merchant.is_favorite = NSNumber(value:!merchant.is_favorite!.boolValue)
                return merchant}.bind(to: refreshMerchant).disposed(by: disposeBag)
        }
        
    }
    
}






