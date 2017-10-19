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
    
    override func skipPropertyValue(_ value: Any, key: String) -> Bool {
        if let value = value as? String, value.characters.count == 0 || value == "null" {
            return true
        } else if let value = value as? NSArray, value.count == 0 {
            return true
        } else if value is NSNull {
            return true
        }
        return false
    }
    
}





