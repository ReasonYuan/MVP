//
//  SelectAddFriendViewController.swift
//  DoctorPlus_ios
//
//  Created by XiWang on 15-5-12.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit

class SelectAddFriendViewController: BaseViewController,ZBarReaderDelegate,UINavigationControllerDelegate {

    var message:String?
    var dialog:CustomIOS7AlertView?
    var zbarReader = ZBarReaderViewController()
    var imageLine = UIImageView(image: UIImage(named: "erweima_search_line"))
    var timer:NSTimer?
    var position = 0
    var mCount:CGFloat = 150
    @IBOutlet weak var cacleBtn: UIButton!
    @IBOutlet weak var scanBtn: UIButton!
    @IBOutlet weak var addFriendBtn: UIButton!
    var selectType:Int = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        hiddenLeftImage(true)
        hiddenRightImage(true)
        UITools.setButtonWithBackGroundColor(ColorType.EMERALD, btn: addFriendBtn, isOpposite: false)
        UITools.setButtonWithBackGroundColor(ColorType.EMERALD, btn: scanBtn, isOpposite: false)
        UITools.setBorderWithView(1.0, tmpColor: Color.color_emerald.CGColor, view: addFriendBtn)
        UITools.setBorderWithView(1.0, tmpColor: Color.color_emerald.CGColor, view: scanBtn)
        addFriendBtn.titleLabel?.lineBreakMode = NSLineBreakMode.ByCharWrapping
        addFriendBtn.titleLabel?.numberOfLines = 0
        addFriendBtn.titleLabel?.font = UIFont.systemFontOfSize(25.0)
        addFriendBtn.setTitle("添加\n朋友", forState: UIControlState.Normal)
        UITools.setButtonWithColor(ColorType.EMERALD, btn: cacleBtn, isOpposite: false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    

    override func getXibName() -> String {
        return "SelectAddFriendViewController"
    }

    @IBAction func addFriendClick(sender: AnyObject) {
        let search:ContactSearchViewController = ContactSearchViewController()
        search.mTitle = "添加朋友"
        self.navigationController?.pushViewController(search, animated: true)
    }
    
    @IBAction func scanClick(sender: AnyObject) {
         initZbar()
    }
    
    @IBAction func cancleClick(sender: AnyObject) {
        super.onLeftBtnOnClick(sender as! UIButton)
    }
    
    
    func initZbar(){
        zbarReader.readerDelegate = self
        zbarReader.tracksSymbols = false
        zbarReader.supportedOrientationsMask = 1
        zbarReader.readerView.frame.origin.y = 70.0
        let scanner = zbarReader.scanner
        zbarReader.readerView.torchMode = 0
        if IOS_STYLE == UIUserInterfaceIdiom.Pad {
            //( Y, 反X, height,width)
            zbarReader.scanCrop = CGRectMake((ScreenWidth*20/128)/(ScreenHeight*3/4), (ScreenWidth*25/128)/ScreenWidth, (ScreenWidth*7/16)/(ScreenHeight*3/4), (ScreenWidth*5/8)/ScreenWidth)
        }else{
            zbarReader.scanCrop = CGRectMake((ScreenWidth*9/64)/(ScreenHeight*3/4), (ScreenWidth*15/64)/ScreenWidth, (ScreenWidth*33/64)/(ScreenHeight*3/4), (ScreenWidth*17/32)/ScreenWidth)
        }
        let scanView = setScanView()
        zbarReader.cameraOverlayView = scanView
        setTopBar()
        
        zbarReader.showsZBarControls = false
        scanner.setSymbology(ZBAR_I25, config: ZBAR_CFG_ENABLE, to: 0)
        
        zbarReader.view.addSubview(imageLine)
        if (timer != nil) {
            timer?.invalidate()
        }
        
        timer = NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: "loop", userInfo: nil, repeats: true)
        self.navigationController?.pushViewController(zbarReader, animated: true)
        //        self.view.addSubview(zbarReader.view)
    }
    
    func setTopBar(){
        let topView = UIView(frame: CGRectMake(0, 0, ScreenWidth, 70))
        topView.backgroundColor = Color.color_emerald
        zbarReader.view.addSubview(topView)
        
        let leftBtn = UIButton(frame: CGRectMake(20, 35, 17, 17))
        leftBtn.setBackgroundImage(UIImage(named: "icon_topleft.png"), forState: UIControlState.Normal)
        leftBtn.addTarget(self, action: "leftTopClick", forControlEvents: UIControlEvents.TouchUpInside)
        topView.addSubview(leftBtn)
        
        let labelTittle = UILabel(frame: CGRectMake(ScreenWidth/4,29, ScreenWidth/2, 29))
        labelTittle.text = "二维码"
        labelTittle.textColor = UIColor(red: 243/250.0, green: 223/250.0, blue: 195/223.0, alpha: 1)
        labelTittle.textAlignment = NSTextAlignment.Center
        labelTittle.font = UIFont.systemFontOfSize(18.0)
        topView.addSubview(labelTittle)
    }
    
