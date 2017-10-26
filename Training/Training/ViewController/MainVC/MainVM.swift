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

enum FeedType:String {
    case all
    case new
    
    static let allValues = [all,new]
}


enum RefreshPolicy{
    case allData
    case partial
}


protocol MainVMInputs {
    
    var loadPageTrigger:PublishSubject<Void> { get }
    var loadNextPageTrigger:PublishSubject<Void> { get }
   
    var viewWillAppearTrigger:PublishSubject<Bool>{ get }
    var loadTopTrigger:PublishSubject<Void> { get }
    var loadNewTrigger:PublishSubject<Void> { get }
    
    func refresh(_ refreshPolicy:RefreshPolicy)
    func tapped(row:NSInteger)
    
}

protocol MainVMOutputs {
    var isLoading: Driver<Bool> { get }
    var isComplete: Variable<Bool> { get }
    var contents:Variable<[Merchant]> { get }
}

protocol MainVMType {
    var inputs: MainVMInputs { get  }
    var outputs: MainVMOutputs { get }
}



class ContentModel{
    var content:Variable<[Merchant]> = Variable<[Merchant]>([])
    var pageIndex:Int = 1
    var nextIndex:Int = 1
    let isComplete = Variable<Bool>(false)
}


class MainVM : MainVMType, MainVMInputs, MainVMOutputs {
    
    public let sceneCoordinator: SceneCoordinatorType
    
    public var inputs: MainVMInputs { return self}
    public var outputs: MainVMOutputs { return self}
    
    //input
    public var loadPageTrigger:PublishSubject<Void>
    public var loadNextPageTrigger:PublishSubject<Void>
    public var loadTopTrigger:PublishSubject<Void>
    public var loadNewTrigger:PublishSubject<Void>
    public var viewWillAppearTrigger:PublishSubject<Bool>

    //output
    public var isLoading: Driver<Bool>
    public var isComplete: Variable<Bool>
    public var contents:Variable<[Merchant]>
    
    //local subject
    public var loadHUDTrigger:PublishSubject<Void>
    public var refreshDataTrigger:PublishSubject<RefreshPolicy>
    
    private var contentArray:[FeedType:ContentModel]
    
    
    private var currentType : FeedType = .all
    
    private let disposeBag = DisposeBag()
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
        self.refreshDataTrigger = PublishSubject<RefreshPolicy>()
        
        //output
        self.contents = Variable<[Merchant]>([])
 
        self.contentArray = [FeedType:ContentModel]()
        
        for feedType in FeedType.allValues{
            self.contentArray[feedType] = ContentModel()
        }
        
        self.isComplete = Variable<Bool>(false)
        
        let Loading = ActivityIndicator()
        self.isLoading = Loading.asDriver()
        
        let HUDLoading = ActivityIndicator.getHUDLoader(disposeBag: disposeBag)
        
        //change the contents based on the selected state
        let changeContent = PublishSubject<Observable<[Merchant]>>()
        changeContent.switchLatest().bind(to: self.contents).disposed(by: disposeBag)

        let topContent = self.contentArray[.all]!.content
        changeContent.onNext(topContent.asObservable())
        
        let allReq = self.loadTopTrigger.map{return FeedType.all}
        let newReq = self.loadNewTrigger.map{return FeedType.new}
        
        let mergeTypeReq = Observable.of(allReq,newReq)
            .merge()
            .distinctUntilChanged()
            .do(onNext:
                {[unowned self] type in
                    self.currentType = type
                    let content = self.contentArray[type]!.content
                    changeContent.onNext(content.asObservable())
                }
             )
            .share()

        
        //isComplete Observer
        
        var completeArray : [Observable<(Bool,FeedType)>] = []
        
        for types in self.contentArray.keys {
            let contentModel = self.contentArray[types]
            completeArray.append(contentModel!.isComplete.asObservable().map{($0,types)})
        }
        
        
        let completeObserver = Observable.combineLatest(completeArray)
        
