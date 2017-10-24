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
        
        //output
        self.contents = Variable<[Merchant]>([])
        
        self.topContents = Variable<[Merchant]>([])
        self.newContents = Variable<[Merchant]>([])
        
        self.isComplete = Variable<Bool>(false)
        
        let Loading = ActivityIndicator()
        self.isLoading = Loading.asDriver()
        
        let HUDLoading = ActivityIndicator()
        self.isHUDLoading = HUDLoading.asDriver()
        
        
        let changeContent = PublishSubject<Observable<[Merchant]>>()
        changeContent.switchLatest().bind(to: self.contents).disposed(by: disposeBag)
        changeContent.onNext(self.topContents.asObservable())
        
        let completeObserver = Observable
            .combineLatest(self.isTopComplete.asObservable(),
                           self.isNewComplete.asObservable())
        
        let allReq = self.loadTopTrigger.map{return FeedType.all}
            .do(onNext:
                {[unowned self] type in
                    self.currentType = type
                    self.topPageIndex = 1
                    changeContent.onNext(self.topContents.asObservable())
            })
        
        let newReq = self.loadNewTrigger.map{return FeedType.new}
            .do(onNext:
                {[unowned self] type in
                    self.currentType = type
                    self.newPageIndex = 1
                    changeContent.onNext(self.newContents.asObservable())
            })
        
        let mergeTypeReq = Observable.of(allReq,newReq)
            .merge()
            .distinctUntilChanged()
            .share()
        
        //gabungkan mergeType dengan complete Observer
        Observable.combineLatest(mergeTypeReq,completeObserver).withLatestFrom(completeObserver).map{[unowned self] isTopComplete,isNewComplete -> Bool in
            
            switch(self.currentType){
            case .all :
                return isTopComplete
            case .new :
                return isNewComplete
            }}
            .bind(to: self.isComplete).disposed(by: disposeBag)
            
        let emptyReqContent = mergeTypeReq
                .flatMap{[unowned self] type -> Observable<[Merchant]> in
                    if type == .all {
                        return self.topContents.asObservable()
                    }
                    else{
                        return self.newContents.asObservable()
                    }
                }.filter{$0.isEmpty}
            
        emptyReqContent.map{_ in return Void()}.bind(to: self.loadHUDTrigger).disposed(by: disposeBag)
            
        let loadRequest = self.loadPageTrigger
                .do(onNext: { [unowned self] in
                    if(self.currentType == .all){
                        self.topPageIndex = 1
                    }
                    else{
                        self.newPageIndex = 1
                    }
                })
            
        let nextRequest = self.loadNextPageTrigger
                .do(onNext: { [unowned self] in
                    if(self.currentType == .all){
                        self.topPageIndex = self.topNextIndex
                    }
                    else{
                        self.newPageIndex = self.newNextIndex
                    }
                })
            
        let merge = Observable.of(loadRequest,nextRequest).merge()
        
        let mergerequest = self.isLoading.asObservable()
                .sample(merge)
                .map{($0,Loading)}
            
        let hudTriggerRequest = self.loadHUDTrigger
                .do(onNext: { [unowned self] in
                    if(self.currentType == .all){
                        self.topPageIndex = 1
                    }
                    else{
                        self.newPageIndex = 1
                    }
                })
            
        let hudRequest = self.isHUDLoading.asObservable()
                .sample(hudTriggerRequest)
                .map{($0,HUDLoading)}
            
            
        let triggerReq = Observable.of(mergerequest,hudRequest).merge()
            
        let request = triggerReq.withLatestFrom(triggerReq)
                .flatMap{[unowned self] isLoading,Loader  -> Observable<(MerchantResponse,FeedType)> in
                    
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
                }.sample(request)
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