    func setScanView() -> UIView{
        let view = UIView(frame: CGRectMake(0, 0 ,ScreenWidth, self.view.frame.size.height*3/4-76))
        let imageview = UIImageView(image: UIImage(named: "erweima_search"))
        imageview.frame = CGRectMake(ScreenWidth*3/16, ScreenWidth*5/32+76, ScreenWidth*5/8, ScreenWidth*5/8)
        view.addSubview(imageview)
        
        let leftWidth = (ScreenWidth - imageview.frame.size.width)/2
        
        let topHeight = ScreenWidth*5/32+76 - 70
        
        let upView = UIView(frame: CGRectMake(leftWidth, 70, imageview.frame.size.width, topHeight))
        upView.backgroundColor = UIColor.whiteColor()
        upView.alpha = 0.5
        
        
        let labelzbar = UILabel(frame: CGRectMake(0, upView.frame.size.height + imageview.frame.size.height + 70 + 10, ScreenWidth, 20))
        labelzbar.text = "将二维码放入框内，即可自动扫描"
        labelzbar.textAlignment = NSTextAlignment.Center
        labelzbar.font = UIFont.systemFontOfSize(13.0)
        
        let BottomHeight = ScreenHeight - imageview.frame.size.height - upView.frame.size.height - 71
        
        let leftView = UIView(frame: CGRectMake(0, 0, leftWidth, ScreenHeight))
        leftView.backgroundColor = UIColor.whiteColor()
        leftView.alpha = 0.5
        
        let rightView = UIView(frame: CGRectMake(leftWidth + imageview.frame.size.width, 0, leftWidth, ScreenHeight))
        rightView.backgroundColor = UIColor.whiteColor()
        rightView.alpha = 0.5
        
        let downView = UIView(frame: CGRectMake(leftWidth,upView.frame.size.height + imageview.frame.size.height + 70, imageview.frame.size.width, BottomHeight ))
        downView.backgroundColor = UIColor.whiteColor()
        downView.alpha = 0.5
        
        UIButton(type: UIButtonType.Custom)
        let fromPhotoBtn = UIButton(frame: CGRectMake(ScreenWidth/4, upView.frame.size.height + imageview.frame.size.height + 70 + 80, ScreenWidth/2, 30))
        fromPhotoBtn.setTitle("从相册选取二维码", forState: UIControlState.Normal)
        fromPhotoBtn.setTitleColor(Color.color_emerald, forState: UIControlState.Normal)
        fromPhotoBtn.addTarget(self, action: "photoSelectQrcode", forControlEvents: UIControlEvents.TouchUpInside)
        
        //设置button下划线长度
        let contentLabel = UILabel(frame: CGRectMake(49, 38, ScreenWidth/2, 17))
        contentLabel.font = UIFont.systemFontOfSize(15.0)
        contentLabel.numberOfLines = 0
        
        contentLabel.text = fromPhotoBtn.titleLabel?.text!
        contentLabel.sizeToFit()
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = NSLineBreakMode.ByCharWrapping
        let attrbutes = [NSFontAttributeName:contentLabel.font,NSParagraphStyleAttributeName:paragraphStyle.copy()]
        
        let height = contentLabel.frame.size.height
        let contentString:NSString = contentLabel.text!
        let contentLableSize = (contentString.boundingRectWithSize(CGSizeMake(height, CGFloat(MAXFLOAT)), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: attrbutes, context: nil)).size
        let contentWidth = contentLableSize.width
        
        let line = UILabel(frame: CGRectMake(ScreenWidth/2-contentWidth*5, upView.frame.size.height + imageview.frame.size.height + 70 + 80 + 30 ,contentWidth*10, 1))
        
        line.backgroundColor = Color.color_emerald
        
        view.addSubview(upView)
        view.addSubview(leftView)
        view.addSubview(rightView)
        view.addSubview(downView)
        view.addSubview(labelzbar)
        zbarReader.view.addSubview(fromPhotoBtn)
        zbarReader.view.addSubview(line)
        view.backgroundColor = UIColor.clearColor()
        return view
    }
    
