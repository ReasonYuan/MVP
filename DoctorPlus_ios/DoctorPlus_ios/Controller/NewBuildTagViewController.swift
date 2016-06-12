//
//  NewBuildTagViewController.swift
//  DoctorPlus_ios
//
//  Created by niko on 15/6/1.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit


class NewBuildTagViewController: BaseViewController,UICollectionViewDataSource,UICollectionViewDelegate,ComFqHalcyonLogic2TagLogic_OnTagModifyCallback,ComFqHalcyonLogic2ContactLogic_ContactLogicInterface,ComFqHalcyonLogic2TagLogic_SuccessCallBack,ComFqHalcyonLogic2TagLogic_FailCallBack {
    
    @IBOutlet weak var mTextNote: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tagName: UITextField!
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var delTagBtn: UIButton!
    @IBOutlet weak var collevtionView: UICollectionView!
    var mOldContacts:JavaUtilArrayList!
    var mSelContacts:JavaUtilArrayList! = JavaUtilArrayList()
    var mTag:ComFqHalcyonEntityTag!
    var mTagList:JavaUtilArrayList? = ComFqLibToolsConstants_tagList_
    var mIsTagExise = false
    var mIsRemove = false
    var loadingDialog:CustomIOS7AlertView!
    var delDialog:CustomIOS7AlertView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hiddenRightImage(true)
        UITools.setButtonWithColor(ColorType.EMERALD, btn: saveBtn, isOpposite: false)
        UITools.setButtonWithColor(ColorType.EMERALD, btn: delTagBtn, isOpposite: false)
        
        
        let flowLayout = UICollectionViewFlowLayout()
        
        flowLayout.itemSize = CGSizeMake(60, 68)
        
        flowLayout.scrollDirection = UICollectionViewScrollDirection.Vertical//设置垂直显示
        
        flowLayout.sectionInset = UIEdgeInsetsMake(0, 1, 0, 1)//设置边距
        
        flowLayout.minimumLineSpacing = 0.0;//每个相邻layout的上下
        
        flowLayout.minimumInteritemSpacing = 0.0;//每个相邻layout的左右
        
        flowLayout.headerReferenceSize = CGSizeMake(0, 0);
        self.collevtionView.collectionViewLayout = flowLayout
        collevtionView.registerNib(UINib(nibName: "NewBuildTagCollectionViewCell", bundle:nil) ,forCellWithReuseIdentifier: "NewBuildTagCollectionViewCell")
        collevtionView.backgroundColor = UIColor.whiteColor()
        
        if mTag.getId() == 0 {
            setTittle("新建标签")
            titleLabel.text = "新建标签"
        }else{
            setTittle("编辑标签")
            titleLabel.text = "编辑标签"
            mOldContacts = JavaUtilArrayList()
            mSelContacts.addAllWithJavaUtilCollection(mTag.getContacts())
            mOldContacts.addAllWithJavaUtilCollection(mTag.getContacts())
            tagName.text = mTag.getTitle()
            delTagBtn.hidden = false
        }
        
