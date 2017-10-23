//
//  MainVM.swift
//  Training
//
//  Created by Valbal on 10/16/17.
//  Copyright © 2017 Emveep. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

protocol MainVMInputs {
 
    var loadPageTrigger:PublishSubject<Void> { get }
    var loadNextPageTrigger:PublishSubject<Void> { get }
    var loadHUDTrigger:PublishSubject<Void>{ get }
    var viewWillAppearTrigger:PublishSubject<Bool>{ get }

    var loadTopTrigger:PublishSubject<Void> { get }
    var loadNewTrigger:PublishSubject<Void> { get }

    func refresh()
    func tapped(row:NSInteger)

}

protocol MainVMOutputs {
    var isLoading: Driver<Bool> { get }
    var isHUDLoading: Driver<Bool> { get }
    var isComplete: Variable<Bool> { get }
    var contents:Variable<[Merchant]> { get }
}

protocol MainVMType {
    var inputs: MainVMInputs { get  }
    var outputs: MainVMOutputs { get }
}


class MainVM : MainVMType, MainVMInputs, MainVMOutputs {
    
    public let sceneCoordinator: SceneCoordinatorType
    
    public var loadPageTrigger:PublishSubject<Void>
    public var loadNextPageTrigger:PublishSubject<Void>
    public var loadTopTrigger:PublishSubject<Void>
    public var loadNewTrigger:PublishSubject<Void>
    public var loadHUDTrigger:PublishSubject<Void>
    public var viewWillAppearTrigger:PublishSubject<Bool>
    
    public var isLoading: Driver<Bool>
    public var isHUDLoading: Driver<Bool>
    
    public var isComplete: Variable<Bool>
    public var contents:Variable<[Merchant]>
    
    public var inputs: MainVMInputs { return self}
    public var outputs: MainVMOutputs { return self}
    
    private let disposeBag = DisposeBag()
    private var pageIndex:Int = 1
    private var nextIndex:Int = 1
    private let error = PublishSubject<Swift.Error>()
    
    init(coordinator: SceneCoordinatorType) {
        
        self.sceneCoordinator = coordinator
        
        //input
        self.loadPageTrigger = PublishSubject<Void>()
        self.loadNextPageTrigger = PublishSubject<Void>()
        
        self.loadNewTrigger = PublishSubject<Void>()
        self.loadTopTrigger = PublishSubject<Void>()
        
        self.loadHUDTrigger = PublishSubject<Void>()
        self.viewWillAppearTrigger = PublishSubject<Bool>()
        
        //output
        self.contents = Variable<[Merchant]>([])
        self.isComplete = Variable<Bool>(false)
        
        let Loading = ActivityIndicator()
        self.isLoading = Loading.asDriver()
        
        let HUDLoading = ActivityIndicator()
        self.isHUDLoading = HUDLoading.asDriver()
        
        
        //binding process
        let loadRequest = self.loadPageTrigger.do(onNext: {
            self.pageIndex = 1
        })
        
        let nextRequest = self.loadNextPageTrigger.do(onNext: {
            self.pageIndex = self.nextIndex
        })
        
        let merge = Observable.of(loadRequest,nextRequest).merge()
        
        let mergerequest = self.isLoading.asObservable()
            .sample(merge).map{($0,Loading)}
        
        let hudTriggerRequest = self.loadHUDTrigger.do(onNext: {
            self.pageIndex = 1
        })
        
        let hudRequest = self.isHUDLoading.asObservable()
            .sample(hudTriggerRequest)
            .map{($0,HUDLoading)}
        
        let allReq = self.loadTopTrigger.map{return "all"}
        let newReq = self.loadNewTrigger.map{return "new"}
        let mergeTypeReq = Observable.of(allReq,newReq).merge()
            .startWith("all")
            .distinctUntilChanged()
            .do(onNext: {type in self.pageIndex = 1})
        
        //tiap kali all/new req kepencet dia bakal kerefresh+reset data pakai HUD
        let hudAndType = Observable.combineLatest(hudRequest,mergeTypeReq).map{(tupple,string) in return tupple}
        
        let tiggerReq = Observable.of(mergerequest,hudAndType).merge()
        let combinedReq = Observable.combineLatest(mergeTypeReq,tiggerReq)
        
        let request = tiggerReq.withLatestFrom(combinedReq)
            .flatMap{(type,tupple)  -> Observable<MerchantResponse> in
                
                let isLoading = tupple.0
                let Loader = tupple.1
                
                if(isLoading){
                    return Observable.empty()
                }
                
                let request = ListMerchantRequest()
                request.search_type = type;
                request.order_alphabetically = true
                request.page = NSNumber(value: self.pageIndex)
                
                return APIManager2.MerchantList(request: request)
                    .trackActivity(Loader)
                    .do(onError: { _error in
                        self.error.onNext(_error)
                    })
                    .catchError({ error -> Observable<MerchantResponse> in
                        Observable.empty()
                    })
            
            }.shareReplay(1)
        
        
        let response = request.map{
            [weak self] merchantResponse -> [Merchant] in
            
            if let pagination = merchantResponse.pagination,let nextPages = pagination["next_page"] as? NSNumber{
                self?.nextIndex = nextPages.intValue
                self?.isComplete.value = false;
            }
            else{
                self?.isComplete.value = true;
            }
            
            return merchantResponse.result
        
        }.shareReplay(1)
        
        
        //combine data when get more data by paging
        Observable
            .combineLatest(request, response, contents.asObservable())
            .sample(request)
            .map{
                _,response,contents in
                return self.pageIndex == 1 ? response : contents + response
            }
            .bind(to: contents)
            .addDisposableTo(disposeBag)
        
    }
    
    func refresh() {
        self.inputs.loadPageTrigger.onNext()
    }
    
    func tapped(row: NSInteger) {
        
        //ceritanya setiap dia mencet tombol info maka otomatis bakal refresh home..
        let merchant = self.contents.value[row]
        let detailVM = DetailVM(coordinator: self.sceneCoordinator, merchant: merchant)
        
        self.viewWillAppearTrigger.withLatestFrom(detailVM.detailModalTrigger)
            .take(1).subscribe(onNext:{
              [unowned self] _ in
                self.loadHUDTrigger.onNext()
            }).disposed(by: disposeBag)
        
        let scene = Scene.detailVC(detailVM)
        sceneCoordinator.transition(to: scene, type: .push)
        
    }
    
}
