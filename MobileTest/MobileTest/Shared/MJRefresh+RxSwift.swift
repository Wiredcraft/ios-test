//  MJRefresh+Hex.swift
//  MobileTest
//
//  Created by yanjun lee on 2022/3/26.
//

import UIKit
import RxSwift
import RxCocoa
import MJRefresh

class Target: NSObject, Disposable {
    private var retainSelf: Target?
    override init() {
        super.init()
        self.retainSelf = self
    }
    func dispose() {
        self.retainSelf = nil
    }
}

private final
class MJRefreshTarget<Component: MJRefreshComponent>: Target {
    typealias CallBack = (MJRefreshState)->()

    weak var component: Component?
    
    let callBack:CallBack
    
    init(_ component: Component , callBack: @escaping CallBack) {
        self.callBack = callBack
        self.component = component
        super.init()
        component.addObserver(self, forKeyPath: "state", options: [.new], context: nil)
    }
    
    override func dispose() {
        super.dispose()
        self.component?.removeObserver(self, forKeyPath: "state")
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "state",
            let new = change?[NSKeyValueChangeKey.newKey] as? Int ,
            let state = MJRefreshState.init(rawValue: new) {
            self.callBack(state)
        }
    }
    
    deinit {
        print("deinit")
    }
}

extension Reactive where Base: MJRefreshComponent {
    
    ///
    var refresh:ControlEvent<Void> {
        let source = state.filter({$0 == .refreshing})
            .map({_ in ()}).asObservable()
        return ControlEvent.init(events: source)
    }
    
    /// 
    var state: ControlProperty<MJRefreshState> {
        let source: Observable<MJRefreshState> = Observable.create { [weak component = self.base] observer  in
            MainScheduler.ensureExecutingOnScheduler()
            guard let component = component else {
                observer.on(.completed)
                return Disposables.create()
            }
            observer.on(.next(component.state))
            let target = MJRefreshTarget(component) { (state) in
                observer.onNext(state)
            }
            return target
        }.takeUntil(deallocated)
        
        let bindingObserver = Binder<MJRefreshState>(self.base) { (component, state) in
            component.state = state
        }
        return ControlProperty(values: source, valueSink: bindingObserver)
    }
}
