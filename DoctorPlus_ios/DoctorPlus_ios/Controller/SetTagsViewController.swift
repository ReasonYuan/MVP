//
//  SetTagsViewController.swift
//  DoctorPlus_ios
//
//  Created by niko on 15/6/1.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit

class SetTagsViewController: BaseViewController,UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,ComFqHalcyonLogic2TagLogic_SuccessCallBack,ComFqHalcyonLogic2TagLogic_FailCallBack {
    var text = ""
    var dialog:CustomIOS7AlertView!
    //触摸屏幕
    @IBAction func touched(sender: AnyObject) {
        if(tagsInput.isFirstResponder()){
            tagsInput.resignFirstResponder()
        }
        else{
            editEnd()
        }
    }
    var inputSize:CGSize!
    var delBtn:UIButton!
    var tagsInput:FQTexfield!
    @IBOutlet weak var mTableView: UITableView!
    var datas:JavaUtilArrayList!
    var selectedPosition = -1
    var mTagUtils:ComFqHalcyonUilogicTagUtils?
    var imageId:Int32?
    var user:ComFqHalcyonEntityContacts!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var headView: UIImageView!
    //确认点击
    @IBAction func sureBtnClicked(sender: AnyObject) {
        editEnd()
        mTagUtils?.getChangeListWithJavaUtilArrayList(mTagUtils?.getMyContactTagListWithComFqHalcyonEntityContacts(user), withJavaUtilArrayList: datas)
        dialog = UIAlertViewTool.getInstance().showLoadingDialog("")
        let logic = ComFqHalcyonLogic2TagLogic()
        let patientIdList = JavaUtilArrayList()
        patientIdList.addWithId(JavaLangInteger(int: user.getUserId()))
        logic.attachPatientsWithJavaUtilArrayList(patientIdList, withJavaUtilArrayList: mTagUtils?.getAddTagWithIdList(), withJavaUtilArrayList: mTagUtils?.getAddTagWithStrList(), withJavaUtilArrayList: mTagUtils?.getDelTagList(), withComFqHalcyonLogic2TagLogic_SuccessCallBack: self, withComFqHalcyonLogic2TagLogic_FailCallBack: self)
    }
    //设置标签成功的回调
    func onSuccessWithInt(responseCode: Int32, withNSString msg: String!, withInt type: Int32, withId results: AnyObject!) {
        dialog.close()
        UIAlertViewTool.getInstance().showAutoDismisDialog("设置成功", width: 210, height: 120)
        self.navigationController?.popViewControllerAnimated(true)
        ComFqHalcyonLogic2TagLogic().getListAllTagsWithComFqHalcyonLogic2TagLogic_RequestTagInfCallBack(nil)
        for(var i:Int32 = 0; i < ComFqLibToolsConstants_contactsList_.size(); i++){
            if(ComFqLibToolsConstants_contactsList_.getWithInt(Int32(i)).getUserId() == user.getUserId()){
                user.getTags().clear()
                for(var i:Int32 = 0 ; i < datas.size();i++ ){
                    user.getTags().addWithId(datas.getWithInt(Int32(i)).getTitle())
                }
                break
            }
        }
    }
    
