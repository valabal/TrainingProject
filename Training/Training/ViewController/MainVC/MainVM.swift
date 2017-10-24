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

enum FeedType:String {
    case all
    case new
}


class MainVM : MainVMType, MainVMInputs, MainVMOutputs {
    
    public let sceneCoordinator: SceneCoordinatorType
    
    public var loadPageTrigger:PublishSubject<Void>
    public var loadNextPageTrigger:PublishSubject<Void>
    public var loadTopTrigger:PublishSubject<Void>
    public var loadNewTrigger:PublishSubject<Void>
    public var loadHUDTrigger:PublishSubject<Void>
    public var viewWillAppearTrigger:PublishSubject<Bool>
    public var refreshDataTrigger:PublishSubject<Void>
    
    public var isLoading: Driver<Bool>
    public var isHUDLoading: Driver<Bool>
    
    public var isComplete: Variable<Bool>
    
    public var contents:Variable<[Merchant]>
    public var topContents:Variable<[Merchant]>
    public var newContents:Variable<[Merchant]>
    
    public var inputs: MainVMInputs { return self}
    public var outputs: MainVMOutputs { return self}
    
    private let disposeBag = DisposeBag()
    
    private var topPageIndex:Int = 1
    private var topNextIndex:Int = 1
    
    private var newPageIndex:Int = 1
    private var newNextIndex:Int = 1
    
    let isTopComplete = Variable<Bool>(false)
    let isNewComplete = Variable<Bool>(false)
    
    private var currentType : FeedType = .all
    
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
        self.refreshDataTrigger = PublishSubject<Void>()
        
        //output
        self.contents = Variable<[Merchant]>([])
        
        self.topContents = Variable<[Merchant]>([])
        self.newContents = Variable<[Merchant]>([])
        
        self.isComplete = Variable<Bool>(false)
        
        let Loading = ActivityIndicator()
        self.isLoading = Loading.asDriver()
        
        let HUDLoading = ActivityIndicator()
        self.isHUDLoading = HUDLoading.asDriver()
        
        //change the contents based on the selected state
        let changeContent = PublishSubject<Observable<[Merchant]>>()
        changeContent.switchLatest().bind(to: self.contents).disposed(by: disposeBag)
        changeContent.onNext(self.topContents.asObservable())
        

        let allReq = self.loadTopTrigger.map{return FeedType.all}
        let newReq = self.loadNewTrigger.map{return FeedType.new}
        
        let mergeTypeReq = Observable.of(allReq,newReq)
            .merge()
            .distinctUntilChanged()
            .do(onNext:
                {[unowned self] type in
                    self.currentType = type
                    switch(type){
                    case .all :
                        changeContent.onNext(self.topContents.asObservable())
                    break
                    case .new :
                        changeContent.onNext(self.newContents.asObservable())
                    break
                    }
             })
            .share()

        
          //isComplete Observer
          let completeObserver = Observable
            .combineLatest(self.isTopComplete.asObservable(),
                           self.isNewComplete.asObservable())
        
          Observable.combineLatest(mergeTypeReq,completeObserver)
            .withLatestFrom(completeObserver)
            .map{[unowned self] isTopComplete,isNewComplete -> Bool in
              switch(self.currentType){
              case .all :
                return isTopComplete
              case .new :
                return isNewComplete
             }}
            .bind(to: self.isComplete)
            .disposed(by: disposeBag)
        
        
          //Empty Page Observer (Each time page empty load the HUD)
           let emptyReqContent = mergeTypeReq
                .flatMap{[unowned self] type -> Observable<[Merchant]> in
                    if type == .all {
                        return self.topContents.asObservable()
                    }
                    else{
                        return self.newContents.asObservable()
                    }
                 }
                .filter{$0.isEmpty}
            
           emptyReqContent.map{_ in return Void()}.bind(to: self.loadHUDTrigger).disposed(by: disposeBag)
        
        //refresh data setiap kali ketriger (lewat hud trigger)
          self.refreshDataTrigger.bind(to: self.loadHUDTrigger).disposed(by: disposeBag)
        
        //refresh data untuk button2 event lainnya (lewat hud trigger)
          self.refreshDataTrigger.asObservable().sample(mergeTypeReq).bind(to: self.loadHUDTrigger).disposed(by: disposeBag)

          let loadRequest = self.loadPageTrigger.map{return "reload"}
          let nextRequest = self.loadNextPageTrigger.map{return "next"}
        