        tagName.addTarget(self, action: "textFieldDidChange:", forControlEvents: UIControlEvents.EditingChanged)
        
    }
    func textFieldDidChange(textField:UITextField){
        let tag = textField.text
        if mTag.getTitle() != nil  && tag == mTag.getTitle() {
            mIsTagExise = false
            mTextNote.hidden = true
            return
        }
        if mTagList != nil{
            for var i = 0 ; i < Int(mTagList!.size()) ; i++ {
                if tag == mTagList!.getWithInt(Int32(i)).getTitle() {
                    mTextNote.hidden = false
                    mIsTagExise = true
                    break
                }else{
                    mIsTagExise = false
                    mTextNote.hidden = true
                }
            }
            
        }
        
    }
    
    override func viewWillAppear(animated: Bool) {
        if selcontacts.size() != 0 {
            mSelContacts.addAllWithJavaUtilCollection(selcontacts)
            selcontacts.clear()
            collevtionView.reloadData()
            
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func getXibName() -> String {
        return "NewBuildTagViewController"
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("NewBuildTagCollectionViewCell", forIndexPath: indexPath) as! NewBuildTagCollectionViewCell
        
        UITools.setBorderWithHeadKuang(cell.headKuang)
        let rect:CGRect? = cell.headImage.bounds
        UITools.setRoundBounds(CGRectGetHeight(rect!)/2, view: cell.headImage)
        
        if mIsRemove {
            cell.removeState.hidden = false
        }else{
            cell.removeState.hidden = true
        }
        
        if mSelContacts.size() == 0{
            cell.removeState.hidden = true
            cell.addCastans.hidden = false
            cell.delCastans.hidden = true
            cell.nameLabel.hidden = true
            cell.headKuang.hidden = true
            cell.headImage.hidden = true
            cell.addCastans.addTarget(self, action: "addCastans", forControlEvents: UIControlEvents.TouchUpInside)
            setaddCastansstate(cell.addCastans)
            
        }else{
            if indexPath.row == Int(mSelContacts.size()) {
                cell.removeState.hidden = true
                cell.addCastans.hidden = false
                cell.delCastans.hidden = true
                cell.nameLabel.hidden = true
                cell.headKuang.hidden = true
                cell.headImage.hidden = true
                cell.addCastans.addTarget(self, action: "addCastans", forControlEvents: UIControlEvents.TouchUpInside)
                setaddCastansstate(cell.addCastans)
            }else if mSelContacts.size() > 0 && indexPath.row == Int(mSelContacts.size())+1 {
                cell.removeState.hidden = true
                cell.delCastans.hidden = false
                cell.addCastans.hidden = true
                cell.nameLabel.hidden = true
                cell.headKuang.hidden = true
                cell.headImage.hidden = true
                cell.delCastans.addTarget(self, action: "delCastans", forControlEvents: UIControlEvents.TouchUpInside)
                setdelCastansstate(cell.delCastans)
            }else{
                
                cell.addCastans.hidden = true
                cell.delCastans.hidden = true
                cell.nameLabel.hidden = false
                cell.headKuang.hidden = false
                cell.headImage.hidden = false
                let contacts:ComFqHalcyonEntityContacts! = mSelContacts.getWithInt(Int32(indexPath.row)) as! ComFqHalcyonEntityContacts
                cell.nameLabel.text = contacts.getUsername()
                let photo:ComFqHalcyonEntityPhoto! = ComFqHalcyonEntityPhoto()
                photo.setImageIdWithInt(contacts.getImageId())
                ApiSystem.getHeadImageWithComFqHalcyonEntityPhoto(photo, withComFqLibCallbackICallback: WapperCallback(onCallback: { (data) -> Void in
                    let path:NSString? = data as? NSString
                    if(path != nil){
                        cell.headImage.image = UITools.getImageFromFile(path!)
                    }
                }), withBoolean: false, withInt: Int32(2))
                
            }
            
        }
        
        
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if !mIsRemove || indexPath.row == Int(mSelContacts.size()) || indexPath.row == Int(mSelContacts.size()+1) {
            return
        }
        
        mSelContacts.removeWithInt(Int32(indexPath.row))
        collevtionView.reloadData()
        
        if mSelContacts.size() == 0 {
            mIsRemove = false
        }
    }
    
    func addCastans(){
        if mIsRemove {
            mIsRemove = false
            collevtionView.reloadData()
            return
        }
        print("添加成员")
        let controller:SelectContactsViewController! = SelectContactsViewController()
        
        if mSelContacts.size() != 0 {
            let ints = JavaUtilArrayList()
            for var i = 0 ; i < Int(mSelContacts.size()) ; i++ {
                let user:ComFqHalcyonEntityContacts! = mSelContacts.getWithInt(Int32(i)) as! ComFqHalcyonEntityContacts
                ints.addWithId(JavaLangInteger(int: user.getUserId()))
            }
//            controller.ints = ints
        }
        
        self.navigationController?.pushViewController(controller, animated: true)
    }
    func delCastans(){
        print("删除成员")
        mIsRemove = !mIsRemove
        collevtionView.reloadData()
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if mSelContacts.size() > 0{
            return Int(mSelContacts.size()) + 2
        }else{
            return Int(mSelContacts.size()) + 1
        }
        
    }
    func onAddTag(){
        if !isNetWorkOK() {
            UIAlertViewTool.getInstance().showAutoDismisDialog("不支持离线操作", width: 210, height: 120)
            return
        }
        if tagName.text == "" {
            UIAlertViewTool.getInstance().showAutoDismisDialog("请输入标签", width: 210, height: 120)
            return
        }
        if mIsTagExise {
            UIAlertViewTool.getInstance().showAutoDismisDialog("标签已存在", width: 210, height: 120)
            return
        }
        loadingDialog = UIAlertViewTool.getInstance().showLoadingDialog("正在提交数据，请稍后...")
        var logic =  ComFqHalcyonLogic2TagLogic()
        if mSelContacts.size() == 0 {
            logic.addTagWithNSString(tagName.text, withComFqHalcyonLogic2TagLogic_OnTagModifyCallback: self)
        }else{
            var docids:IOSIntArray! =  IOSIntArray.arrayWithLength(UInt(mSelContacts.size()))  as! IOSIntArray
            for var  i = 0 ; i < Int(mSelContacts.size()); i++ {
                Extend.setJavaIntArrayValue(mSelContacts.getWithInt(Int32(i)).getUserId(), forIndex: Int32(i), forArray: docids)
            }
            var titles:IOSObjectArray! = IOSObjectArray.arrayWithLength(1, type: nil) as! IOSObjectArray
            Extend.setJavaObjectArrayValue(NSString(string: tagName.text!) , forIndex: 0, forArray: titles)
            logic.modifyTagContactWithIntArray(docids, withIntArray: nil, withNSStringArray: titles, withIntArray: nil, withIntArray: nil, withComFqHalcyonLogic2TagLogic_OnTagModifyCallback:self)
        }
        
    }
    
    @IBAction func saveTag(sender: AnyObject) {
        if !isNetWorkOK() {
            UIAlertViewTool.getInstance().showAutoDismisDialog("不支持离线操作", width: 210, height: 120)
            return
        }
        if tagName.text == "" {
            UIAlertViewTool.getInstance().showAutoDismisDialog("请输入标签", width: 210, height: 120)
            return
        }
        if mIsTagExise {
            UIAlertViewTool.getInstance().showAutoDismisDialog("标签已存在", width: 210, height: 120)
            return
        }
        
        let tag = tagName.text
        if mTag.getId() == 0 {
            onAddTag()
        }else{
            if tag != mTag.getTitle(){
                let tmpTag = ComFqHalcyonEntityTag()
                tmpTag.setIdWithInt(mTag.getId())
                tmpTag.setTitleWithNSString(tag)
                ComFqHalcyonLogic2TagLogic().modifyTagWithComFqHalcyonEntityTag(tmpTag, withComFqHalcyonLogic2TagLogic_OnTagModifyCallback: self)
            }
            
            let addDocPIds = getAddDocPatIds()
            let remDocPIds = getRemoveDocPayIds()
            let ids: IOSIntArray! = IOSIntArray.arrayWithLength(1) as! IOSIntArray
            Extend.setJavaIntArrayValue(mTag.getId(), forIndex: 0, forArray: ids)
//            var titles = IOSObjectArray()
            loadingDialog = UIAlertViewTool.getInstance().showLoadingDialog("正在提交数据，请稍后...")
            ComFqHalcyonLogic2TagLogic().modifyTagContactWithIntArray(addDocPIds, withIntArray: ids, withNSStringArray: nil, withIntArray: remDocPIds, withIntArray: ids, withComFqHalcyonLogic2TagLogic_OnTagModifyCallback: self)
            
            
        }
    }
    
    func getAddDocPatIds()->IOSIntArray?{
        let ids = JavaUtilArrayList()
        for var i = 0 ; i < Int(mSelContacts.size()) ; i++ {
            let user:ComFqHalcyonEntityContacts! = mSelContacts.getWithInt(Int32(i)) as! ComFqHalcyonEntityContacts
            if !(isRecordInArray(user.getUserId(), users: mOldContacts)) {
                ids.addWithId(JavaLangInteger(int: user.getUserId()))
            }
        }
        
        if ids.size() > 0 {
            let addids:IOSIntArray! = IOSIntArray.arrayWithLength(UInt(ids.size())) as! IOSIntArray
            for var i = 0 ; i < Int(ids.size()) ; i++ {
                Extend.setJavaIntArrayValue(ids.getWithInt(Int32(i)).intValue, forIndex: Int32(i), forArray: addids)
                
            }
            return addids
        }else{
            return nil
        }
        
    }
    
    func getRemoveDocPayIds()->IOSIntArray?{
        let ids = JavaUtilArrayList()
        for var i = 0 ; i < Int(mOldContacts.size()) ; i++ {
            let user:ComFqHalcyonEntityContacts! = mOldContacts.getWithInt(Int32(i)) as! ComFqHalcyonEntityContacts
            if !(isRecordInArray(user.getUserId(), users: mSelContacts)) {
                ids.addWithId(JavaLangInteger(int: user.getUserId()))
                let tags = user.getTags()
                for var j = 0 ; j < Int(tags.size()) ; j++ {
                    if mTag.getTitle() == tags.getWithInt(Int32(j)) as! NSString{
                        tags.removeWithInt(Int32(j))
                       break
                    }
                    
                }
            }
        }
        
        if ids.size() > 0 {
            let removeids:IOSIntArray! = IOSIntArray.arrayWithLength(UInt(ids.size())) as! IOSIntArray
            for var i = 0 ; i < Int(ids.size()) ; i++ {
                Extend.setJavaIntArrayValue(ids.getWithInt(Int32(i)).intValue, forIndex: Int32(i), forArray: removeids)
            }
            return removeids
        }else{
            return nil
        }
        
    }
    
    func isRecordInArray(id:Int32, users:JavaUtilArrayList)->Bool{
        
        for var i = 0 ; i < Int(users.size()) ; i++ {
            let red:ComFqHalcyonEntityContacts! = users.getWithInt(Int32(i)) as! ComFqHalcyonEntityContacts
            if red.getUserId() == id {
                return true
            }
        }
        
        return false
    }
    
    func onModifySuccessWithBoolean(isb: Bool) {
        if isb {
            ComFqHalcyonLogic2ContactLogic(comFqHalcyonLogic2ContactLogic_ContactLogicInterface: self, withInt: ComFqLibToolsConstants.getUser().getUserId())
        }else{
            UIAlertViewTool.getInstance().showAutoDismisDialog("添加标签失败", width: 210, height: 120)
            loadingDialog.close()
        }
        
    }
    func onErrorWithInt(code: Int32, withJavaLangThrowable e: JavaLangThrowable!) {
        loadingDialog.close()
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func onDataReturnWithJavaUtilHashMap(mHashPeerList: JavaUtilHashMap!) {
        loadingDialog.close()
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    
    func onSuccessWithComFqHalcyonEntityTag(tag: ComFqHalcyonEntityTag!) {
        
        if tag != nil {
            for var i = 0 ; i < Int(ComFqLibToolsConstants_tagList_.size()) ; i++ {
                let tg:ComFqHalcyonEntityTag! = ComFqLibToolsConstants_tagList_.getWithInt(Int32(i)) as! ComFqHalcyonEntityTag
                if tg.getId() == tag.getId() {
                    tg.setTitleWithNSString(tag.getTitle())
                    tg.setCountWithInt(tag.getCount())
                    break
                }
                
            }
        }
        
        loadingDialog.close()
    }
    
    
    func addTagWithComFqHalcyonEntityTag(tag: ComFqHalcyonEntityTag!) {
        
        loadingDialog.close()
        ComFqLibToolsConstants_tagList_.addWithId(tag)
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    
    @IBAction func delTag(sender: AnyObject) {
        
        
        onRemoveTag()
        
    }
    
    func onRemoveTag(){
        if !isNetWorkOK() {
            return
        }
        if mTag.getId() == 0 {
            return
        }
        delDialog = UIAlertViewTool.getInstance().showNewDelDialog("确认要删除此标签" + mTag.getTitle() + "?", target: self, actionOk: "sureDel", actionCancle: "cancleDel")
        
    }
    
    func sureDel(){
        delDialog.close()
        deltag(mTag.getTitle())
    }
    
    func cancleDel(){
        delDialog.close()
    }
    
    func deltag(tagName:String){
        loadingDialog = UIAlertViewTool.getInstance().showLoadingDialog("正在提交数据，请稍后...")
        let taglist = ComFqLibToolsConstants_tagList_
        let tagId = JavaUtilArrayList()
        
        for var i = 0 ; i < Int(taglist.size()) ; i++ {
            if tagName == taglist.getWithInt(Int32(i)).getTitle(){
                tagId.addWithId( JavaLangInteger(int: taglist.getWithInt(Int32(i)).getId()))
            }
        }
        
        let logic = ComFqHalcyonLogic2TagLogic()
        logic.delTagWithJavaUtilArrayList(tagId, withComFqHalcyonLogic2TagLogic_SuccessCallBack: self, withComFqHalcyonLogic2TagLogic_FailCallBack: self)
    }
    
    func onSuccessWithInt(responseCode: Int32, withNSString msg: String!, withInt type: Int32, withId results: AnyObject!) {
        loadingDialog.close()
        UIAlertViewTool.getInstance().showAutoDismisDialog("删除成功", width: 210, height: 120)
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func onFailWithInt(code: Int32, withNSString msg: String!) {
        loadingDialog.close()
        UIAlertViewTool.getInstance().showAutoDismisDialog("删除失败", width: 210, height: 120)
    }
    
    
    /*!
    * 判断是否有网络连接
    */
    func isNetWorkOK()->Bool{
//        var remoteHostStatus:NetworkStatus = Tools.getNetWorkState()
//        if remoteHostStatus == NetworkStatus.NotReachable {
//            return false
//        }
        return Tools.isNetWorkConnect()
    }
    
    /**添加成员按钮的点击效果*/
    func setaddCastansstate(btn:UIButton!){
        
        
        btn.setTitleColor(UIColor(red:181/255.0,green:181/255.0,blue:181/255.0,alpha:1), forState: UIControlState.Normal)
        btn.setTitleColor(UIColor.blackColor(), forState: UIControlState.Highlighted)
        btn.setBackgroundImage(UITools.imageWithColor(UIColor(red:235/255.0,green:97/255.0,blue:0/255.0,alpha:1)), forState: UIControlState.Normal)
        btn.setBackgroundImage(UITools.imageWithColor(UIColor(red:240/255.0,green:147/255.0,blue:116/255.0,alpha:1)), forState: UIControlState.Highlighted)
        
        
    }
    /**删除成员按钮的点击效果*/
    func setdelCastansstate(btn:UIButton!){
        btn.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Highlighted)
        btn.setTitleColor(UIColor(red: 170/255.0, green: 170/255.0, blue: 170/255.0, alpha: 1), forState: UIControlState.Normal)
        btn.setBackgroundImage(UITools.imageWithColor(UIColor.whiteColor()), forState: UIControlState.Normal)
        btn.setBackgroundImage(UITools.imageWithColor(UIColor(red: 170/255.0, green: 170/255.0, blue: 170/255.0, alpha: 1)), forState: UIControlState.Highlighted)
        btn.layer.borderWidth = 1.0
        btn.layer.borderColor = UIColor(red: CGFloat(140.0/255.0), green: CGFloat(205.0/255.0), blue: CGFloat(197.0/255.0), alpha: CGFloat(1)).CGColor
        
    }
    
    
}