    func loop(){
        if (position == 1) {
            mCount += 1
            imageLine.frame = CGRectMake(ScreenWidth*3/16 + 20, mCount, ScreenWidth*5/8 - 40, 1)
            if (mCount > (ScreenWidth*5/8 + ScreenWidth*5/32 - 32 + 76)) {
                position = 2
            }
        }else
        {
            mCount -= 1
            imageLine.frame = CGRectMake(ScreenWidth*3/16+20, mCount, ScreenWidth*5/8-40, 1)
            if (mCount < ScreenWidth*5/32+32+76) {
                position = 1
            }
        }
    }
    
    func doScanResult(resultString:String){
        if selectType != 1 {
            zbarReader.readerView.stop()
        }
        zbarReader.readerView.stop()
        if resultString == ""  || resultString.isEmpty {
            UIAlertViewTool.getInstance().showAutoDismisDialog("不是有效的二维码",width:210 ,height:120)
            if selectType != 1 {
                zbarReader.readerView.start()
            }
            
        } else {
            if resultString.hasPrefix(ComFqLibToolsUriConstants.getInvitationURL()){
                let str = resultString as NSString
               print("------------------------------\(str)")
                let index = str.indexOfString("?")
                print("------------------------------\(index)")
                let tmpstr = str.substringFromIndex(Int(index))
                
                 print("------------------------------\(tmpstr)")
                let url = "\(ComFqLibToolsUriConstants.getUserURL())\(tmpstr)"
                print("------------------------------\(url)")
                let controller = UserInfoViewController()
                controller.scanUrl = url
                self.navigationController?.pushViewController(controller, animated: true)
            }else {
                if !resultString.hasPrefix("http://") && !resultString.hasPrefix("https://") {
                    timer?.fireDate = NSDate.distantFuture() 
                    dialog = UIAlertViewTool.getInstance().showZbarDialogWith1Btn("不是有效的二维码,请重新扫描", target: self, actionOk: "errorSureClick")
                    return
                }
                message  = resultString
                dialog = UIAlertViewTool.getInstance().showZbarDialog("打开：\(resultString)?", target: self, actionOk: "sureClick", actionCancle: "cancleClick")
                
            }
        }
    }
    
//    func readerControllerDidFailToRead(reader: ZBarReaderController!, withRetry retry: Bool) {
//        if retry {
//            UIAlertViewTool.getInstance().showAutoDismisDialog("不是有效的二维码",width:210 ,height:120)
//            zbarReader.readerView.start()
//            reader.dismissViewControllerAnimated(true, completion: nil)
//        }
//    }
    
    func errorSureClick(){
        dialog?.close()
        zbarReader.readerView.start()
        timer?.fireDate = NSDate.distantPast() 
    }
    
    func sureClick(){
        let url = NSURL(string:message!)
        print("\(url!)")
        UIApplication.sharedApplication().openURL(url!)
        dialog?.close()
        print("确定")
    }
    
    func cancleClick(){
        dialog?.close()
        zbarReader.readerView.start()
        print("取消")
    }

    
    func photoSelectQrcode(){
        print("从相册选取二维码")
        selectType = 1
        let pickImageController = UIImagePickerController()
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary) {
            pickImageController.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            pickImageController.mediaTypes = UIImagePickerController.availableMediaTypesForSourceType(pickImageController.sourceType)!
        }
        pickImageController.delegate = self
        pickImageController.allowsEditing = false
        self.presentViewController(pickImageController, animated: true, completion: nil)//进入相册界面
        
    }
    
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        switch selectType {
        case 0:
            let results: NSFastEnumeration = info[ZBarReaderControllerResults] as! NSFastEnumeration
            var symbolFound : ZBarSymbol?
            for symbol in results as! ZBarSymbolSet {
                symbolFound = symbol as? ZBarSymbol
                break
            }
            
            let resultString = NSString(string: symbolFound!.data)
            print(resultString)
            doScanResult(resultString as String)
        case 1:
            let image =  info[UIImagePickerControllerOriginalImage] as! UIImage
            let mm =  zbarReader.scanner.scanImage(ZBarImage(CGImage: image.CGImage))
            if mm != 0 {
                let results = zbarReader.scanner.results
                var symbolFound : ZBarSymbol?
                for symbol in results as ZBarSymbolSet {
                    symbolFound = symbol as? ZBarSymbol
                    break
                }
                
                let resultString = NSString(string: symbolFound!.data)
                print(resultString)
                picker.dismissViewControllerAnimated(true, completion: nil)
                doScanResult(resultString as String)
                
            }else{
                picker.dismissViewControllerAnimated(true, completion: nil)
                doScanResult("")
            }
            selectType = 0
        default:
            picker.dismissViewControllerAnimated(true, completion: nil)

        }
        
        
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        selectType = 0
        picker.dismissViewControllerAnimated(true, completion: nil)
    }

    func leftTopClick(){
        self.navigationController?.popViewControllerAnimated(true)
    }
}
