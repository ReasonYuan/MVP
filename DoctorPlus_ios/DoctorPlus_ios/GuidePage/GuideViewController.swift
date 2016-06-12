//
//  GuideViewController.swift
//  DoctorPlus_ios
//
//  Created by niko on 15/5/25.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit

class GuideViewController: UIViewController,UIScrollViewDelegate{
    
    @IBOutlet weak var mask: UIView!
    var maskingLayer = CALayer()
    
    var isFirstGuideTwo = true
    var isFirstGuideThree = true
    var isFirstGuideFour = true
    var oldPage = 0
    var currentPage = 0
    //guideOne
    @IBOutlet weak var guideOne2014: UIImageView!
    @IBOutlet weak var guideOneSep30: UIImageView!
    @IBOutlet weak var guideOneBingli: UIImageView!
    @IBOutlet weak var guideOneDiq: UIImageView!
    @IBOutlet weak var guideOneBlk2: UIImageView!
    @IBOutlet weak var guideOneYun1: UIImageView!
    @IBOutlet weak var guideOneYun2: UIImageView!
    @IBOutlet weak var guideOneYun3: UIImageView!
    //guideTwo
    @IBOutlet weak var guideTwoSongshilv: UIImageView!
    @IBOutlet weak var guideTwoLv: UIImageView!
    @IBOutlet weak var guideTwo2014: UIImageView!
    @IBOutlet weak var guideTwoDec18: UIImageView!
    @IBOutlet weak var guideTwoWenzi2: UIImageView!
    //guideThree
    @IBOutlet weak var guideThreeApr17: UIImageView!
    @IBOutlet weak var guideThreeLv2: UIImageView!
    @IBOutlet weak var guideThreeShijianzhou: UIImageView!
    @IBOutlet weak var guideThree2015: UIImageView!
    @IBOutlet weak var guideThreeSj: UIImageView!
    @IBOutlet weak var guideThreeSjView: UIView!
    //guideFour
    @IBOutlet weak var guideFourYijia: UIImageView!
    @IBOutlet weak var guideFourWenzi1: UIImageView!
    @IBOutlet weak var guideFourFeiji: UIImageView!
    @IBOutlet weak var guideFourYun4: UIImageView!
    @IBOutlet weak var guideFourYun5: UIImageView!
    @IBOutlet weak var guideFourYun6: UIImageView!
    @IBOutlet weak var guideFourQihang: UIButton!
    
    @IBOutlet var view4: UIView!
    var iv : UIImageView!
    var container:UIView!
    let ScreenHeight = UIScreen.mainScreen().bounds.size.height
    let ScreenWidth = UIScreen.mainScreen().bounds.size.width
    var pageControl = UIPageControl()
    @IBOutlet var sv: UIScrollView!

    @IBOutlet var contentViewOne: UIView!
    @IBOutlet var contentViewTwo: UIView!
    @IBOutlet var contentViewThree: UIView!
    @IBOutlet var contentViewFour: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.whiteColor()
        view4.backgroundColor = UIColor(red: 98/255, green: 192/255, blue: 180/255, alpha: 1.0)
        guideOne2014.hidden = true
        guideOneBingli.hidden = true
        guideOneSep30.hidden = true
        guideOneDiq.hidden = true
        guideOneYun1.hidden = true
        guideOneYun2.hidden = true
        guideOneYun3.hidden = true
        guideOneBlk2.hidden = true
        
        guideTwoSongshilv.hidden = true
        guideTwoLv.hidden = true
        guideTwo2014.hidden = true
        guideTwoDec18.hidden = true
        guideTwoWenzi2.hidden = true
        
        guideThreeApr17.hidden = true
        guideThreeLv2.hidden = true
        guideThree2015.hidden = true
        guideThreeSj.hidden = true
        
        guideFourYijia.hidden = true
        guideFourWenzi1.hidden = true
        guideFourFeiji.hidden = true
        guideFourYun4.hidden = true
        guideFourYun5.hidden = true
        guideFourYun6.hidden = true
        guideFourQihang.hidden = true
        
