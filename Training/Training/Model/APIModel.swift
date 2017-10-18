//
//  APIModel.swift
//  Training
//
//  Created by Valbal on 8/22/17.
//  Copyright © 2017 Emveep. All rights reserved.
//

import Foundation
import EVReflection

class ListMerchantRequest : EVObject{
    
    var search_type: String?
    var search_key: String?
    var latitude : NSNumber?
    var longitude : NSNumber?
    var type : Array<String>?
    var sub_type : Array<String>?
    var location : Array<String>?
    var price_rating : Array<String>?
    var additional_features : Array<String>?
    var page : NSNumber?
    var per_page: NSNumber = 8
    var order_alphabetically: NSNumber?
        
    
}





