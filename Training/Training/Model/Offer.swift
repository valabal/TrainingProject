//
//  Offer.swift
//  Training
//
//  Created by Valbal on 8/28/17.
//  Copyright © 2017 Emveep. All rights reserved.
//

import UIKit
import EVReflection

class Offer : EVObject{
    
    var offer_id : NSNumber?
    var title: String?
    var currency: String?
    var estimated_saving : NSDictionary?
    var valid_date : Date?
    var valid_until : Date?
    var status : String?
    var date_taken: Date?
    var reference_code : String?
    
    override func propertyMapping() -> [(keyInObject: String?, keyInResource: String?)] {
        return[("offer_id","id")];
    }
    
    func propertyConverters() -> [(String?, ((Any?) -> ())?, (() -> Any?)?)] {
        return [
            (   key: "valid_date"
                , decodeConverter: {
                    if let dateString = $0 as? String{
                        self.valid_date = Date.dateFromString(dateString: dateString, dateFormat: "yyyy-MM-dd'T'HH:mm:ss")
                    }
            }
                , encodeConverter: { return self.valid_date != nil ? Date.stringFromDate(dateInput: self.valid_date!, dateFormat: "yyyy-MM-dd'T'HH:mm:ss"): nil}
            ),(   key: "date_taken"
                , decodeConverter: {
                    if let dateString = $0 as? String{
                        self.date_taken = Date.dateFromString(dateString: dateString, dateFormat: "yyyy-MM-dd'T'HH:mm:ss")
                    }
            }
                , encodeConverter: { return self.date_taken != nil ? Date.stringFromDate(dateInput: self.date_taken!, dateFormat: "yyyy-MM-dd'T'HH:mm:ss"): nil}
            ),
              (   key: "valid_until"
                , decodeConverter: {
                    if let dateString = $0 as? String{
                        self.valid_until = Date.dateFromString(dateString: dateString, dateFormat: "yyyy-MM-dd'T'HH:mm:ss")
                    }
              }
                , encodeConverter: { return self.valid_until != nil ? Date.stringFromDate(dateInput: self.valid_until!, dateFormat: "yyyy-MM-dd'T'HH:mm:ss"): nil}
            )
        ]
    }
    
}


extension Offer:BasicCellObjectProtocol{
    
    func convertToCellObject() -> BasicCellObject{
        
        let cellObj = BasicCellObject.init()
        cellObj.title = self.title
        cellObj.subTitle = self.status
        cellObj.other = self
        
        return cellObj
    }
    
}
