//
//  HWPullToInfinity.swift
//  HypeUGC
//
//  Created by Hugues Blocher on 21/01/16.
//  Copyright © 2016 Hype. All rights reserved.
//

import UIKit
import QuartzCore
import ObjectiveC

// MARK: Pull to refresh scrollView extension

extension UIScrollView {
    
    var pullRefreshColor: UIColor? {
        get { return self.refreshControlView.tintColor }
        set(newValue) {
            self.refreshControlView.tintColor = newValue
        }
    }
    
    fileprivate struct PullAssociatedKeys {
        static var refreshControlView: UIRefreshControl?
        static var pullRefreshHasBeenSetup : Bool = false
        static var pullRefreshHandler: (() -> Void)?
    }
    
    fileprivate class pullRefreshHandlerWrapper {
        var handler: (() -> Void)
        init(handler: @escaping (() -> Void)) { self.handler = handler }
    }
    
    fileprivate var pullRefreshHandler: (() -> Void)? {
        get {
            if let wrapper = objc_getAssociatedObject(self, &PullAssociatedKeys.pullRefreshHandler) as? pullRefreshHandlerWrapper { return wrapper.handler }
            return nil
        }
        set {
            objc_setAssociatedObject(self, &PullAssociatedKeys.pullRefreshHandler, pullRefreshHandlerWrapper(handler: newValue!), objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    fileprivate var refreshControlView: UIRefreshControl {
        get {
            return objc_getAssociatedObject(self, &PullAssociatedKeys.refreshControlView) as! UIRefreshControl
        }
        set {
            objc_setAssociatedObject(self, &PullAssociatedKeys.refreshControlView, newValue as UIRefreshControl?, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    fileprivate var pullRefreshHasBeenSetup: Bool {
        get {
            guard let number = objc_getAssociatedObject(self, &PullAssociatedKeys.pullRefreshHasBeenSetup) as? NSNumber else { return false }
            return number.boolValue
        }
        set(value) {
            objc_setAssociatedObject(self, &PullAssociatedKeys.pullRefreshHasBeenSetup, NSNumber(value: value as Bool), objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    func addPullToRefreshWithActionHandler(_ actionHandler: @escaping () -> Void) {
        if !self.pullRefreshHasBeenSetup {
            let view: UIRefreshControl = UIRefreshControl()
            view.addTarget(self, action: #selector(UIScrollView.triggerPullToRefresh), for: UIControlEvents.valueChanged)
            view.layer.zPosition = self.layer.zPosition - 1
            self.refreshControlView = view
            self.pullRefreshHandler = actionHandler
            self.addSubview(view)
            self.pullRefreshHasBeenSetup = true
        }
    }
    
    func addPullToRefreshWithTitleAndActionHandler(_ pullToRefreshTitle: NSAttributedString?, actionHandler: @escaping () -> Void) {
        if !self.pullRefreshHasBeenSetup {
            let view: UIRefreshControl = UIRefreshControl()
            if let title = pullToRefreshTitle { view.attributedTitle = title }
            view.addTarget(self, action: #selector(UIScrollView.triggerPullToRefresh), for: UIControlEvents.valueChanged)
            view.layer.zPosition = self.layer.zPosition - 1
            self.refreshControlView = view
            self.pullRefreshHandler = actionHandler
            self.addSubview(view)
            self.pullRefreshHasBeenSetup = true
        }
    }
    
    func triggerPullToRefresh() {
        if let handler = self.pullRefreshHandler { handler() }
    }
    
    func stopPullToRefresh() {
        self.refreshControlView.endRefreshing()
    }
}

// MARK: Infinite Scroll

enum HWPullToInfinityState {
    case stopped
    case triggered
    case loading
    case all
}

let HWPullToInfinityViewHeight: CGFloat = 60
let HWPullToInfinityViewWidth: CGFloat = HWPullToInfinityViewHeight

class HWPullToInfinityView: UIView {

    // MARK: Infinite properties
    
    var isHorizontal: Bool = false
    var enabled: Bool = false
    
    fileprivate var _infiniteRefreshColor : UIColor = UIColor.gray
    var color : UIColor {
        get {
            return _infiniteRefreshColor
        }
        set(newColor) {
            _activityIndicatorView?.color = newColor
        }
    }
    
    fileprivate weak var scrollView: UIScrollView?
    fileprivate var infiniteScrollingHandler: (() -> Void)?
    fileprivate var viewForState: [AnyObject] = ["" as AnyObject, "" as AnyObject, "" as AnyObject, "" as AnyObject]
    fileprivate var originalInset: CGFloat = 0.0
    fileprivate var wasTriggeredByUser: Bool = false
    fileprivate var isObserving: Bool = false
    fileprivate var isSetup: Bool = false

    fileprivate var _activityIndicatorView : UIActivityIndicatorView?
    fileprivate var activityIndicatorView : UIActivityIndicatorView {
        get {
            if _activityIndicatorView == nil {
                _activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .white)
                _activityIndicatorView?.color = _infiniteRefreshColor
                _activityIndicatorView?.hidesWhenStopped = true
                self.addSubview(_activityIndicatorView!)
            }
            return _activityIndicatorView!
        }
    }
    
    fileprivate var _state: HWPullToInfinityState = .stopped
    fileprivate var state: HWPullToInfinityState {
        get {
            return _state
        }
        set(newState) {
            if _state == newState {
                return
            }
            let previousState: HWPullToInfinityState = state
            _state = newState
            for otherView in self.viewForState {
                if otherView is UIView {
                    otherView.removeFromSuperview()
                }
            }
            let customView: AnyObject = self.viewForState[newState.hashValue]
            if let custom = customView as? UIView {
                self.addSubview(custom)
                let viewBounds: CGRect = custom.bounds
                let x = CGFloat(roundf(Float((self.bounds.size.width - viewBounds.size.width) / 2)))
                let y = CGFloat(roundf(Float((self.bounds.size.height - viewBounds.size.height) / 2)))
                let origin: CGPoint = CGPoint(x: x, y: y)
                custom.frame = CGRect(x: origin.x, y: origin.y, width: viewBounds.size.width, height: viewBounds.size.height)
            } else {
                let viewBounds: CGRect = self.activityIndicatorView.bounds
                let x = CGFloat(roundf(Float((self.bounds.size.width - viewBounds.size.width) / 2)))
                let y = CGFloat(roundf(Float((self.bounds.size.height - viewBounds.size.height) / 2)))
                let origin: CGPoint = CGPoint(x: x, y: y)
                self.activityIndicatorView.frame = CGRect(x: origin.x, y: origin.y, width: viewBounds.size.width, height: viewBounds.size.height)
                switch newState {
                case .stopped:
                    self.activityIndicatorView.stopAnimating()
                case .triggered:
                    self.activityIndicatorView.startAnimating()
                case .loading:
                    self.activityIndicatorView.startAnimating()
                default: break
                }
            }
            if previousState == .triggered && newState == .loading && self.enabled {
                if let handler = self.infiniteScrollingHandler {
                    handler()
                }
            }
        }
    }
    
    // MARK: Infinite initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.autoresizingMask = .flexibleWidth
        self.enabled = true
    }
    
    convenience init () {
        self.init(frame:CGRect.zero)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override func layoutSubviews() {
        self.activityIndicatorView.center = CGPoint(x: self.bounds.size.width / 2, y: self.bounds.size.height / 2)
    }

    // MARK: Infinite scrollView
    
    func resetScrollViewContentInset() {
        var currentInsets: UIEdgeInsets = self.scrollView!.contentInset
        if self.isHorizontal {
            currentInsets.right = self.originalInset
        } else {
            currentInsets.bottom = self.originalInset
        }
        self.setScrollViewContentInset(currentInsets)
    }
    
    func setScrollViewContentInsetForInfiniteScrolling() {
        var currentInsets: UIEdgeInsets = self.scrollView!.contentInset
        if self.isHorizontal {
            currentInsets.right = self.originalInset + HWPullToInfinityViewWidth
        } else {
            currentInsets.bottom = self.originalInset + HWPullToInfinityViewHeight
        }
        self.setScrollViewContentInset(currentInsets)
    }

    func setScrollViewContentInset(_ contentInset: UIEdgeInsets) {
        UIView.animate(withDuration: 0.3, delay: 0, options: [.allowUserInteraction, .beginFromCurrentState], animations: {() -> Void in
            self.scrollView!.contentInset = contentInset
            }, completion: { _ in })
    }
    
    func scrollViewDidScroll(_ contentOffset: CGPoint) {
        if self.state != .loading && self.enabled {
            if self.isHorizontal {
                let scrollViewContentWidth: CGFloat = self.scrollView!.contentSize.width
                let scrollOffsetThreshold: CGFloat = scrollViewContentWidth - self.scrollView!.bounds.size.width
                if !self.scrollView!.isDragging && self.state == .triggered {
                    self.state = .loading
                }
                else if contentOffset.x > scrollOffsetThreshold && self.state == .stopped && self.scrollView!.isDragging {
                    self.state = .triggered
                }
                else if contentOffset.x < scrollOffsetThreshold && self.state != .stopped {
                    self.state = .stopped
                }
            } else {
                let scrollViewContentHeight: CGFloat = self.scrollView!.contentSize.height
                let scrollOffsetThreshold: CGFloat = scrollViewContentHeight - self.scrollView!.bounds.size.height
                if !self.scrollView!.isDragging && self.state == .triggered {
                    self.state = .loading
                }
                else if contentOffset.y > scrollOffsetThreshold && self.state == .stopped && self.scrollView!.isDragging {
                    self.state = .triggered
                }
                else if contentOffset.y < scrollOffsetThreshold && self.state != .stopped {
                    self.state = .stopped
                }
            }
        }
    }
    
    // MARK: Infinite observing
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if (keyPath == "contentOffset") {
            let new = (change?[NSKeyValueChangeKey.newKey] as! NSValue).cgPointValue
            self.scrollViewDidScroll(new)
        } else if (keyPath == "contentSize") {
            self.layoutSubviews()
            if self.isHorizontal {
                self.frame = CGRect(x: self.scrollView!.contentSize.width, y: 0, width: HWPullToInfinityViewWidth, height: self.scrollView!.contentSize.height)
            } else {
                self.frame = CGRect(x: 0, y: self.scrollView!.contentSize.height, width: self.bounds.size.width, height: HWPullToInfinityViewHeight)
            }
        }
    }
    
    // MARK: Infinite setters
    
    func setCustomView(_ view: UIView, forState state: HWPullToInfinityState) {
        let viewPlaceholder: AnyObject = view
        if state == .all {
            self.viewForState[0...3] = [viewPlaceholder, viewPlaceholder, viewPlaceholder]
        } else {
            self.viewForState[state.hashValue] = viewPlaceholder
        }
        self.state = state
    }
    
    func setActivityIndicatorViewColor(_ color: UIColor) {
        self.activityIndicatorView.tintColor = color
    }
    
    func triggerRefresh() {
        self.state = .triggered
        self.state = .loading
    }
    
    func startAnimating() {
        self.state = .loading
    }
    
    func stopAnimating() {
        self.state = .stopped
    }
}

// MARK: Infinite scrollView extension

extension UIScrollView {
    
    fileprivate struct InfiniteAssociatedKeys {
        static var infiniteScrollingView: HWPullToInfinityView?
        static var showsInfiniteScrolling : Bool = false
        static var infiniteScrollingHasBeenSetup : Bool = false
    }
    
    var infiniteScrollingHasBeenSetup: Bool {
        get {
            guard let number = objc_getAssociatedObject(self, &InfiniteAssociatedKeys.infiniteScrollingHasBeenSetup) as? NSNumber else {
                return false
            }
            return number.boolValue
        }
        
        set(value) {
            objc_setAssociatedObject(self,&InfiniteAssociatedKeys.infiniteScrollingHasBeenSetup,NSNumber(value: value as Bool),objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    var showsInfiniteScrolling : Bool {
        get {
            return !self.infiniteScrollingView.isHidden
        }
        set(value) {
            self.infiniteScrollingView.isHidden = !showsInfiniteScrolling
            if !value {
                if self.infiniteScrollingView.isObserving {
                    self.removeObserver(self.infiniteScrollingView, forKeyPath: "contentOffset")
                    self.removeObserver(self.infiniteScrollingView, forKeyPath: "contentSize")
                    self.infiniteScrollingView.resetScrollViewContentInset()
                    self.infiniteScrollingView.isObserving = false
                }
            } else {
                if !self.infiniteScrollingView.isObserving {
                    self.addObserver(self.infiniteScrollingView, forKeyPath: "contentOffset", options: .new, context: nil)
                    self.addObserver(self.infiniteScrollingView, forKeyPath: "contentSize", options: .new, context: nil)
                    self.infiniteScrollingView.setScrollViewContentInsetForInfiniteScrolling()
                    self.infiniteScrollingView.isObserving = true
                    self.infiniteScrollingView.setNeedsLayout()
                    if self.infiniteScrollingView.isHorizontal {
                        self.infiniteScrollingView.frame = CGRect(x: self.contentSize.width, y: 0, width: HWPullToInfinityViewWidth, height: self.contentSize.height)
                    } else {
                        self.infiniteScrollingView.frame = CGRect(x: 0, y: self.contentSize.height, width: self.infiniteScrollingView.bounds.size.width, height: HWPullToInfinityViewHeight)
                    }
                }
            }
        }
    }
    
    var infiniteScrollingView: HWPullToInfinityView {
        get {
            return objc_getAssociatedObject(self, &InfiniteAssociatedKeys.infiniteScrollingView) as! HWPullToInfinityView
        }
        set {
            self.willChangeValue(forKey: "UIScrollViewInfiniteScrollingView")
            objc_setAssociatedObject(self, &InfiniteAssociatedKeys.infiniteScrollingView, newValue as HWPullToInfinityView?, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            self.didChangeValue(forKey: "UIScrollViewInfiniteScrollingView")
        }
    }
    
    func addInfiniteScrollingWithActionHandler(_ actionHandler: @escaping () -> Void) {
        if !self.infiniteScrollingHasBeenSetup {
            let view: HWPullToInfinityView = HWPullToInfinityView(frame: CGRect(x: 0, y: self.contentSize.height, width: self.bounds.size.width, height: HWPullToInfinityViewHeight))
            view.infiniteScrollingHandler = actionHandler
            view.scrollView = self
            self.addSubview(view)
            view.originalInset = self.contentInset.bottom
            self.infiniteScrollingView = view
            self.showsInfiniteScrolling = true
            self.infiniteScrollingHasBeenSetup = true
        }
    }
    
    func addHorizontalInfiniteScrollingWithActionHandler(_ actionHandler: @escaping () -> Void) {
        if !self.infiniteScrollingHasBeenSetup {
            let view: HWPullToInfinityView = HWPullToInfinityView(frame: CGRect(x: self.contentSize.width, y: 0, width: HWPullToInfinityViewWidth, height: self.contentSize.height))
            view.infiniteScrollingHandler = actionHandler
            view.scrollView = self
            view.isHorizontal = true
            self.addSubview(view)
            view.originalInset = self.contentInset.right
            self.infiniteScrollingView = view
            self.showsInfiniteScrolling = true
            self.infiniteScrollingHasBeenSetup = true
        }
    }
    
    func triggerInfiniteScrolling() {
        self.infiniteScrollingView.state = .triggered
        self.infiniteScrollingView.startAnimating()
    }
}
