//
//  DateHelper.swift
//  EmveepApp
//
//  Created by Valbal on 12/6/16.
//  Copyright © 2016 Emveep. All rights reserved.
//

import UIKit

extension Date{

    static func dateFromString(dateString:String , dateFormat:String)->Date{
    
        if dateString.isEmpty {
           return Date()
        }
        
        let formater = DateFormatter()
        formater.dateFormat = dateFormat
        
        return formater.date(from: dateString)!
        
    }
    
    static func stringFromDate(dateInput:Date? , dateFormat:String)->String{
        
        var date = dateInput
        
        if date == nil {
          date = Date()
        }
        
        let formater = DateFormatter()
        formater.dateFormat = dateFormat
        
        return formater.string(from: date!)
        
    }
    
    
}
