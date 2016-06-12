//
//  SnapItemPhotoMoreViewController.swift
//  DoctorPlus_ios
//
//  Created by XiWang on 15-6-1.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit

class SnapItemPhotoMoreViewController: BaseViewController, UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout {

    
    @IBOutlet weak var photoCollection: UICollectionView!
    var type = 0
    var index = -1
    var oneType:ComFqHalcyonUimodelsOneType?
    var photoList = JavaUtilArrayList()
    var tittleStr:String = ""
    var isEditMode = false
    var currentItemIndex = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        hiddenRightImage(true)
        
        photoCollection.registerNib(UINib(nibName: "SnapItemPhotoMoreCollectionViewCell", bundle:nil), forCellWithReuseIdentifier: "SnapItemPhotoMoreCollectionViewCell")
       let snap =  ComFqLibRecordSnapPhotoManager.getInstance()
        if index != -1 {
            oneType = snap.getTypeByIndexWithInt(Int32(index))
        }
        
        if oneType != nil {
            tittleStr = ComFqLibRecordRecordConstants.getTypeTitleByRecordTypeWithInt(oneType!.getType())
            setTittle(tittleStr)
            photoList = oneType?.getCopyByIdWithInt(0).getPhotos()
            photoCollection.reloadData()
        }
        
        photoCollection.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "OutSideClick:"))
    }
    
    func OutSideClick(gesture:UITapGestureRecognizer){
        setEditMode(false)
    }

    func setEditMode(isEdit:Bool){
        isEditMode = isEdit
        if photoList.size() > 0 {
           photoCollection.reloadData()
        }else {
            ComFqLibRecordSnapPhotoManager.getInstance().getTypes().removeWithId(oneType)
            self.navigationController?.popViewControllerAnimated(true)
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

    override func getXibName() -> String {
        return "SnapItemPhotoMoreViewController"
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("SnapItemPhotoMoreCollectionViewCell", forIndexPath: indexPath) as! SnapItemPhotoMoreCollectionViewCell
        let row = indexPath.row
        cell.contentBtn.setTitle(tittleStr, forState: UIControlState.Normal)
        UITools.setRoundBounds(5.0, view: cell.contentBtn)
        
        if isEditMode {
           cell.icon.hidden = false
        }else {
           cell.icon.hidden = true
        }
        cell.contentBtn.setBackgroundImage(UIImage(named: ""), forState: UIControlState.Normal)

        if row == Int(photoList.size()) {
            cell.icon.hidden = true
            cell.contentBtn.setTitle("", forState: UIControlState.Normal)
            cell.contentBtn.setBackgroundImage(UIImage(named: "btn_cretifi_add_normal.png")!, forState: UIControlState.Normal)
        }
         cell.contentBtn.tag = row
        cell.contentBtn.addTarget(self, action: "BtnClick:", forControlEvents: UIControlEvents.TouchUpInside)
        if row != Int(photoList.size()) {
           cell.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: "cellLongTouch:"))
        }
        
        return cell
    }
    
    func BtnClick(sender:UIButton){
        let row = sender.tag
         print("\(sender.tag)")
        if row == Int(photoList.size()) {
            print("SnapItemPhotoMoreViewController------------拍照")
            ComFqLibRecordSnapPhotoManager.getInstance().setCurrentIndexWithInt(Int32(currentItemIndex))
            let index:Int! = self.navigationController?.viewControllers.count
            let controller: UIViewController = self.navigationController!.viewControllers[index - 4]
            self.navigationController?.popToViewController(controller, animated: true)
        }else {
            if isEditMode {
                deletePhoto(Int32(row))
            }else{
                //跳进图片浏览
                let controller = SnapItemPhotoReviewViewController()
                controller.typeTitle = tittleStr
                controller.photoList = photoList
                self.navigationController?.pushViewController(controller, animated: true)
            }
           
        }
    }
    
    func cellLongTouch(gesture:UILongPressGestureRecognizer){
        setEditMode(true)
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Int(photoList.size() + 1)
    }
    
    func deletePhoto(mIndex:Int32){
        photoList.removeWithInt(mIndex)
        setEditMode(true)
    }
    
}
