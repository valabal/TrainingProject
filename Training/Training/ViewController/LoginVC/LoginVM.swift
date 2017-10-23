//
//  LoginVM.swift
//  Training
//
//  Created by Fransky on 10/18/17.
//  Copyright © 2017 Emveep. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

protocol LoginVMInputs {
    var email:PublishSubject<String?>{ get }
    var password:PublishSubject<String?>{ get }
    var loginProcess:PublishSubject<Void>{ get }
}

protocol LoginVMOutputs {
    var isLoading: Driver<Bool> { get }
}

protocol LoginVMType {
    var inputs: LoginVMInputs { get  }
    var outputs: LoginVMOutputs { get }
}


class LoginVM : LoginVMType, LoginVMInputs, LoginVMOutputs {
    
    public var email: PublishSubject<String?>
    public var password: PublishSubject<String?>
    public var loginProcess:PublishSubject<Void>
    public var isLoading : Driver<Bool>

    public var inputs: LoginVMInputs { return self}
    public var outputs: LoginVMOutputs { return self}
    
    private let disposeBag = DisposeBag()
    private let error = PublishSubject<Swift.Error>()
    
    public var sceneCoordinator: SceneCoordinatorType!
    
    init(coordinator : SceneCoordinatorType) {
        
        self.sceneCoordinator = coordinator
        
        email = PublishSubject<String?>()
        password = PublishSubject<String?>()
        loginProcess = PublishSubject<Void>()
        
        let Loader = ActivityIndicator()
        isLoading = Loader.asDriver()
        
        let combined = Observable.combineLatest(email,password)
        
        let action = loginProcess.withLatestFrom(combined).share()
        
        let request = action
            .filter{email,password in
                    guard let mail = email, let pass = password else{return false}
                    return mail.characters.count > 0 && pass.characters.count > 0
                    }
            .flatMapLatest{ email,password in
                return APIManager2.Login(email: email!, password: password!)
                    .trackActivity(Loader)
                    .do(onError: { error in
                        self.error.onNext(error)
                    })
                    .catchError({
                        error -> Observable<NSDictionary> in Observable.empty()
                     })
            }.shareReplay(1)
        
        
        //response digunakan untuk mapping hasil dari request.. kalo request ga dimaping apa apa ya di sama denganin aja
        let response = request
        
        response.subscribe(onNext:{ userDic in
            let viewModel = MainVM(coordinator: self.sceneCoordinator)
            self.sceneCoordinator.transition(to: Scene.mainVC(viewModel), type: .push)
        }).disposed(by: disposeBag)
        
    }
    
    
    
}
