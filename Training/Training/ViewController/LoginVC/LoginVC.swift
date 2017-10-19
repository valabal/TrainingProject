//
//  LoginVC.swift
//  Training
//
//  Created by Valbal on 8/23/17.
//  Copyright © 2017 Emveep. All rights reserved.
//

import UIKit
import RxSwift


class LoginVC : UIViewController{

    @IBOutlet var userTF : UITextField?
    @IBOutlet var passTF : UITextField?
    @IBOutlet var buttonLogin : UIButton?
    
    var viewModel : LoginVM!
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        self.bindingViews()
    }

    func bindingViews(){
       
        //input
        self.userTF?.rx.text
            .bind(to: self.viewModel.email)
            .disposed(by: disposeBag)
        
        self.passTF?.rx.text
            .bind(to: self.viewModel.password).disposed(by: disposeBag)
        
        self.buttonLogin?.rx.tap
            .bind(to: self.viewModel.inputs.loginProcess)
            .disposed(by: disposeBag)
        
        //output
        self.viewModel.isLoading.asObservable().subscribe(onNext:{isLoading in
            if(isLoading){
              FunctionHelper.showHUD()
            }
            else{
              FunctionHelper.hideHUD()
            }
            
        }).disposed(by: disposeBag)
    
    }
    
    

    

}
