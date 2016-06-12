//
//  HttpClient.swift
//  DoctorPlus_ios
//
//  Created by 廖敏 on 15/9/14.
//  Copyright (c) 2015年 YiYiHealth. All rights reserved.
//

import UIKit

private var _instance:HttpClient = HttpClient()

class HttpClient {

    class var instance:HttpClient{
        return _instance
    }
    
    init(){
        
    }
    
   
    func POST(url: String, parameters: Dictionary<String,AnyObject>?, timeOut:Double? = nil,completionHandler:((HTTPResponse) -> Void)!)->HTTPOperation?{
        let request = self.getHTTPTask(url,timeOut)
        return request.POST(url, parameters: parameters, completionHandler: completionHandler)
    }
    
    func GET(url: String, parameters: Dictionary<String,AnyObject>?, timeOut:Double? = nil ,completionHandler:((HTTPResponse) -> Void)!)->HTTPOperation?{
        let request = self.getHTTPTask(url,timeOut)
        return request.GET(url, parameters: parameters, completionHandler: completionHandler)
    }
    
    private func getHTTPTask(url: String, _ timeOut:Double? = nil)->HTTPTask{
        var request = HTTPTask()
        //url 跳转，下载图片需要
        request.redirect = { (session: NSURLSession, task: NSURLSessionTask, response: NSHTTPURLResponse, request: NSURLRequest, completionHandler: ((NSURLRequest!) -> Void)) in
            if let headers =  task.currentRequest!.allHTTPHeaderFields {
                var newRequest = NSMutableURLRequest()
                for (key,value) in headers {
                    var hKey = key as! String
                    if(hKey != "Authorization"  && hKey != "Content-Length"){
                        newRequest.setValue(value as? String , forHTTPHeaderField:hKey )
                    }
                    
                }
//                newRequest.setValue("bytes=10070-", forHTTPHeaderField: "RANGE")  //断点续传
                newRequest.URL = request.URL
                completionHandler(newRequest)
            }
        }
       
        //https 认证
        if (ComFqLibToolsUriConstants_Conn_DO_NOT_VERIFY_CERTIFICATE == 1) {
            request.auth = {(challenge: NSURLAuthenticationChallenge) in
                    return NSURLCredential(forTrust: challenge.protectionSpace.serverTrust!)
            }
            
        }else{
            let path = NSBundle.mainBundle().pathForResource("yiyihealth", ofType: "cer")
            let data = NSData(contentsOfFile: path!)
            request.security = HTTPSecurity(certs: [HTTPSSLCert(data: data!)], usePublicKeys: true)
        }
        request.requestSerializer = JSONRequestSerializer()
        request.requestSerializer.headers["Content-Type"] = "application/json; charset=utf-8"
        var headers:Dictionary = FQSecuritySession_IOS.getSessionHeadersWithFullUrl(url, andMethod: "POST")
        for (key,value) in headers {
            request.requestSerializer.headers[key as! String] = value as? String
        }
        if let timeout = timeOut {
            request.requestSerializer.timeoutInterval = timeout
        }
        return request
    }
    
}