    //设置标签失败的回调
    func onFailWithInt(code: Int32, withNSString msg: String!) {
        dialog.close()
        UIAlertViewTool.getInstance().showAutoDismisDialog("网络状况不佳,设置失败", width: 210, height: 120)
    }
    @IBOutlet weak var sureButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        setTittle("设置标签")
        hiddenRightImage(true)
        UITools.setRoundBounds(5, view: sureButton)
        UITools.setButtonWithColor(ColorType.EMERALD, btn: sureButton, isOpposite: false)
        UITools.setRoundBounds(20.0, view: headView)
        UITools.setBorderWithView(1.0, tmpColor: Color.color_emerald.CGColor, view:headView)
        nameLabel.text = user?.getUsername()
        let photo = ComFqHalcyonEntityPhoto()
        photo.setImageIdWithInt(user.getImageId())
        headView.downLoadImageWidthImageId(photo.getImageId(), callback: { (view, path) -> Void in
            let tmpImageView = view as! UIImageView
            tmpImageView.image = UITools.getImageFromFile(path)
        })
        mTableView.showsVerticalScrollIndicator = false
        //长按事件
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: "handleLongPressGesture:")
        longPressGesture.minimumPressDuration = 1
        longPressGesture.allowableMovement = 15
        longPressGesture.numberOfTouchesRequired = 1
        mTableView.addGestureRecognizer(longPressGesture)
        initDatas()
    }
    //区分tableview点击时间和长按事件
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool{
        if(touch.view!.isDescendantOfView(mTableView)){
            return false
        }
        return true
    }
    //长按事件
    func handleLongPressGesture(sender:UILongPressGestureRecognizer){
        let index = mTableView.indexPathForRowAtPoint(sender.locationInView(mTableView))?.row
        if(sender.state == UIGestureRecognizerState.Ended){
            return
        }else if(sender.state == UIGestureRecognizerState.Began){
            selectedPosition = index!
            mTableView.reloadData()
        }
    }
    //初始化tag数据
    func initDatas(){
        mTagUtils = ComFqHalcyonUilogicTagUtils()
        datas = mTagUtils?.getMyContactTagListWithComFqHalcyonEntityContacts(user)
    }
    
    override func getXibName() -> String {
        return "SetTagsViewController"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("CellId")
        if(cell == nil){
            cell = UITableViewCell(style: .Default, reuseIdentifier: "CellId")
        }else{
            while(cell?.contentView.subviews.last != nil){
                cell?.contentView.subviews.last?.removeFromSuperview()
            }
        }
        //图标和线条
        var imageView = UIImageView(frame: CGRectMake(0, 12, 20, 20))
        imageView.image = UIImage(named: "icon_address_tag_unselected.png")
        cell?.contentView.addSubview(imageView)
        var label = UILabel(frame: CGRectMake(0, 42, UIScreen.mainScreen().bounds.size.width - 60, 0.5))
        label.backgroundColor = UIColor.lightGrayColor()
        //标签名
        var tagName = UIButton(frame: CGRectMake(19, 12, 20, 20))
        tagName.titleLabel?.font = UIFont.systemFontOfSize(14)
        tagName.adjustsImageWhenHighlighted = false
        tagName.titleLabel?.lineBreakMode = NSLineBreakMode.ByTruncatingTail
        tagName.contentEdgeInsets = UIEdgeInsetsMake(0, 4, 0, 0)
        tagName.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
        //标签名输入框
        inputSize = ("请输入标签名称" as NSString).sizeWithAttributes([NSFontAttributeName : UIFont.systemFontOfSize(14)])
        tagsInput = FQTexfield(frame: CGRectMake(19, 12, inputSize.width + 5, 20))
        tagsInput.placeholder = "请输入标签名称"
        tagsInput.font = UIFont.systemFontOfSize(14)
        tagsInput.backgroundColor = UIColor(red: 218/255, green: 238/255, blue: 234/255, alpha: 1.0)
        if(indexPath.row == Int(datas.size())){
            cell?.contentView.addSubview(tagsInput)
        }
        if(indexPath.row % 2 == 0 && indexPath.row != Int(datas.size())){
            tagName.setTitle(datas.getWithInt(Int32(indexPath.row)).getName(), forState: UIControlState.Normal)
            var stringSize = (datas.getWithInt(Int32(indexPath.row)).getName() as NSString).sizeWithAttributes([NSFontAttributeName : UIFont.systemFontOfSize(14)])
            var btnWidth :CGFloat
            var temp = ("噢噢噢" as NSString).sizeWithAttributes([NSFontAttributeName : UIFont.systemFontOfSize(14)]).width
            if(stringSize.width < temp){
                btnWidth = temp
            }else if(stringSize.width > cell!.frame.width/3 * 2){
                btnWidth = cell!.frame.width/3 * 2
            }else{
                btnWidth = stringSize.width
            }
            tagName.frame = CGRectMake(20, 12, btnWidth + 8, 20)
           var image =  Tools.createNinePathImageForImage(UIImage(named: "tag_yellow_bg.png"), leftMargin: 15, rightMargin: 15, topMargin: 15, bottomMargin: 5)
            tagName.setBackgroundImage(image, forState: UIControlState.Normal)
            cell?.contentView.addSubview(tagName)
            cell?.contentView.addSubview(label)
        }
        if(indexPath.row % 2 != 0 && indexPath.row != Int(datas.size())){
            tagName.setTitle(datas.getWithInt(Int32(indexPath.row)).getName(), forState: UIControlState.Normal)
            var stringSize = (datas.getWithInt(Int32(indexPath.row)).getName() as NSString).sizeWithAttributes([NSFontAttributeName : UIFont.systemFontOfSize(14)])
            var btnWidth :CGFloat
            var temp = ("噢噢噢" as NSString).sizeWithAttributes([NSFontAttributeName : UIFont.systemFontOfSize(14)]).width
            if(stringSize.width < temp){
                btnWidth = temp
            }else if(stringSize.width > cell!.frame.width/3 * 2){
                btnWidth = cell!.frame.width/3 * 2
            }else{
                btnWidth = stringSize.width
            }
            tagName.frame = CGRectMake(20, 12, btnWidth + 8, 20)
            var image =  Tools.createNinePathImageForImage(UIImage(named: "tag_green_bg.png"), leftMargin: 15, rightMargin: 15, topMargin: 15, bottomMargin: 5)
            image?.resizableImageWithCapInsets(UIEdgeInsetsMake(2, 2, 2, 30), resizingMode: UIImageResizingMode.Stretch)
            tagName.setBackgroundImage(image, forState: UIControlState.Normal)
            cell?.contentView.addSubview(tagName)
            cell?.contentView.addSubview(label)
        }
        if(selectedPosition == indexPath.row && indexPath.row != Int(datas.size())){
            delBtn = UIButton(frame: CGRectMake((cell!.frame.width - ("噢噢" as NSString).sizeWithAttributes([NSFontAttributeName : UIFont.systemFontOfSize(14)]).width)-10, 12, ("噢噢" as NSString).sizeWithAttributes([NSFontAttributeName : UIFont.systemFontOfSize(14)]).width + 10, 20))
            delBtn.setTitle("删除", forState: UIControlState.Normal)
            delBtn.titleLabel?.font = UIFont.systemFontOfSize(14)
            delBtn.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
            delBtn.layer.borderWidth = 1.0
            delBtn.backgroundColor = UIColor.whiteColor()
            delBtn.setBackgroundImage(UITools.imageWithColor(UIColor(red: 98/255, green: 192/255, blue: 180/255, alpha: 1.0)), forState: UIControlState.Highlighted)
            delBtn.setBackgroundImage(UITools.imageWithColor(UIColor.whiteColor()), forState: UIControlState.Normal)
            delBtn.layer.borderColor = UIColor(red: 98/255, green: 192/255, blue: 180/255, alpha: 1.0).CGColor
            cell?.contentView.addSubview(delBtn)
            delBtn.addTarget(self, action: "delClicked:", forControlEvents: UIControlEvents.TouchUpInside)
        }
        tagsInput.addTarget(self, action: "textChange:", forControlEvents: UIControlEvents.EditingChanged)
        cell?.selectionStyle = UITableViewCellSelectionStyle.None
        return cell!
    }
    
    //输入框文字变化监听事件
    func textChange(sender:AnyObject){
        text = (sender as! UITextField).text!
        if(text.sizeWithAttributes([NSFontAttributeName : UIFont.systemFontOfSize(14)]).width > inputSize.width){
            tagsInput.frame.size.width =  text.sizeWithAttributes([NSFontAttributeName : UIFont.systemFontOfSize(14)]).width
        }
    }
    
    //输入框编辑结束
    func editEnd() {
        let allTags = mTagUtils?.getMyContactTagListWithComFqHalcyonEntityContacts(user)
        var isExist = false
        if (!("" == text)){
            tagsInput.text = ""
            for(var i:Int32 = 0 ; i < datas.size(); i++ ) {
                let tempTag:ComFqHalcyonEntityTag = datas.getWithInt(i) as! ComFqHalcyonEntityTag
                if(text == tempTag.getTitle()){
                    datas.removeWithInt(i)
                    datas.addWithInt(datas.size(), withId: tempTag)
                    mTableView.reloadData()
                    return
                }
            }
            for(var i = 0; i < Int(allTags!.size()); i++){
                if(text == allTags?.getWithInt(Int32(i)).getTitle()){
                    isExist = true
                    datas.addWithId(allTags?.getWithInt(Int32(i)))
                    break
                }
            }
            if(!isExist){
                let tag = ComFqHalcyonEntityTag()
                tag.setIdWithInt(-1)
                tag.setTitleWithNSString(text)
                datas.addWithId(tag)
            }
            mTableView.reloadData()
        }
    }
    //删除按钮点击
    func delClicked(sender:UIButton){
        datas.removeWithInt(Int32(selectedPosition))
        selectedPosition = -1
        mTableView.reloadData()
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if(indexPath.row != selectedPosition && selectedPosition != -1){
            delBtn.removeFromSuperview()
            selectedPosition = -1
        }
        if(tagsInput.isFirstResponder()){
            tagsInput.resignFirstResponder()
        }
        editEnd()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Int(datas.size())+1
    }
}
