//
//  MapWebBridge.swift
//  DoctorPlus_ios
//
//  管理web和native之间的通信
//
//  Created by reason on 15/12/4.
//  Copyright © 2015年 YiYiHealth. All rights reserved.
//

import UIKit

class MapWebBridge: WebViewJsBridge {
    
    weak var viewController : UIViewController!
        
    func initData(controller : UIViewController,mediacal : ComFqHalcyonEntityCareMedicalItem){
        viewController = controller
    }
        
    override func webViewDidFinishLoad(webView: UIWebView) {
        super.webViewDidFinishLoad(webView)
    }
        
        /**用数据填充界面*/
        func fillWeb(){
//            var head = uiLogic.getChartHead()
//            webView!.stringByEvaluatingJavaScriptFromString("fillChartHead(\(head))")
//            
//            var body = uiLogic.getChartBody()
//            webView!.stringByEvaluatingJavaScriptFromString("fillChartBody(\(body))")
//            
//            var doc = uiLogic.getDocument()
//            webView!.stringByEvaluatingJavaScriptFromString("fillDocument(\(doc))")
        }
        
    func log(msg:String){
        print("~~~~~:\(msg)")
    }
        
    /**获取数据结果的回调*/
    func loadRecordCallbackWithBoolean(isb: Bool) {
        if isb {
                fillWeb()
        }else{
//            viewController!.view.makeToast("网络异常，获取数据失败")
            FQToast.makeError().show("网络异常，获取数据失败", superview: viewController!.view)
        }
    }
}
