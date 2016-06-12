//
//  DataVisualizationViewController.swift
//  DoctorPlus_ios
//
//  Created by niko on 15/5/22.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit

class DataVisualizationViewController: UIViewController,UIWebViewDelegate {

    @IBOutlet weak var backKuang: UIImageView!
    @IBOutlet weak var mWebView: UIWebView!
    var entity:ComFqHalcyonEntityVisualizeVisualizeEntity!
    var loadingDialog:CustomIOS7AlertView!
    override func viewDidLoad() {
        super.viewDidLoad()
        UITools.setRoundBounds(36/2, view: backKuang)
        loadingDialog  = UIAlertViewTool.getInstance().showLoadingDialog("正在加载数据...")
        let str:String! = entity.getURL()
        let url:NSURL! = NSURL(string:str)
        mWebView.loadRequest(NSURLRequest(URL: url))
        
    }
    
    init() {
        super.init(nibName: "DataVisualizationViewController", bundle:nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        loadingDialog.close()
    }
    
    @IBAction func back(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.LandscapeLeft
    }
    override func shouldAutorotate() -> Bool {
        return true
    }
    
//    override func shouldAutorotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation) -> Bool {
//        return true
//    }

}
