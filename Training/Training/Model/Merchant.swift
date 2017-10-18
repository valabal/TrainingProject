//
//  Merchant.swift
//  Training
//
//  Created by Valbal on 8/23/17.
//  Copyright © 2017 Emveep. All rights reserved.
//

import UIKit
import EVReflection
import CoreLocation

enum ProductType{
    case NORMAL
    case MONTHLY
}

class Merchant : EVObject{

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
    var place : Place?
    var merchant_detail : MerchantDetail?
    var products : NSDictionary?

    
    override func propertyMapping() -> [(keyInObject: String?, keyInResource: String?)] {
        return[("merchant_id","id"),("descriptions","description"),("merchant_detail","detail")];
    }
    
    func getProductType(state:ProductType)->[NSDictionary]?{
       
        switch state {
        case .NORMAL:
            return self.products?["offers"] as? [NSDictionary]
        default:
            return self.products?["monthly_special"] as? [NSDictionary]
        }
    
    }
    
    
}


extension Merchant:BasicCellObjectProtocol{

    func convertToCellObject() -> BasicCellObject{
        
        let cellObj = BasicCellObject.init()
        cellObj.title = self.name
        cellObj.subTitle = self.type
        cellObj.descString = self.place?.getCurrentDistance()
        cellObj.imageURL = self.logo_url
        cellObj.other = self
        
        return cellObj
    }
    
}


class Place : EVObject{

    var id : NSNumber?
    var coordinate : NSDictionary?
    var address : String?
    var jarak : String?
    var area : String?
    
    
    func getCurrentDistance() -> String?{
    
        if let dist = self.jarak {
            return dist
        }
        
        if var currentCoordinate = UserManager.getCurrentCoordinate(), var coordinate = self.coordinate{
            
            currentCoordinate = FunctionHelper.unNullDictionary(dict: currentCoordinate)
            coordinate = FunctionHelper.unNullDictionary(dict: coordinate)
            
            let destlat = (coordinate["lat"] as? NSString)?.doubleValue
            let destlong = (coordinate["lng"] as? NSString)?.doubleValue
            
            guard let lat = currentCoordinate["lat"] as? NSNumber,let long = currentCoordinate["lng"] as? NSNumber, let dlat = destlat, let dlong = destlong else{
                 return nil
             }
            
            let currentLoc = CLLocation(latitude: lat.doubleValue, longitude: long.doubleValue)
            let restaurantLoc = CLLocation(latitude: dlat, longitude: dlong)
            let meters = restaurantLoc.distance(from: currentLoc)
            let km = meters/1000.0
            
            let dist = NSNumber(value: km)
            self.jarak = "\(dist.abbreviateNumber()) km"
            
            return self.jarak
            
        }
        
        return nil
    
    }

}


class MerchantDetail : EVObject{
   
    var descriptions: String?
    var images : [String]?
    var additional_details : NSDictionary?
    var additional_features : [NSDictionary]?
    var open_hour : String?
    var close_hour : String?
    var price_rating : String?

    override func propertyMapping() -> [(keyInObject: String?, keyInResource: String?)] {
        return[("descriptions","description")];
    }
    
}




