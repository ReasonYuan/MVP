//
//  ManageGroupViewController.swift
//  DoctorPlus_ios
//
//  Created by niko on 15/7/20.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit
import HitalesSDK
import RealmSwift

var selcontacts = JavaUtilArrayList()
class ManageGroupViewController:BaseViewController,UICollectionViewDataSource,UICollectionViewDelegate{
    
    @IBOutlet weak var groupNameTextField: UITextField!
    @IBOutlet weak var collevtionView: UICollectionView!
    @IBOutlet weak var tuichuBtn: UIButton!
    
    var mCreaterId:Int?//群主id
    var mGroupId:String?//群id
    var mIsGroupManager = true//是否是群主
    var mIsRemove = false//是否点了删除
    var mOldGroupName = ""//群名字
    var mNewGroupName = ""
    var mOldContacts:JavaUtilArrayList! = JavaUtilArrayList()//群成员
    var mSelContacts:JavaUtilArrayList! = JavaUtilArrayList() //添加或者删除过后的好友list
    
    
    
    
    var loadingDialog:CustomIOS7AlertView!
    var delDialog:CustomIOS7AlertView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTittle(mOldGroupName)
        hiddenRightImage(true)
        
        let groupInfo = HitalesIMSDK.sharedInstance.getOneGroupDetail(mGroupId!,mRealm:try! Realm(path: MessageTools.getHIMRootPath()))
        let ownerId = groupInfo!.createrId
        mCreaterId = Int(ownerId)
        let membersList = groupInfo?.members
        if Int32(ownerId) == ComFqLibToolsConstants.getUser().getUserId() {
            mIsGroupManager = true
        }else{
            mIsGroupManager = false
        }
        
        
        if mIsGroupManager {
            tuichuBtn.setTitle("删除并退出", forState: UIControlState.Normal)
            groupNameTextField.enabled = true
        }else{
            tuichuBtn.setTitle("退出该群", forState: UIControlState.Normal)
            groupNameTextField.enabled = false
        }
        
        let nomalImage = UITools.imageWithColor(UITools.colorWithHexString("32323e"))
        let highLightImage = UITools.imageByApplyingAlpha(0.7, image: nomalImage)

        
        tuichuBtn.setBackgroundImage(nomalImage, forState: UIControlState.Normal)
        tuichuBtn.setBackgroundImage(highLightImage, forState: UIControlState.Highlighted)
        
        groupNameTextField.text = mOldGroupName
        mNewGroupName = mOldGroupName
        
        
        let flowLayout = UICollectionViewFlowLayout()
        
        flowLayout.itemSize = CGSizeMake(60, 60)
        
        flowLayout.scrollDirection = UICollectionViewScrollDirection.Vertical//设置垂直显示
        
        flowLayout.sectionInset = UIEdgeInsetsMake(0, 1, 0, 1)//设置边距
        
        flowLayout.minimumLineSpacing = 0.0;//每个相邻layout的上下
        
        flowLayout.minimumInteritemSpacing = 0.0;//每个相邻layout的左右
        