          let merge = Observable.of(loadRequest,nextRequest).merge()
        
          let mergerequest = Observable.combineLatest(self.isLoading.asObservable(),merge){load,action in return(load,action)}
                .sample(merge)
                .map{($0.0,$0.1,Loading)}
            
          let hudTriggerRequest = self.loadHUDTrigger.map{return "reload"}
            
          let hudRequest =  Observable.combineLatest(self.isHUDLoading.asObservable(),hudTriggerRequest){load,action in return(load,action)}
                .sample(hudTriggerRequest)
                .map{($0.0,$0.1,HUDLoading)}
        
          let triggerReq = Observable.of(mergerequest,hudRequest).merge()
            .do(onNext: { [unowned self] _,action,_ in
                var index = 1
                if(self.currentType == .all){
                    if(action == "next"){
                        index = self.topNextIndex
                    }
                    self.topPageIndex = index
                }
                else{
                    if(action == "next"){
                        index = self.newNextIndex
                    }
                    self.newPageIndex = index
                }
            })
            
          let request = triggerReq
                .flatMap{[unowned self] isLoading,_,Loader  -> Observable<(MerchantResponse,FeedType)> in
                    
                    let type = self.currentType
                    
                    if(isLoading){
                        return Observable.empty()
                    }
                    
                    let request = ListMerchantRequest()
                    request.search_type = type.rawValue;
                    request.order_alphabetically = true
                    
                    if(type == .all){
                        request.page = NSNumber(value: self.topPageIndex)
                    }
                    else{
                        request.page = NSNumber(value: self.newPageIndex)
                    }
                    
                    return APIManager2.MerchantList(request: request)
                        .trackActivity(Loader)
                        .do(onError: { _error in
                            self.error.onNext(_error)
                        })
                        .map{return ($0,type)}
                        .catchError({ error -> Observable<(MerchantResponse,FeedType)> in
                            Observable.empty()
                        })
                    
                }.shareReplay(1)
            
            
            let response = request.map{
                [weak self] merchantResponse,type -> ([Merchant],FeedType) in
                
                if let pagination = merchantResponse.pagination,let nextPages = pagination["next_page"] as? NSNumber{
                    
                    if(type == .all){
                        self?.topNextIndex = nextPages.intValue
                        self?.isTopComplete.value = false
                    }
                    else{
                        self?.newNextIndex = nextPages.intValue
                        self?.isNewComplete.value = false
                    }
                }
                else{
                    
                    if(type == .all){
                        self?.isTopComplete.value = true
                    }
                    else{
                        self?.isNewComplete.value = true
                    }
                    
                }
                
                return (merchantResponse.result,type)
                
                }.shareReplay(1)
            
            
            Observable.combineLatest(request,response,topContents.asObservable()){reqTupple,respTuppe,array in
                return (respTuppe.1,respTuppe.0,array)
                }
                .sample(request)
                .filter{type,_,_ in type == .all}
                .map{
                    _,response,contents in
                    return self.topPageIndex == 1 ? response : contents + response
                }
                .bind(to: topContents)
                .addDisposableTo(disposeBag)
            
            
            Observable.combineLatest(request,response,newContents.asObservable()){reqTupple,respTuppe,array in
                return (respTuppe.1,respTuppe.0,array)
                }
                .sample(request)
                .filter{type,_,_ in type == .new}
                .map{
                    _,response,contents in
                    return self.newPageIndex == 1 ? response : contents + response
                }
                .bind(to: newContents)
                .addDisposableTo(disposeBag)
            
        }
        
        func refresh() {
            self.inputs.loadPageTrigger.onNext()
        }
        
        func tapped(row: NSInteger) {
            
            //ceritanya setiap dia mencet tombol info maka otomatis bakal refresh ketika tombol requested..
            let merchant = self.contents.value[row]
            let detailVM = DetailVM(coordinator: self.sceneCoordinator, merchant: merchant)
            
            self.viewWillAppearTrigger.withLatestFrom(detailVM.detailModalTrigger).map{return $0.merchant_id}
                .debug().subscribe(onNext:{
                    [unowned self] _ in
                    self.refreshDataTrigger.onNext()
                }).disposed(by: detailVM.disposeBag)
            
            let scene = Scene.detailVC(detailVM)
            sceneCoordinator.transition(to: scene, type: .push)
            
        }
        
}
