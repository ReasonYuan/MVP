//
//  WebChartViewController.swift
//  DoctorPlus_ios
//
//  Created by 廖敏 on 15/7/6.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit

class WebChartViewController: BaseViewController {

    @IBOutlet weak var mWebView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        var resourcePath = NSBundle.mainBundle().resourcePath
        
//        var filePath = resourcePath?.stringByAppendingPathComponent("Html/chart.html")
      var filePath =  NSURL(fileURLWithPath: resourcePath!).URLByAppendingPathComponent("Html/chart.html")
        
        //encoding:NSUTF8StringEncoding error:nil 这一段一定要加，不然中文字会乱码
        let htmlstring = try! NSString(contentsOfFile: filePath.absoluteString, encoding: NSUTF8StringEncoding);
        var html:String = htmlstring as! String
        mWebView.loadHTMLString(html, baseURL: NSURL.fileURLWithPath(NSBundle.mainBundle().bundlePath+"/Html"))
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func getXibName() -> String {
        return "WebChartViewController"
    }

}