          Observable.combineLatest(mergeTypeReq,completeObserver)
            .withLatestFrom(completeObserver)
            .map{[unowned self] complet -> Bool in
          
            let isComplt = complet.filter{_,type in return type == self.currentType}.map{bool,_ in return bool}.first
            if let complete = isComplt {
               return complete
            }
                
            return true
                
            }.bind(to: self.isComplete)
            .disposed(by: disposeBag)
        
        
          //Empty Page Observer (Each time page empty load the HUD)
           let emptyReqContent = mergeTypeReq
                .flatMap{[unowned self] type -> Observable<[Merchant]> in
                    let content = self.contentArray[type]!.content
                    return content.asObservable()
                 }
                .filter{$0.isEmpty}
            
          emptyReqContent.map{_ in return Void()}.bind(to: self.loadHUDTrigger).disposed(by: disposeBag)
        
        //refresh data setiap kali ketriger (lewat hud trigger)
        self.refreshDataTrigger.filter{$0 == .allData}
            .map{_ in Void()}
            .bind(to: self.loadHUDTrigger).disposed(by: disposeBag)
        
        //refresh data untuk button2 event lainnya (lewat hud trigger)
          self.refreshDataTrigger.asObservable().sample(mergeTypeReq)
            .map{_ in Void()}
            .bind(to: self.loadHUDTrigger).disposed(by: disposeBag)

          let loadRequest = self.loadPageTrigger.map{return "reload"}
          let nextRequest = self.loadNextPageTrigger.map{return "next"}
        
          let merge = Observable.of(loadRequest,nextRequest).merge()
        
          let mergerequest = Observable.combineLatest(self.isLoading.asObservable(),merge){load,action in return(load,action)}
                .sample(merge)
                .map{($0.0,$0.1,Loading)}
            
          let hudTriggerRequest = self.loadHUDTrigger.map{return "reload"}
            
          let hudRequest =  Observable.combineLatest(HUDLoading.asObservable(),hudTriggerRequest){load,action in return(load,action)}
                .sample(hudTriggerRequest)
                .map{($0.0,$0.1,HUDLoading)}
        
          let triggerReq = Observable.of(mergerequest,hudRequest).merge()
            .do(onNext: { [unowned self] _,action,_ in
                var index = 1
                let model = self.contentArray[self.currentType]
                
                if(action == "next"){
                    index = model!.nextIndex
                }
                model?.pageIndex = index
                
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
                    
                    let model = self.contentArray[type]
                    
                    request.page = NSNumber(value:model!.pageIndex)
                    
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
                    
                    if let model = self?.contentArray[type]{
                       model.nextIndex = nextPages.intValue
                       model.isComplete.value = false
                    }
                }
                else{
                    
                    if let model = self?.contentArray[type]{
                        model.isComplete.value = true
                    }
                }
                
                return (merchantResponse.result,type)
                
                }.shareReplay(1)
            
        
           //binding the results
        
           for types in self.contentArray.keys {
     
              let contentModel = self.contentArray[types]
            
              Observable.combineLatest(request,response,contentModel!.content.asObservable()){reqTupple,respTuppe,array in
                return (respTuppe.1,respTuppe.0,array)}
                .sample(request)
                .filter{type,_,_ in type == types}
                .map{[unowned self]
                    type,response,contents in
                    let model = self.contentArray[type]
                    return model!.pageIndex == 1 ? response : contents + response
                }
                .bind(to: contentModel!.content)
                .addDisposableTo(disposeBag)
            
           }
        
        }

        
       func refresh(_ refreshPolicy:RefreshPolicy) {
            self.refreshDataTrigger.onNext(refreshPolicy)
        }
        
        func tapped(row: NSInteger) {
            
            //munculkan view detail merchant
            //ceritanya setiap dia mencet tombol info di merchant detail maka otomatis bakal refresh ketika tombol requested..
            let merchant = self.contents.value[row]
            let detailVM = DetailVM(coordinator: self.sceneCoordinator, merchant: merchant)
            
            self.viewWillAppearTrigger.withLatestFrom(detailVM.detailModalTrigger).map{return $0.merchant_id}
                .debug().subscribe(onNext:{
                    [unowned self] _ in
                    self.refresh(.allData)
                }).disposed(by: detailVM.disposeBag)
            
            let scene = Scene.detailVC(detailVM)
            sceneCoordinator.transition(to: scene, type: .push)
            
        }
        
}
