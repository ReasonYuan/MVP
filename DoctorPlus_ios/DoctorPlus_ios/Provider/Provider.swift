//
//  Provider.swift
//  TestOther
//
//  Created by 廖敏 on 15/9/21.
//  Copyright (c) 2015年 reason. All rights reserved.
//

import Foundation
import RealmSwift
import DataCache

//class Test : Object {
////    dynamic var id = ""
////    override static func primaryKey() -> String? {
////        return "id"
////    }
//}


class Provider : HandlerChain {

    struct ProviderConfig {
        
        /// 请求网络的时间间隔
        var updateInterval:NSTimeInterval = 0
        
    }
    
    /// 注册的数据变更回调
    var observers:[NSObject:((Any?)->Void)]
    
    var id:String
    
    var httpOperation:HTTPOperation?
    
    var config:ProviderConfig?
    
    /// 是否从服务器上取得数据
    var isGetDataFormServer:Bool = false
    
    var lastGetDataFormServerTime:NSTimeInterval = 0
    
    init(_ id:String,config:ProviderConfig? = nil){
        observers = Dictionary<NSObject,((Any?)->Void)>()
        self.id = id
        self.config = config
    }
    
    /**
    添加回调
    
    - parameter target:   目标，没什么用，unRegisterObserver的时候的key
    - parameter observer:  回调闭包
    */
    func registerObserver(target:NSObject,_ observer:((Any?)->Void)){
        observers[target] = observer
    }
    
    /**
    删除回调
    
    - parameter target: 注册的时候的key
    */
    func unRegisterObserver(target:NSObject){
        observers.removeValueForKey(target)
        if( observers.isEmpty ){ //如果没有回调则回收
            providerManagerInstance.providerTable.removeValueForKey(id)
        }
    }
    
    /**
    获取数据,如果已经请求过数据：如果配置config并且上次请求时间大于interval这请求服务器，否则直接返回本地数据
            没有请求过数据：有本地数据则马上显示本地数据，在请求网络
    */
    func getData(_ subId:String? = nil){
        if isGetDataFormServer,let conf = config{
            let now = (CFAbsoluteTimeGetCurrent() + kCFAbsoluteTimeIntervalSince1970)*1000
            if( (now - lastGetDataFormServerTime ) >= conf.updateInterval*100){ //时间过了从网上取
                getHttpData(subId) { (data) -> Void in
                    self.handleData(data)
                    self.isGetDataFormServer = true
                    self.lastGetDataFormServerTime = (CFAbsoluteTimeGetCurrent() + kCFAbsoluteTimeIntervalSince1970)*1000
                }
            }else{ //直接加载本地数据
                handleData(getLocalData(subId))
            }
        }else{
            handleData(getLocalData(subId))    //获取本地数据
            getHttpData(subId) { (data) -> Void in//获取网络数据
                self.handleData(data)
                self.isGetDataFormServer = true
                self.lastGetDataFormServerTime = (CFAbsoluteTimeGetCurrent() + kCFAbsoluteTimeIntervalSince1970)*1000
            }
        }
    }
    
    
    /**
    向服务器发送post请求
    
    - parameter url:               地址
    - parameter parameters:        参数
    - parameter completionHandler: 回调
    - parameter cache:             是否缓存
    - parameter subId:
    - parameter timeOut:           
    */
    func POST(url: String, parameters: Dictionary<String,AnyObject>?,completionHandler:((String?)->Void),cache:Bool = true,subId:String? = nil,timeOut:Double? = nil){
        httpOperation = HttpClient.instance.POST(url, parameters: parameters,  timeOut:30, completionHandler: {(response) -> Void in
            if let err = response.error {
                self.onError(error: err,response.responseObject as? NSData)
            }else if let data = response.responseObject as? NSData {
                if let  str = NSString(data: data, encoding: NSUTF8StringEncoding){
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        completionHandler(str as String)
                        if (cache){
                            self.cache(subId,str: str as String)
                        }
                    })
                }
            }
        })
    }
    
    
    func cancel(){
        httpOperation?.cancel()
    }

    
    func cache(subId:String? = nil,str:String){
        if let sub_id = subId{
            DataCache.cache(id+"_"+sub_id, str: str) { (str) -> [String]? in
                return nil
            }
        }else{
            DataCache.cache(id, str: str) { (str) -> [String]? in
                return nil
            }
        }
    }

    
    /**
    处理数据，不管本地数据还是网络数据都是这个方法处理
    
    - parameter str:
    */
    private func handleData(str:String?){
        if let jsonStr = str,let dataFromString = jsonStr.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false){
            var json = JSON(data: dataFromString)
            let code = json["response_code"].intValue
            let msg = json["msg"].string
            let results  = json["results"]
            let reslut = self.onDataHandle(code, errorMsg: msg, resulus: results, responseStr: str!)
            for (target,obs) in observers {
                obs(reslut)
            }
        }
    }
    
    
    /**
    获取本地数据
    
    - returns: 本地数据库缓存的json
    */
    func getLocalData(_ subId:String? = nil)->String?{
        let (_id,text,_,_) = DataCache.get(subId != nil ? id+"_"+subId! : id)
        return text
    }

    
    /**
    处理数据详细信息
    
    - parameter errorCode:
    - parameter errorMsg:
    - parameter resulus:
    - parameter responseStr:
    
    - returns:
    */
    func onDataHandle(errorCode:Int,errorMsg:String?,resulus:JSON,responseStr:String)->Any?{
        assertionFailure("onDataHandle method must be overridden")
        return nil
    }
    
    
    /**
    获取网络数据
    
    - parameter
    */
    func getHttpData(_ subId:String? = nil,completionHandler:((String?)->Void)){
       assertionFailure("getHttpData method must be overridden")
    }
    
}

private var providerManagerInstance = ProviderManager()

class ProviderManager{
    class var instance:ProviderManager {
        return providerManagerInstance;
    }
    
    /// 缓存table，每种类型的Provider在内存中只能出现一个
    private var providerTable:[String:Provider] = [String:Provider]()
    

//    func getProvider<T : Provider>(id:String,@noescape creater:((id:String)->Provider))-> T {
//        if let cache = providerTable[id] as? T {
//            return cache;
//        }else{
//            if let cache = creater(id: id) as? T {
//                providerTable[id] = cache
//                return cache
//            }
//            return T(id)
//        }
//    }
}