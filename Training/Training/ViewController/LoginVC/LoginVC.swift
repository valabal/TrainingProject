//
//  LoginVC.swift
//  Training
//
//  Created by Valbal on 8/23/17.
//  Copyright © 2017 Emveep. All rights reserved.
//

import UIKit


class LoginVC : UIViewController{

    @IBOutlet var userTF : UITextField?
    @IBOutlet var passTF : UITextField?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    @IBAction func loginButtonPressed(){
    
      let username = userTF?.text  != nil ? userTF?.text : ""
      let pass = passTF?.text != nil ? passTF?.text : ""
    
      FunctionHelper.showHUD()
        
        let param = ["email":username!,"password":pass!]
        
        APIManager.Login(authDic: param as NSDictionary
         , callback: {(result : NSDictionary?) in
            FunctionHelper.hideHUD()
            
            let mainSB = UIStoryboard.init(name: "MainSB", bundle: Bundle.main)
            let viewController = mainSB.instantiateViewController(withIdentifier: "MainVC")
            
            self.navigationController?.pushViewController(viewController, animated: true)
         }
        , failure: {(error : Error?) in
            FunctionHelper.hideHUD()
        }
        )
    
    }
    

}
