//
//  HttpHandleChain.swift
//  DoctorPlus_ios
//
//  Created by 廖敏 on 15/9/14.
//  Copyright (c) 2015年 YiYiHealth. All rights reserved.
//

import Foundation

class HttpHandleChain : HandlerChain {
    
    /// 最后处理成功的回调
    var completionHandler:((Any?)->Void)?
    
    var httpOperation:HTTPOperation?
    
    init(completionHandler:((Any?)->Void)){
        super.init()
        self.completionHandler = completionHandler
        self.setUp()
    }
    
    
    /**
    初始化时的回调
    */
    func setUp(){
        //第一步设置json,response_code检测
        self.addHandler { [weak self](chain,arg) -> Any? in
            if let _self = self , let response = arg as? HTTPResponse {
                if let err = response.error {
                    _self.onError(error: err,response.responseObject as? NSData)
                }else if let data = response.responseObject as? NSData {
                    var json = JSON(data: data)
                    let code = json["response_code"].intValue
                    let msg = json["msg"].string
                    let results  = json["results"]
                    let args:(Int,String?,JSON,JSON) = (code,msg,results,json)
                    return chain.next(args)
                }
            }else{
                self?.onError("第一个handle的参数不是HTTPResponse", nil)
            }
            return nil
        }
    }
    
    /**
    网络请求成功的回调方法
    
    - parameter response: 服务器回复
    */
    func onResponse(response:HTTPResponse){
        if let sDelegate = self.completionHandler {
            let result = self.handle(response)
            let json = result as? JSON
            dispatch_sync(dispatch_get_main_queue(), { () -> Void in
                 sDelegate(result)
            })
        }
    }
    
    /**
    向服务器发送post请求
    
    - parameter url:        地址
    - parameter parameters: 参数
    */
    func POST(url: String, parameters: Dictionary<String,AnyObject>?,timeOut:Double? = nil){
        httpOperation = HttpClient.instance.POST(url, parameters: parameters,  timeOut:30, completionHandler: {(response) -> Void in
            self.onResponse(response)
        })
    }
    
    
    func cancel(){
        httpOperation?.cancel()
    }
}