        flowLayout.headerReferenceSize = CGSizeMake(0, 0);
        self.collevtionView.collectionViewLayout = flowLayout
        collevtionView.registerNib(UINib(nibName: "ManagerGroupCollectionViewCell", bundle:nil) ,forCellWithReuseIdentifier: "ManagerGroupCollectionViewCell")
        collevtionView.backgroundColor = UIColor.whiteColor()
        
        
        
        
        groupNameTextField.addTarget(self, action: "textFieldDidChange:", forControlEvents: UIControlEvents.EditingChanged)
        
        
       
        
        for m in membersList! {
            let contact = ComFqHalcyonEntityContacts()
            var imageId:Int32?
            if m.imageId == "null" {
                imageId = 0
            }else{
                imageId = Int32(Int(m.imageId)!)
            }
            
            let name = m.username
            let id = Int32(m.memberUserId)!
            contact.setNameWithNSString(name)
            contact.setUserIdWithInt(id)
            contact.setImageIdWithInt(imageId!)
            
            if Int32(mCreaterId!) == id {
                mOldContacts.addWithInt(0, withId: contact)
            }else{
                mOldContacts.addWithId(contact)

            }
            
            
        }
        mSelContacts.addAllWithJavaUtilCollection(mOldContacts)
        collevtionView.reloadData()
        
    }
    
    override func onLeftBtnOnClick(sender: UIButton) {
        groupNameTextField.resignFirstResponder()
        if mOldGroupName != mNewGroupName {
            loadingDialog = UIAlertViewTool.getInstance().showLoadingDialog("修改群信息，请稍后...")
            
            HitalesIMSDK.sharedInstance.modifyGroupName(mGroupId!, groupName: mNewGroupName, success: { () -> Void in
                self.loadingDialog.close()
                MessageTools.updateRecentContact(self.mGroupId!, name: self.mNewGroupName)
                
                (self.navigationController?.viewControllers[self.navigationController!.viewControllers.count - 2] as! MoreChatViewController).setTittle(self.mNewGroupName)
                (self.navigationController?.viewControllers[self.navigationController!.viewControllers.count - 2] as! MoreChatViewController).tittleStr = self.mNewGroupName
                self.navigationController?.popViewControllerAnimated(true)
            }, failure: { (error) -> Void in
                self.loadingDialog.close()
//                (self.navigationController?.viewControllers[self.navigationController!.viewControllers.count - 2] as! MoreChatViewController).view.makeToast("修改失败")
                FQToast.makeError().show("修改失败", superview: (self.navigationController?.viewControllers[self.navigationController!.viewControllers.count - 2] as! MoreChatViewController).view)
                self.navigationController?.popViewControllerAnimated(true)
            })
            
        }else {
            self.navigationController?.popViewControllerAnimated(true)
        }
        
    }
    
    func textFieldDidChange(textField:UITextField){
        mNewGroupName = textField.text!
    }
    
    
    /**退出删除*/
    @IBAction func tuichu(sender: AnyObject) {
        if mIsGroupManager {
            print("删除并退出")
            delDialog = UIAlertViewTool.getInstance().showNewDelDialog("确认删除并退出？", target: self, actionOk: "delgroup", actionCancle: "cancel")

        }else{
            print("退出群组")
            delDialog = UIAlertViewTool.getInstance().showNewDelDialog("确认退出群组？", target: self, actionOk: "tuichu", actionCancle: "quxiao")
        }
    }
    
    func delgroup(){
        delDialog.close()
        loadingDialog = UIAlertViewTool.getInstance().showLoadingDialog("删除中...")
        
        HitalesIMSDK.sharedInstance.deleteGroup(mGroupId!, success: { () -> Void in
            self.loadingDialog.close()
            MessageTools.removeMorechatList(self.mGroupId!)
            let index:Int! = self.navigationController?.viewControllers.count
            self.navigationController?.viewControllers.removeAtIndex(index - 2)
            self.navigationController?.popViewControllerAnimated(true)
        }) { (error) -> Void in
            self.loadingDialog.close()
//            self.view.makeToast("删除讨论组失败")
            FQToast.makeError().show("删除讨论组失败", superview: self.view)
        }
        
    }
    
    func cancel(){
        delDialog.close()
    }
    
    func tuichu(){
        self.delDialog.close()
        loadingDialog = UIAlertViewTool.getInstance().showLoadingDialog("退出中...")
        
        HitalesIMSDK.sharedInstance.quitGroup(mGroupId!, success: { () -> Void in
            self.loadingDialog.close()
            MessageTools.removeMorechatList(self.mGroupId!)
            let index:Int! = self.navigationController?.viewControllers.count
            self.navigationController?.viewControllers.removeAtIndex(index - 2)
            self.navigationController?.popViewControllerAnimated(true)
        }) { (error) -> Void in
            self.loadingDialog.close()
//            self.view.makeToast("退出讨论组失败")
            FQToast.makeError().show("退出讨论组失败", superview: self.view)

        }

    }
    
    func quxiao(){
        delDialog.close()
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
        return "ManageGroupViewController"
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ManagerGroupCollectionViewCell", forIndexPath: indexPath) as!
        ManagerGroupCollectionViewCell
        
        UITools.setBorderWithHeadKuang(cell.headKuang)
        let rect:CGRect? = cell.headImage.bounds
        UITools.setRoundBounds(CGRectGetHeight(rect!)/2, view: cell.headImage)
        
        
        
        if mIsGroupManager {//群主能删好友
            if mIsRemove {
                cell.removeState.hidden = false
                if indexPath.row == 0 {
                    cell.removeState.hidden = true
                }
            }else{
                cell.removeState.hidden = true
            }
            
            if indexPath.row == Int(mSelContacts.size()) {
                cell.removeState.hidden = true
                cell.addCastans.hidden = false
                cell.delCastans.hidden = true
                cell.headKuang.hidden = true
                cell.headImage.hidden = true
                cell.addCastans.addTarget(self, action: "addCastans", forControlEvents: UIControlEvents.TouchUpInside)
                
            }else if mSelContacts.size() > 0 && indexPath.row == Int(mSelContacts.size())+1 {
                cell.removeState.hidden = true
                cell.delCastans.hidden = false
                cell.addCastans.hidden = true
                cell.headKuang.hidden = true
                cell.headImage.hidden = true
                cell.delCastans.addTarget(self, action: "delCastans", forControlEvents: UIControlEvents.TouchUpInside)
            }else{
                cell.addCastans.hidden = true
                cell.delCastans.hidden = true
                cell.headKuang.hidden = false
                cell.headImage.hidden = false
                let contacts:ComFqHalcyonEntityContacts! = mSelContacts.getWithInt(Int32(indexPath.row)) as! ComFqHalcyonEntityContacts
                let photo:ComFqHalcyonEntityPhoto! = ComFqHalcyonEntityPhoto()
                photo.setImageIdWithInt(contacts.getImageId())
                ApiSystem.getHeadImageWithComFqHalcyonEntityPhoto(photo, withComFqLibCallbackICallback: WapperCallback(onCallback: { (data) -> Void in
                    let path:NSString? = data as? NSString
                    if(path != nil){
                        cell.headImage.image = UITools.getImageFromFile(path!)
                    }else {
                        cell.headImage.image = UIImage(named: "icon_head_default.png")
                    }
                }), withBoolean: false, withInt: Int32(2))
                
            }
            
        }else{//群成员不能删好友
            cell.delCastans.hidden = true
            cell.removeState.hidden = true
            
            if indexPath.row == Int(mSelContacts.size()) {
                cell.addCastans.hidden = false
                cell.headKuang.hidden = true
                cell.headImage.hidden = true
                cell.addCastans.addTarget(self, action: "addCastans", forControlEvents: UIControlEvents.TouchUpInside)
            }else{
                cell.addCastans.hidden = true
                cell.headKuang.hidden = false
                cell.headImage.hidden = false
                let contacts:ComFqHalcyonEntityContacts! = mSelContacts.getWithInt(Int32(indexPath.row)) as! ComFqHalcyonEntityContacts
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
        if !mIsRemove || indexPath.row == Int(mSelContacts.size()) || indexPath.row == Int(mSelContacts.size()+1) || indexPath.row == 0 {
            return
        }
        let loading = UIAlertViewTool.getInstance().showLoadingDialog("删除中...")
        let contact:ComFqHalcyonEntityContacts! = mSelContacts.getWithInt(Int32(indexPath.row)) as! ComFqHalcyonEntityContacts
        
        
        HitalesIMSDK.sharedInstance.removeMemberFromGroup("\(contact.getUserId())", groupID: mGroupId!, success: { () -> Void in
            self.mSelContacts.removeWithInt(Int32(indexPath.row))
            
            
            if self.mSelContacts.size() == 1 {
                self.mIsRemove = false
            }
            self.collevtionView.reloadData()
            loading.close()

        }) { (error) -> Void in
//            self.view.makeToast("删除群成员失败")
            FQToast.makeError().show("删除群成员失败", superview: self.view)

            loading.close()
        }
        

        
    }
    
    /**添加群成员*/
    func addCastans(){
        if mIsRemove {
            mIsRemove = false
            collevtionView.reloadData()
            return
        }
        print("添加成员")
        let controller:SelectContactViewController! = SelectContactViewController()
        
        
        let ints = JavaUtilArrayList()
        for var i = 0 ; i < Int(mSelContacts.size()) ; i++ {
            let user:ComFqHalcyonEntityContacts! = mSelContacts.getWithInt(Int32(i)) as! ComFqHalcyonEntityContacts
            ints.addWithId(JavaLangInteger(int: user.getUserId()))
        }
        controller.ints = ints
        controller.isCreatGroup = false
        controller.groupId = mGroupId!
        
        self.navigationController?.pushViewController(controller, animated: true)
    }
    /**删除群成员*/
    func delCastans(){
        print("删除成员")
        if mSelContacts.size() == 1{
            return
        }
        mIsRemove = !mIsRemove
        collevtionView.reloadData()
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if mIsGroupManager {
            if mSelContacts.size() > 0{
                return Int(mSelContacts.size()) + 2
            }else{
                return Int(mSelContacts.size()) + 1
            }
        }else{
            return Int(mSelContacts.size()) + 1
        }
        
        
    }
    
    /*!
    * 判断是否有网络连接
    */
    func isNetWorkOK()->Bool{
        return Tools.isNetWorkConnect()
    }
    
   
    
}