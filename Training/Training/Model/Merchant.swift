//
//  Merchant.swift
//  Training
//
//  Created by Valbal on 8/23/17.
//  Copyright © 2017 Emveep. All rights reserved.
//

import UIKit
import EVReflection

class Merchant : NSObject,EVReflectable{

    var descriptions: String?
    var email: String?
    var web : String?
    var location : String?
    var merchant_id : NSNumber?
    var is_favorite : NSNumber?
    var is_locked : NSNumber?
    var is_featured : NSNumber?
    var location_id : NSNumber?
    var logo_url : String?
    var name : String?
    var type : String?
    var subType : [String]?
    var price_rating : String?
    var offer_exclusion : String?
    var place : NSDictionary?
    var merchant_detail : NSDictionary?
    var products : NSDictionary?

    
    func propertyMapping() -> [(keyInObject: String?, keyInResource: String?)] {
        return[("merchant_id","id"),("descriptions","description")];
    }
    
    func convertToCellObject() -> BasicCellObject{
       
        let cellObj = BasicCellObject.init()
        cellObj.title = self.name
        cellObj.subTitle = self.type
        cellObj.descString = self.descriptions
        cellObj.imageURL = self.logo_url
        cellObj.other = self
        
        return cellObj
        
    }
    
    
}

