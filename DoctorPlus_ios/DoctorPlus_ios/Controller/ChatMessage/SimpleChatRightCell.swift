//
//  SimpleChatRightCell.swift
//  DoctorPlus_ios
//
//  Created by XiWang on 15-7-1.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit

class SimpleChatRightCell: ChatBaseCell{

    @IBOutlet weak var userHead: UIImageView!
    @IBOutlet weak var content: UILabel!
    @IBOutlet weak var sendTimerLabel: UILabel!
    @IBOutlet weak var headBtn: UIButton!
    @IBOutlet weak var sendFailBtn:UIButton!
    @IBOutlet weak var iconRight: UIImageView!
    var imagesView:FullScreenImageZoomView!
    
    override func initData(entity: ComFqHalcyonEntityChartEntity, headView: UIView) {
        super.initData(entity, headView: headView)
        headBtn.addTarget(self, action: "headOnClick", forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    override func initData(entity: ComFqHalcyonEntityChartEntity){
        super.initData(entity, headView: userHead)
        headBtn.addTarget(self, action: "headOnClick", forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    override func setData(entity: ComFqHalcyonEntityChartEntity) {
        let messageType = entity.getMessageType()
        if messageType == 1 {
            initNormalMessage()
        }
        
        if messageType == 4  {
            initImageMessage()
        }
       
    }
    
    
    /**
    初始化发送图片的信息
    
    */
    func initImageMessage(){
        var removeView:UIView?
        var progressView:UIView?
        var failedBtn:UIView?
        for views in self.subviews {
            if (views ).tag == 1{
                removeView = (views )
            }
            if (views ).tag == 10 {
                progressView = (views )
            }
            if (views ).tag == 11{
                failedBtn = (views )
            }
        }
        removeView?.removeFromSuperview()
        progressView?.removeFromSuperview()
        failedBtn?.removeFromSuperview()
        
        sendTimerLabel.text = MessageTools.dateFormatTimer(entity!.getmSendTime())
        UITools.setRoundBounds(20.0, view: userHead)
//        UITools.setBorderWithView(1.0, tmpColor: Color.color_violet.CGColor, view: userHead)
        content.subviews.map{$0.removeFromSuperview()}
        
        let tmpView = UIView(frame: CGRectMake(ScreenWidth - 65 - CGFloat(entity!.getImageWidth()), 38,CGFloat(entity!.getImageWidth()), CGFloat(entity!.getImageHeight())))
        let imageView = UIImageView(frame: CGRectMake(0,0,CGFloat(entity!.getImageWidth()), CGFloat(entity!.getImageHeight())))
        let imageBtn = UIButton(frame: imageView.frame)
        
        imageBtn.addTarget(self, action: "imageBtnClick", forControlEvents: UIControlEvents.TouchUpInside)
        imageView.backgroundColor = Color.color_chat_right_color
        
        let btnFailed = UIButton(frame: CGRectMake(ScreenWidth - 65 - CGFloat(entity!.getImageWidth()) - 15,content.frame.origin.y + tmpView.frame.size.height/2 - 10, 20, 20))
        btnFailed.setBackgroundImage(UIImage(named: "IM_chat_failed.png"), forState: UIControlState.Normal)
        addSubview(btnFailed)
        btnFailed.tag = 11
        btnFailed.addTarget(self, action: "reSendBtnOnClick", forControlEvents: UIControlEvents.TouchUpInside)
        
        if !entity!.isSendSuccess() {
            btnFailed.hidden = false
        }else{
            btnFailed.hidden = true
        }
        
        let chatImage = UIImageView(frame: CGRectMake(0, 0, imageView.frame.size.width, imageView.frame.size.height ))
        
        let path = ComFqHalcyonExtendFilesystemFileSystem.getInstance().getImgTempPath()
        chatImage.image = UITools.getImageFromFile(path + entity!.getImagePath())
        
        if chatImage.image == nil {
            chatImage.downLoadImageWidthImageId(entity?.getMessageImageId(), callback: { (view, path) -> Void in
                let tmpView = view as! UIImageView
                UITools.getThumbnailImageFromFile(path, width: tmpView.frame.size.width, callback: { (image) -> Void in
                    tmpView.image = image
                })
                
            })
            
        }
        self.iconRight.hidden = true
        imageView.addSubview(chatImage)
        tmpView.addSubview(imageView)
        tmpView.addSubview(imageBtn)
        addSubview(tmpView)
        tmpView.tag = 1
        UITools.setRoundBounds(3.0, view: imageView)
        tmpView.translatesAutoresizingMaskIntoConstraints = false
        addConstraint(NSLayoutConstraint(item: tmpView, attribute:
            NSLayoutAttribute.Right, relatedBy: NSLayoutRelation.Equal, toItem: content, attribute: NSLayoutAttribute.Right, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: tmpView, attribute:
            NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: content, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: tmpView, attribute:
            NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: CGFloat(entity!.getImageWidth())))
        addConstraint(NSLayoutConstraint(item: tmpView, attribute:
            NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: CGFloat(entity!.getImageHeight())))
        
        let progress = ChatProgressView(frame: tmpView.frame)
        progress.tag = 10
        addSubview(progress)
        UITools.setRoundBounds(3.0, view: progress)
        progress.translatesAutoresizingMaskIntoConstraints = false
        addConstraint(NSLayoutConstraint(item: progress, attribute:
            NSLayoutAttribute.Right, relatedBy: NSLayoutRelation.Equal, toItem: content, attribute: NSLayoutAttribute.Right, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: progress, attribute:
            NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: content, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: progress, attribute:
            NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: CGFloat(entity!.getImageWidth())))
        addConstraint(NSLayoutConstraint(item: progress, attribute:
            NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: CGFloat(entity!.getImageHeight())))
    if entity!.getSendImageType() == 1 {
        progress.hidden = false
    }else{
        progress.hidden = true
    }

    }
    
    /**
    初始化普通聊天文字信息
    */
    func initNormalMessage(){
        var removeView:UIView?
        var progressView:UIView?
        var failedBtn:UIView?
        for views in self.subviews {
            if (views ).tag == 1{
                removeView = (views )
            }
            if (views ).tag == 10 {
                progressView = (views )
            }
            if (views ).tag == 11{
                failedBtn = (views )
            }
        }
        removeView?.removeFromSuperview()
        progressView?.removeFromSuperview()
        failedBtn?.removeFromSuperview()
        
        sendTimerLabel.text = MessageTools.dateFormatTimer(entity.getmSendTime())
        
        content.subviews.map{$0.removeFromSuperview()}
        content.userInteractionEnabled = true
//        content.backgroundColor = UIColor.redColor()
        self.iconRight.hidden = false
        if MessageTools.calculateHeightForCell(entity) < 18 {
//            self.content.backgroundColor = UIColor.redColor()
            
            content.textAlignment = NSTextAlignment.Right
            let width = MessageTools.calculateWidthForCell(entity)
            
            let textLabel = UILabel(frame: CGRectMake(5, 5, width, 18))
            textLabel.text = entity.getMessage()
            textLabel.font = UIFont.systemFontOfSize(13.0)
            textLabel.textColor = UIColor.whiteColor()
            
            let imageView = UIImageView(frame: CGRectMake(ScreenWidth - 112 - width  - 10, 0,width + 10, 28))
            imageView.backgroundColor = Color.color_chat_right_color
            
            let btnFailed = UIButton(frame: CGRectMake(ScreenWidth - 56 - width  - 10 - 25, content.frame.origin.y + imageView.frame.size.height/2 - 10, 20, 20))
            btnFailed.setBackgroundImage(UIImage(named: "IM_chat_failed.png"), forState: UIControlState.Normal)
            btnFailed.addTarget(self, action: "reSendBtnOnClick", forControlEvents: UIControlEvents.TouchUpInside)
            btnFailed.tag = 11
            addSubview(btnFailed)
            
            if !entity!.isSendSuccess() {
                btnFailed.hidden = false
            }else{
                btnFailed.hidden = true
            }
            
            imageView.addSubview(textLabel)
            content.addSubview(imageView)
            imageView.translatesAutoresizingMaskIntoConstraints = false
            content.addConstraint(NSLayoutConstraint(item: imageView, attribute:
                NSLayoutAttribute.Right, relatedBy: NSLayoutRelation.Equal, toItem: content, attribute: NSLayoutAttribute.Right, multiplier: 1, constant: 0))
            content.addConstraint(NSLayoutConstraint(item: imageView, attribute:
                NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: content, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 0))
            content.addConstraint(NSLayoutConstraint(item: imageView, attribute:
                NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: (width + 10)))
            content.addConstraint(NSLayoutConstraint(item: imageView, attribute:
                NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 28))
            
            
            UITools.setRoundBounds(3.0, view: imageView)
        }else{
//            self.backgroundColor = UIColor.greenColor()
            
            let textLabel =  UILabel(frame: CGRectMake(5, 5,ScreenWidth - 112 - 10, MessageTools.calculateHeightForCell(entity)))
            textLabel.numberOfLines = 0
            textLabel.font = UIFont.systemFontOfSize(13.0)
            textLabel.text = entity.getMessage()
            textLabel.sizeToFit()
            textLabel.textColor = UIColor.whiteColor()
            
            textLabel.textAlignment = NSTextAlignment.Left
            let imageView = UIImageView(frame: CGRectMake(0, 0,ScreenWidth - 112 , textLabel.frame.size.height + 10))
            imageView.backgroundColor = Color.color_chat_right_color
           
            let btnFailed = UIButton(frame: CGRectMake(56 - 25, content.frame.origin.y + imageView.frame.size.height/2 - 10, 20, 20))
            btnFailed.setBackgroundImage(UIImage(named: "IM_chat_failed.png"), forState: UIControlState.Normal)
            btnFailed.addTarget(self, action: "reSendBtnOnClick", forControlEvents: UIControlEvents.TouchUpInside)
            btnFailed.tag = 11
            addSubview(btnFailed)
//          
            if !entity.isSendSuccess() {
                btnFailed.hidden = false
            }else{
                btnFailed.hidden = true
            }
            
            imageView.addSubview(textLabel)
            content.addSubview(imageView)
            UITools.setRoundBounds(3.0, view: imageView)
            imageView.translatesAutoresizingMaskIntoConstraints = false
            content.addConstraint(NSLayoutConstraint(item: imageView, attribute:
                NSLayoutAttribute.Right, relatedBy: NSLayoutRelation.Equal, toItem: content, attribute: NSLayoutAttribute.Right, multiplier: 1, constant: 0))
            content.addConstraint(NSLayoutConstraint(item: imageView, attribute:
                NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: content, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 0))
            content.addConstraint(NSLayoutConstraint(item: imageView, attribute:
                NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: ScreenWidth - 112))
            content.addConstraint(NSLayoutConstraint(item: imageView, attribute:
                NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: textLabel.frame.size.height + 10))
        }

    }
    
    /**图片点击事件**/
    func imageBtnClick(){
        let imageId = entity!.getMessageImageId()
        var imageList = [ComFqHalcyonEntityPhotoRecord]()
        let photoRecord = ComFqHalcyonEntityPhotoRecord()
        let path = ComFqHalcyonExtendFilesystemFileSystem.getInstance().getImgTempPath()
        photoRecord.setImageIdWithInt(imageId)
        photoRecord.setLocalPathWithNSString(path + entity!.getImagePath())
        imageList.append(photoRecord)
        print(imageId)
        print(path + entity!.getImagePath())
        showImages(imageList)
    }
    
    func showImages(imageList:Array<ComFqHalcyonEntityPhotoRecord>){
        if imagesView != nil {
            imagesView.removeFromSuperview()
            imagesView = nil
        }
        if imagesView == nil {
            imagesView = FullScreenImageZoomView(frame: CGRectMake(0, 0, ScreenWidth, ScreenHeight))
            Tools.getCurrentViewController(self).view.addSubview(imagesView)
        }
        
        let pagePhotoRecords = imageList
        if pagePhotoRecords.count > 0 {
            imagesView.setDatas(0, pagePhotoRecords: pagePhotoRecords)
            imagesView.showOrHiddenView(true)
        }
        
    }
    
    override func reSendBtnOnClick() {
        if entity.getMessageType() == 1 {
            super.reSendBtnOnClick()
        }
        
        if entity.getMessageType() == 4  {
            if entity.getMessageImageId() != 0 {
                super.reSendBtnOnClick()
            }else{
                entity.setSendImageTypeWithInt(1)
                entity.setSendSuccessWithBoolean(true)
               
                let name = entity.getmSendTime()
                let path = ComFqHalcyonExtendFilesystemFileSystem.getInstance().getImgTempPath()
                let tmppath = path + "\(name)"
//                tabView?.reloadData()
                
                let controller = Tools.getCurrentViewController(self) as! BaseChatViewController
                if chatType == CHAT_SIMPLE {
                    MessageTools.getCurrentMessageEntityForSimpleReSend(entity.description(), customId: customId)
                    ComFqHalcyonLogicPracticeUpLoadChatImageManager.getInstanceWithNSString(customId).upLoadImageWithNSString(tmppath, withInt: entity.getMessageIndex(), withComFqHalcyonLogicPracticeUpLoadChatImageManager_UpLoadChatImageManagerCallBack:controller, withNSString: customId,withInt:2,withInt:toUser!.getImageId(),withNSString:toUser!.getName())
                }
                
                if chatType == CHAT_GROUP {
                    MessageTools.getCurrentMessageEntityForMoreReSend(entity.description(), groupId: customId)
                    ComFqHalcyonLogicPracticeUpLoadChatImageManager.getInstanceWithNSString(customId).upLoadImageWithNSString(tmppath, withInt: entity.getMessageIndex(), withComFqHalcyonLogicPracticeUpLoadChatImageManager_UpLoadChatImageManagerCallBack: controller, withNSString: customId,withInt:1,withInt:0,withNSString:"")
                }
            }
        }
    }
    
    
}
