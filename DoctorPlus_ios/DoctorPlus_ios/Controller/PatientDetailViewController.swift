//
//  PatientDetailViewController.swift
//  DoctorPlus_ios
//
//  Created by niko on 15/5/14.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit

class PatientDetailViewController: BaseViewController,ComFqHalcyonLogic2SearchPatientDetailLogic_SearchPatientDetailLogicInterface {

    @IBOutlet weak var headImage: UIImageView!
    @IBOutlet weak var nameAndGenderLabel: UILabel!
    @IBOutlet weak var scanBtn: UIButton!
    @IBOutlet weak var mLine: UILabel!
    @IBOutlet weak var mDescription: UITextView!
    var mPatientFriendId:Int32!
    var mPatientFriend:ComFqHalcyonEntityPatientFriend!
    override func viewDidLoad() {
        super.viewDidLoad()
        setTittle("个人详情")
        hiddenRightImage(true)
        getDetail()
        UITools.setBorderWithView(1.0, tmpColor:UIColor(red: 98/255, green: 192/255, blue: 180/255, alpha: 1.0).CGColor, view: headImage)

    }
    
    func getDetail(){
        let mDetailLogic = ComFqHalcyonLogic2SearchPatientDetailLogic(comFqHalcyonLogic2SearchPatientDetailLogic_SearchPatientDetailLogicInterface: self)
        mDetailLogic.searchPatientDetailWithInt(mPatientFriendId)
    }
    
    func onErrorWithInt(code: Int32, withJavaLangThrowable error: JavaLangThrowable!) {
        
    }
    
    func onSearchPatientDetailSuccessWithComFqHalcyonEntityPatientFriend(mFriend: ComFqHalcyonEntityPatientFriend!) {
        mPatientFriend = mFriend
        let photo:ComFqHalcyonEntityPhoto! = ComFqHalcyonEntityPhoto()
        photo.setImageIdWithInt(mFriend.getImageId())
        ApiSystem.getHeadImageWithComFqHalcyonEntityPhoto(photo, withComFqLibCallbackICallback: WapperCallback(onCallback: { (data) -> Void in
            let path:NSString? = data as? NSString
            if(path != nil){
                self.headImage.image = UITools.getImageFromFile(path!)
            }
        }), withBoolean: false, withInt: Int32(2))
        if (mFriend.getPatientFriendGender() == "1") {
            nameAndGenderLabel.text = mFriend.getName()+"   "+"女"
        }else if (mFriend.getPatientFriendGender() == "2"){
            nameAndGenderLabel.text = mFriend.getName()+"   "+"男"
        }
        mDescription.text = mFriend.getDescription()
        
        if (mFriend.getPatientId() != 0) {
            scanBtn.hidden = false
            mLine.hidden = false
        }else{
            UIAlertViewTool.getInstance().showAutoDismisDialog("该患者还未分享病案", width: 210, height: 120)
        }
    }
    
    func onSearchPatientErrorDetailWithInt(code: Int32, withNSString msg: String!) {
        UIAlertViewTool.getInstance().showAutoDismisDialog(msg, width: 210, height: 120)
    }
    
    override func getXibName() -> String {
        return "PatientDetailViewController"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    
    /**查看病案*/
    @IBAction func scan(sender: AnyObject) {
        let patient:ComFqHalcyonEntityPatient! = ComFqHalcyonEntityPatient()
        patient.setMedicalIdWithInt(mPatientFriend.getPatientId())
        patient.setMedicalNameWithNSString(mPatientFriend.getPatientName())
        let controller:RecordListViewController! = RecordListViewController()
        controller.patient = patient
        controller.isNewPatient = controller.ISNOT_NEW_PATIENT
        self.navigationController?.pushViewController(controller, animated: true)
    }

   

}
