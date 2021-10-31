//
//  ZLPromise.swift
//  ZLPromise
//
//  Created by Minh Nguyen's Mac on 10/25/21.
//

import Foundation

//typealist blockPromise
typealias blockReturn = ()->Any
typealias blockReturn2 = (Any)->Any
typealias blockParam = (Any) -> Void
typealias blockDefault = ()->Void
typealias blockWithCompletion = (@escaping blockParam)->Void

// firstly : run block on queue. resolve with value (block return) (ok)
// then : add to observe
// firstlyWaitComplete : run block on queue, wait completion to resolve

// resolve : set value & seal observe


class ZLPromise : NSObject {
    
    var observers : [blockParam] = []
    var val : Any?
    var didReesolve = false
    
    class func firstly(_ queue : DispatchQueue?, _ block:@escaping blockReturn)->Self {
        let promise = ZLPromise()
        
        if let queue1=queue {
            queue1.async {
                promise.resolve(block())
            }
        } else {
            promise.resolve(block())
        }
        
        return promise as! Self
    }
    class func firstlyWithCompletion(_ block : @escaping blockWithCompletion) -> Self {
        let promise = ZLPromise()
        
        let completion : blockParam = { val in
            promise.resolve(val)
        }
        block(completion)
        
        return promise as! Self
    }
    
    func then( _ block: @escaping blockReturn2) -> ZLPromise {
        let promise = ZLPromise()
        
        if didReesolve {
            promise.resolve(block(val as Any))
        } else {
            let block2 : blockParam = { val in
                let thenVal = block(val)
                promise.resolve(thenVal)
            }
            
            observers.append(block2)
        }
        
        return promise
    }
    
    
private func resolve(_ val:Any) {
        self.val = val
        didReesolve = true
        for block in observers {
            block(val)
        }
        observers.removeAll()
    }
  
    
}

class another:NSObject {
    func someFunc() {
       
        
    }
}
