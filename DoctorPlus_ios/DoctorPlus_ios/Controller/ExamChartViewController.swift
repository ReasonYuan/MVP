//
//  ExamChartViewController.swift
//  DoctorPlus_ios
//
//  Created by monkey on 15-7-6.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit

class ExamChartViewController:  BaseViewController,UIWebViewDelegate,ComFqHalcyonLogic2LogicExamCharts_ExamRequestCallBack{

    
    @IBOutlet weak var webView: UIWebView!
    var patientId:Int32 = 0
    var examName = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var res = NSBundle.mainBundle().pathForResource("exam_charts", ofType: "html")
        var url = NSURL(fileURLWithPath: res!)
        webView.loadRequest(NSURLRequest(URL: url))
        setTittle(examName)
        hiddenRightImage(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func getXibName() -> String {
        return "ExamChartViewController"
    }
    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        return true
    }
    
    func webViewDidFinishLoad(webView: UIWebView){
        getChar(patientId,examName: examName)
    }
    
    func getChar(patientId:Int32,examName:String){
//        var logic = ComFqHalcyonLogic2LogicExamCharts(comFqHalcyonLogic2LogicExamCharts_ExamRequestCallBack: self)
//        logic.requestExamDataWithInt(patientId, withNSString: examName)
        var length = 30
        webView.stringByEvaluatingJavaScriptFromString("dv.style.width = '1800px' ")
        webView.stringByEvaluatingJavaScriptFromString("dv.style.height = '\(ScreenHeight - 80 )px'")
        webView.stringByEvaluatingJavaScriptFromString("drawChart('','','')");
    }
    
    func requestBackWithFQJSONArray(array: FQJSONArray!) {
        let length = array.length()
        webView.stringByEvaluatingJavaScriptFromString("setWidth(\(length * 85)'px')")
        webView.stringByEvaluatingJavaScriptFromString("dv.style.height = '400px'")
        webView.stringByEvaluatingJavaScriptFromString(ComFqHalcyonPracticeExamChartTools.getCallFuncWithNSString(examName, withFQJSONArray: array));
    }
    
    func requestErrorWithNSString(json: String!) {
        NSLog(json)
    }
}
