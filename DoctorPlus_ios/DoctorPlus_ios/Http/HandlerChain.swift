//
//  HandleChain.swift
//  FQLibrary
//
//  Created by 廖敏 on 15/8/20.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit

/// 提供方法获取类名
public class NameConvertible:NSObject {
    
    class func getName()->String{
        let className = NSStringFromClass(self.classForCoder())
        return className
    }
    
    func getName()->String{
        let className = NSStringFromClass(self.classForCoder)
        return className
    }
    
    deinit{
        print("delloc: \( NSStringFromClass(self.classForCoder))")
    }
}

public class Handler {
    
    public var closure:((chain:HandlerChain,arg:Any?) -> Any?)
    
    public init(hander:((chain:HandlerChain,arg:Any?)->Any?)){
        closure = hander
    }
    
}

/// 处理链，如果hanler的返回值为空则不会继续向下传递
public class HandlerChain : NameConvertible {
   
    /// 当前正在处理第几个handler
    public var currentHandleIndex = 0
    
    public var chain:[Handler] = []
    
    /// 处理过程中的异常处理
    public var error:((handerChain:HandlerChain,error:NSError,responseData:NSData?) -> Void)?
    
    public var count:Int {
        get{
            return chain.count
        }
    }
    
    public func clean(){
        chain.removeAll(keepCapacity: true)
    }
   
    public func addHandler(hander:((chain:HandlerChain,arg:Any?)->Any?)) -> HandlerChain{
        return self.addHandler(Handler(hander: hander))
    }
    
    public func addHandler(hander:Handler) -> HandlerChain{
        chain.append(hander)
        return self
    }
    
    /**
    开始处理
    
    - parameter arg: 最原始的参数
    
    - returns: 经过handlerChain处理后的返回值
    */
    public func handle(arg:Any?) -> Any? {
        currentHandleIndex = -1
        let result = next(arg)
        currentHandleIndex = 0
        return result
    }
    
    
    /**
    处理过程中如果没有处理，则调用这个方法交给下一个handler继续处理
    
    - parameter arg: 上个handler的返回值
    
    - returns:
    */
    public func next(arg:Any?) -> Any?{
        currentHandleIndex += 1
        if ( currentHandleIndex < chain.count){
            let nextHandle = chain[currentHandleIndex]
            return nextHandle.closure(chain: self, arg: arg)
        }
        onError("handleChain 没有下一个 handle")
        return nil
    }
    
    /**
    设置异常处理
    */
    public func setErrorHandler(error:((handerChain:HandlerChain,error:NSError,responseData:NSData?) -> Void)?) -> HandlerChain{
        self.error = error
        return self
    }
    
    /**
    快速抛出异常，如果设置了异常处理则会被调用
    */
    public func onError(reason:String,_ responseData:NSData? = nil) -> HandlerChain {
        let userInfo = [NSLocalizedDescriptionKey:reason]
        let err = NSError(domain: "HandlerChain Error", code: 0, userInfo: userInfo)
        return self.onError(error: err,responseData)
    }
    
    /**
    快速抛出异常，如果设置了异常处理则会被调用
    */
    public func onError(error error:NSError,_ responseData:NSData? = nil) -> HandlerChain {
        if let errorHandler = self.error {
            errorHandler(handerChain: self, error: error,responseData:responseData)
        }
        return self
    }
}
