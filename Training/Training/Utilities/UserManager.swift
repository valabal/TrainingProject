//
//  UserManager.swift
//  EmveepApp
//
//  Created by Valbal on 12/6/16.
//  Copyright © 2016 Emveep. All rights reserved.
//

import UIKit
import GoogleSignIn

class UserManager: NSObject {
    
    static func SaveUserDefault(key :String, value : AnyObject?){
        let defaults = UserDefaults.standard
        defaults.set(value, forKey: key)
        defaults.synchronize()
    }
    
    static func GetUserDefault(key : String) -> AnyObject?{
        let defaults = UserDefaults.standard
        
        if let value = defaults.value(forKey: key)
        {return value as AnyObject?}
        
        return nil
        
    }
    
    static func resetDefaults(){
        let domain = Bundle.main.bundleIdentifier!
        let defaults = UserDefaults.standard
        
        defaults.removePersistentDomain(forName: domain)
        defaults.synchronize()

    }
    
    static func GetCurrentVersion() -> String{
        
        let versionString : String = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
        let bundleVersion : String = Bundle.main.infoDictionary?["CFBundleVersion"] as! String
        
        return versionString+"."+bundleVersion
        
    }
    
    static func accessToken() -> String? {
        if let token = self.GetUserDefault(key:"Emveep.AccountToken")
        {return token as? String}
        
        return nil
    }
    
    static func saveAccessToken(token : NSString?){
        self.SaveUserDefault(key: "Emveep.AccountToken" , value: token)
    }
    
    
    static func saveCurrentCoordinate(dic : NSDictionary?){
       self.SaveUserDefault(key: "Emveep.coordinateLoc", value: dic)
    }
    
    static func getCurrentCoordinate() -> NSDictionary? {
        
        if let token = self.GetUserDefault(key:"Emveep.coordinateLoc")
        {return token as? NSDictionary}
        
        return nil
    
    }
    
}
