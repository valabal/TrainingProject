//
//  DetailVM.swift
//  Training
//
//  Created by Valbal on 10/17/17.
//  Copyright © 2017 Emveep. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

protocol DetailVMInputs {
    var loadMerchantDetail:PublishSubject<Void>{ get }
    func goToDetailModal()
}

protocol DetailVMOutputs {
    var current_merchant : Variable<Merchant> { get }
    var isLoading: Driver<Bool> { get }
}

protocol DetailVMType {
    var inputs: DetailVMInputs { get  }
    var outputs: DetailVMOutputs { get }
}


class DetailVM : DetailVMType, DetailVMInputs, DetailVMOutputs {

    public let sceneCoordinator: SceneCoordinatorType
    
    public var loadMerchantDetail: PublishSubject<Void>
    public var current_merchant: Variable<Merchant>
    public var isLoading : Driver<Bool>
    
    public var inputs: DetailVMInputs { return self}
    public var outputs: DetailVMOutputs { return self}
    
    private let disposeBag = DisposeBag()
    private let error = PublishSubject<Swift.Error>()

    init(coordinator: SceneCoordinatorType, merchant : Merchant) {
        self.sceneCoordinator = coordinator
        self.current_merchant = Variable<Merchant>(merchant)
    
        loadMerchantDetail = PublishSubject<Void>()
     
        let merchantID = self.current_merchant.value.merchant_id
        
        let Loading = ActivityIndicator()
        isLoading = Loading.asDriver()
        
        let request = loadMerchantDetail.flatMap{ _ in
            return APIManager2.MerchantDetail(merchantID: merchantID!).trackActivity(Loading)
        }.shareReplay(1)
        
        let response = request
            .do(onError: { error in
                self.error.onNext(error)
            }).catchError({ error -> Observable<Merchant> in
                Observable.just(self.current_merchant.value)
            }).shareReplay(1)
        
        response.bind(to: self.current_merchant).disposed(by: disposeBag)
        
    }
    
    func goToDetailModal() {
        
        let merchant = self.current_merchant.value
                
        self.sceneCoordinator.transition(to: Scene.detailModal(merchant), type: .modal(transparent:true))
        
    }
    
    
    
}