        maskingLayer.hidden = true
        let maskingImage = UIImage(named: "sj.png")
        if IOS_STYLE == UIUserInterfaceIdiom.Pad {
            maskingLayer.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight)
        }else{
            maskingLayer.frame = guideThreeSj.bounds
        }
        maskingLayer.contents = maskingImage?.CGImage
        guideThreeSj.layer.mask = maskingLayer
        
        for(var i = 0 ; i < 4 ; i++){
            if(i == 0){
                container = UIView(frame: CGRectMake(CGFloat(i) * ScreenWidth, 0, ScreenWidth, ScreenHeight))
                contentViewOne.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight)
                container.addSubview(contentViewOne)
                self.sv.addSubview(container!)
            }else if (i == 1){
                container = UIView(frame: CGRectMake(CGFloat(i) * ScreenWidth, 0, ScreenWidth, ScreenHeight))
                contentViewTwo.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight)
                container.addSubview(contentViewTwo)
                self.sv.addSubview(container!)
            }else if (i == 2){
                container = UIView(frame: CGRectMake(CGFloat(i) * ScreenWidth, 0, ScreenWidth, ScreenHeight))
                contentViewThree.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight)
                container.addSubview(contentViewThree)
                self.sv.addSubview(container!)
            }else if (i == 3){
                container = UIView(frame: CGRectMake(CGFloat(i) * ScreenWidth, 0, ScreenWidth, ScreenHeight))
                contentViewFour.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight)
                container.addSubview(contentViewFour)
                self.sv.addSubview(container!)
            }
        }
        self.sv.showsHorizontalScrollIndicator = false
        
        self.sv.pagingEnabled = true
        self.pageControl.currentPageIndicatorTintColor = UIColor.redColor()
        self.pageControl.pageIndicatorTintColor = UIColor.grayColor()
        self.pageControl.currentPage = 1
        
        self.view.addSubview(self.pageControl)
    }
    
    
    override func viewDidLayoutSubviews() {
        self.sv.contentSize = CGSizeMake(4 * ScreenWidth, 0)
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let pageWidth = self.sv.frame.width
        currentPage = Int(floor((self.sv.contentOffset.x - pageWidth/2) / pageWidth)) + 1
    }
    
    func guideOne2014Animation(){
        let transition = CATransition()
        transition.delegate = self
        transition.duration = 1
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromTop
        transition.setValue("transition1", forKey: "MyAnimationType")
        guideOne2014.layer.addAnimation(transition, forKey: nil)
        guideOne2014.hidden = false
    }
    
    func guideOneBingliAnimation(){
        let transition = CATransition()
        transition.delegate = self
        transition.duration = 1
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromBottom
        transition.setValue("transition2", forKey: "MyAnimationType")
        guideOneBingli.layer.addAnimation(transition, forKey: nil)
        guideOneBingli.hidden = false
    }
    
    func guideOneSep30Animation(){
        let transition = CATransition()
        transition.delegate = self
        transition.duration = 1
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        transition.type = kCATransitionFade
        transition.subtype = kCATransitionFromBottom
        transition.setValue("transition3", forKey: "MyAnimationType")
        guideOneSep30.layer.addAnimation(transition, forKey: nil)
        guideOneSep30.hidden = false
    }
    
    func guideOneDiqAnimation(){
        let transition = CABasicAnimation(keyPath: "transform.scale")
        transition.delegate = self
        transition.fromValue = NSNumber(float: 0.0)
        transition.toValue = NSNumber(float: 1.0)
        transition.duration = 1
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        transition.setValue("transition4", forKey: "MyAnimationType")
        guideOneDiq.layer.addAnimation(transition, forKey: nil)
        guideOneDiq.hidden = false
    }
    
    func guideOneYun1Animation(){
        let transition = CATransition()
        transition.delegate = self
        transition.duration = 1
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromLeft
        transition.setValue("transition5", forKey: "MyAnimationType")
        guideOneYun1.layer.addAnimation(transition, forKey: nil)
        guideOneYun1.hidden = false
    }
    
    func guideOneYun2Animation(){
        let transition1 = CATransition()
        transition1.delegate = self
        transition1.duration = 1
        transition1.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        transition1.type = kCATransitionFade
        transition1.subtype = kCATransitionFromBottom
        transition1.setValue("transition52", forKey: "MyAnimationType")
        guideOneYun1.layer.addAnimation(transition1, forKey: nil)
        
        let transition2 = CATransition()
        transition2.delegate = self
        transition2.duration = 1
        transition2.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        transition2.type = kCATransitionMoveIn
        transition2.subtype = kCATransitionFromRight
        transition2.setValue("transition53", forKey: "MyAnimationType")
        guideOneYun2.layer.addAnimation(transition2, forKey: nil)
        
        guideOneYun2.hidden = false
    }
    
    func guideOneYun3Animation(){
        let transition1 = CATransition()
        transition1.delegate = self
        transition1.duration = 1
        transition1.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        transition1.type = kCATransitionFade
        transition1.subtype = kCATransitionFromBottom
        transition1.setValue("transition54", forKey: "MyAnimationType")
        guideOneYun1.layer.addAnimation(transition1, forKey: nil)
        
        let transition2 = CATransition()
        transition2.delegate = self
        transition2.duration = 1
        transition2.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        transition2.type = kCATransitionMoveIn
        transition2.subtype = kCATransitionFromRight
        transition2.setValue("transition55", forKey: "MyAnimationType")
        guideOneYun3.layer.addAnimation(transition2, forKey: nil)
        
        guideOneYun3.hidden = false
    }
    
    func guideOneBlk2Animation(){
        let transition = CABasicAnimation(keyPath: "position")
        let fromPoint = guideOneBlk2.layer.position
        let toPoint = CGPoint(x: -guideOneBlk2.frame.width, y: ScreenHeight / 1.5)
        transition.fromValue = NSValue(CGPoint: toPoint)
        transition.toValue = NSValue(CGPoint: fromPoint)
        transition.duration = 1.5
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        transition.setValue("transition6", forKey: "MyAnimationType")
        guideOneBlk2.layer.addAnimation(transition, forKey: nil)
        guideOneBlk2.hidden = false
    }
    
    func guideTwo2014Animation(){
        let transition = CATransition()
        transition.delegate = self
        transition.duration = 1
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromTop
        transition.setValue("transition21", forKey: "MyAnimationType")
        guideTwo2014.layer.addAnimation(transition, forKey: nil)
        guideTwo2014.hidden = false
    }
    
    func guideTwoWenzi2Animation(){
        let transition = CATransition()
        transition.delegate = self
        transition.duration = 1
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromBottom
        transition.setValue("transition22", forKey: "MyAnimationType")
        guideTwoWenzi2.layer.addAnimation(transition, forKey: nil)
        guideTwoWenzi2.hidden = false
    }
    
    func guideTwoDec18Animation(){
        let transition = CATransition()
        transition.delegate = self
        transition.duration = 1
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        transition.type = kCATransitionFade
        transition.subtype = kCATransitionFromBottom
        transition.setValue("transition23", forKey: "MyAnimationType")
        guideTwoDec18.layer.addAnimation(transition, forKey: nil)
        guideTwoDec18.hidden = false
    }
    
    func guideTwoLvAnimation(){
        let transition = CABasicAnimation(keyPath: "transform.rotation.y")
        transition.toValue = NSNumber(float: Float(-2 * M_PI))
        transition.duration = 2
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        transition.setValue("transition24", forKey: "MyAnimationType")
        guideTwoLv.layer.addAnimation(transition, forKey: nil)
        guideTwoLv.hidden = false
    }
    
    func guideTwoSongshilvAnimation(){
        let transition = CATransition()
        transition.delegate = self
        transition.duration = 2
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromBottom
        transition.setValue("transition25", forKey: "MyAnimationType")
        guideTwoSongshilv.layer.addAnimation(transition, forKey: nil)
        guideTwoSongshilv.hidden = false
    }
    
    func guideThree2015Animation(){
        let transition = CATransition()
        transition.delegate = self
        transition.duration = 1
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromTop
        transition.setValue("transition31", forKey: "MyAnimationType")
        guideThree2015.layer.addAnimation(transition, forKey: nil)
        guideThree2015.hidden = false
    }
    
    func guideThreeLv2Animation(){
        let transition = CATransition()
        transition.delegate = self
        transition.duration = 1
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromBottom
        transition.setValue("transition32", forKey: "MyAnimationType")
        guideThreeLv2.layer.addAnimation(transition, forKey: nil)
        guideThreeLv2.hidden = false
    }
    
    func guideThreeApr17Animation(){
        let transition = CATransition()
        transition.delegate = self
        transition.duration = 1
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        transition.type = kCATransitionFade
        transition.subtype = kCATransitionFromBottom
        transition.setValue("transition33", forKey: "MyAnimationType")
        guideThreeApr17.layer.addAnimation(transition, forKey: nil)
        guideThreeApr17.hidden = false
    }
    
    func maskingLayerAnimation(){
        let transition = CABasicAnimation(keyPath: "position")
        var toPoint = maskingLayer.position
        toPoint.y -= maskingLayer.frame.height
        transition.fromValue = NSValue(CGPoint: toPoint)
        transition.toValue = NSValue(CGPoint: maskingLayer.position)
        transition.duration = 1.5
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        transition.setValue("transition34", forKey: "MyAnimationType")
        maskingLayer.addAnimation(transition, forKey: nil)
        guideThreeSj.hidden = false
        maskingLayer.hidden = false
    }
    
    func guideFourYijiaAnimation(){
        let transition = CATransition()
        transition.delegate = self
        transition.duration = 1
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromBottom
        transition.setValue("transition41", forKey: "MyAnimationType")
        guideFourYijia.layer.addAnimation(transition, forKey: nil)
        guideFourYijia.hidden = false
    }
    
    func guideFourWenzi1Animation(){
        let transition = CATransition()
        transition.delegate = self
        transition.duration = 1
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromBottom
        transition.setValue("transition42", forKey: "MyAnimationType")
        guideFourWenzi1.layer.addAnimation(transition, forKey: nil)
        guideFourWenzi1.hidden = false
    }
    
    func guideFourYun4Animation(){
        let transition = CATransition()
        transition.delegate = self
        transition.duration = 0.8
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromRight
        transition.setValue("transition43", forKey: "MyAnimationType")
        guideFourYun4.layer.addAnimation(transition, forKey: nil)
        guideFourYun4.hidden = false
    }
    
    func guideFourYun4cAnimation(){
        let transition = CABasicAnimation(keyPath: "position")
        var toPoint = guideFourYun4.layer.position
        toPoint.y -= guideFourYun4.frame.height/4
        var fromPoint = guideFourYun4.layer.position
        fromPoint.y += guideFourYun4.frame.height/4
        transition.fromValue = NSValue(CGPoint: toPoint)
        transition.toValue = NSValue(CGPoint: fromPoint)
        transition.duration = 1.5
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        transition.setValue("transition4000", forKey: "MyAnimationType")
        transition.repeatCount = 500
        transition.autoreverses = true
        guideFourYun4.layer.addAnimation(transition, forKey: nil)
    }
    
    func guideFourYun5Animation(){
        let transition = CATransition()
        transition.delegate = self
        transition.duration = 0.8
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromLeft
        transition.setValue("transition44", forKey: "MyAnimationType")
        guideFourYun5.layer.addAnimation(transition, forKey: nil)
        guideFourYun5.hidden = false
    }
    
    func guideFourYun5cAnimation(){
        let transition = CABasicAnimation(keyPath: "position")
        var toPoint = guideFourYun5.layer.position
        toPoint.y -= guideFourYun5.frame.height/4
        var fromPoint = guideFourYun5.layer.position
        fromPoint.y += guideFourYun5.frame.height/4
        transition.fromValue = NSValue(CGPoint: toPoint)
        transition.toValue = NSValue(CGPoint: fromPoint)
        transition.duration = 1.0
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        transition.setValue("transition5000", forKey: "MyAnimationType")
        transition.repeatCount = 500
        transition.autoreverses = true
        guideFourYun5.layer.addAnimation(transition, forKey: nil)
    }
    
    func guideFourYun6Animation(){
        let transition = CATransition()
        transition.delegate = self
        transition.duration = 0.8
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromRight
        transition.setValue("transition45", forKey: "MyAnimationType")
        guideFourYun6.layer.addAnimation(transition, forKey: nil)
        guideFourYun6.hidden = false
    }
    
    func guideFourYun6cAnimation(){
        let transition = CABasicAnimation(keyPath: "position")
        var toPoint = guideFourYun6.layer.position
        toPoint.y -= guideFourYun6.frame.height/4
        var fromPoint = guideFourYun6.layer.position
        fromPoint.y += guideFourYun6.frame.height/4
        transition.fromValue = NSValue(CGPoint: toPoint)
        transition.toValue = NSValue(CGPoint: fromPoint)
        transition.duration = 1.2
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        transition.setValue("transition6000", forKey: "MyAnimationType")
        transition.repeatCount = 500
        transition.autoreverses = true
        guideFourYun6.layer.addAnimation(transition, forKey: nil)
    }
    
    func guideFourQihangAnimation(){
        let transition = CATransition()
        transition.delegate = self
        transition.duration = 1
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        transition.type = kCATransitionFade
        transition.subtype = kCATransitionFromBottom
        transition.setValue("transition46", forKey: "MyAnimationType")
        guideFourQihang.layer.addAnimation(transition, forKey: nil)
        guideFourQihang.hidden = false
    }
    
    func guideFourFeijiAnimation(){
        let transition = CABasicAnimation(keyPath: "position")
        let fromPoint = CGPoint(x: 0, y: ScreenHeight / 3 * 2)
        let toPoint = CGPoint(x: guideFourFeiji.frame.width * 2 + ScreenWidth, y: ScreenHeight / 7 * 2)
        transition.fromValue = NSValue(CGPoint: fromPoint)
        transition.toValue = NSValue(CGPoint: toPoint)
        transition.duration = 4
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        transition.setValue("transition47", forKey: "MyAnimationType")
        guideFourFeiji.hidden = false
        guideFourFeiji.layer.addAnimation(transition, forKey: nil)
    }
    
    override func animationDidStop(anim: CAAnimation, finished flag: Bool) {
        let value: NSString = anim.valueForKey("MyAnimationType") as! NSString
        if(value.isEqualToString("transition1")){
            guideOneSep30Animation()
        }else if(value.isEqualToString("transition3")){
            guideOneDiqAnimation()
        }else if(value.isEqualToString("transition4")){
            guideOneYun1Animation()
            guideOneYun2Animation()
            guideOneYun3Animation()
        }else if(value.isEqualToString("transition5")){
            guideOneBlk2Animation()
        }else if(value.isEqualToString("transition21")){
            guideTwoDec18Animation()
        }else if(value.isEqualToString("transition23")){
            guideTwoSongshilvAnimation()
            guideTwoLvAnimation()
        }else if(value.isEqualToString("transition31")){
            guideThreeApr17Animation()
        }else if(value.isEqualToString("transition33")){
            maskingLayerAnimation()
        }else if(value.isEqualToString("transition41")){
            guideFourWenzi1Animation()
        }else if(value.isEqualToString("transition42")){
            guideFourYun4Animation()
        }else if(value.isEqualToString("transition43")){
            guideFourYun4cAnimation()
            guideFourYun5Animation()
        }else if(value.isEqualToString("transition44")){
            guideFourYun5cAnimation()
            guideFourYun6Animation()
        }else if(value.isEqualToString("transition45")){
            guideFourYun6cAnimation()
            guideFourQihangAnimation()
        }else if(value.isEqualToString("transition46")){
            guideFourFeijiAnimation()
        }else if(value.isEqualToString("transition47")){
            guideFourFeiji.hidden = true
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        guideOne2014Animation()
        guideOneBingliAnimation()
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        let offSetX = self.sv.contentOffset.x
        let index = offSetX/self.view.frame.size.width
        self.pageControl.currentPage = Int (index)
        if(oldPage != currentPage){
            print("\(self.currentPage)")
            oldPage = currentPage
            if(self.currentPage == 1 && isFirstGuideTwo){
                guideTwo2014Animation()
                guideTwoWenzi2Animation()
                isFirstGuideTwo = false
            }else if(self.currentPage == 2 && isFirstGuideThree){
                guideThree2015Animation()
                guideThreeLv2Animation()
                isFirstGuideThree = false
            }else if(self.currentPage == 3 && isFirstGuideFour){
                guideFourYijiaAnimation()
                isFirstGuideFour = false
            }
        }
    }
    
    @IBAction func btnClicked(sender: AnyObject) {
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: "everLaunched")
        self.navigationController?.pushViewController(LoginViewController(nibName:"LoginViewController",bundle:nil), animated: false)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
