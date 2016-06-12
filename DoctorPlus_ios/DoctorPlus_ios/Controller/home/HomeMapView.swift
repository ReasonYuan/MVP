//
//  HomeMapView.swift
//  DoctorPlus_ios
//
//  主页地图图表view，包含图表和按钮
//
//  Created by reason on 15/12/2.
//  Copyright © 2015年 YiYiHealth. All rights reserved.
//

import UIKit

class HomeMapView: HomeBaseView, UIWebViewDelegate {

    
    @IBOutlet weak var mapContainer: UIView!
    
    
    let bridge: MapWebBridge = MapWebBridge()
    
    override func getXibName() -> String {
        return "HomeMapView"
    }
    
    override func moreInit() {
        let web :UIWebView = UIWebView()
        web.backgroundColor = UIColor.clearColor()
        web.opaque = false
        web.scrollView.scrollEnabled = false
        web.frame = mapContainer.frame//CGRectMake(0,40,mapContainer.frame.width,mapContainer.frame.height-80) //
//        mapContainer.addSubview(web)
        UITools.addChildViewFullInParent(web, parent: mapContainer)
        
        bridge.bridgeForWebView(web, webViewDelegate: self)
        
        web.scalesPageToFit = true;
        let res = NSBundle.mainBundle().pathForResource("home_map",ofType: "html")
        web.loadRequest(NSURLRequest(URL: NSURL(string:res!)!))
    }
}
