//
//  MedicalAnalysisViewController.swift
//  DoctorPlus_ios
//
//  Created by niko on 15/5/20.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit

class MedicalAnalysisViewController: BaseViewController ,UITableViewDataSource,UITableViewDelegate,ComFqHalcyonLogic2RequestMedicineLogic_RequetMedicineInf{

    var loadingDialog:CustomIOS7AlertView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var keyWordsTextField: UITextField!
    @IBOutlet weak var mTableView: UITableView!
    var mMedicines = [ComFqHalcyonEntityMedicine]()
    var keyWords = ""
    var mSelectedItem = -1
    @IBOutlet weak var sureButton: UIButton!
    @IBAction func sureButtonClicked(sender: AnyObject) {
        let txt = nameLabel.text
        if(txt == nil || "" == txt){
            return
        }
        let data = ComFqHalcyonEntityVisualizeVisualData(comFqHalcyonEntityVisualizeVisualizeEntity_VISUALTYPEEnum: (ComFqHalcyonEntityVisualizeVisualizeEntity_VISUALTYPEEnum.values().objectAtIndex(UInt(ComFqHalcyonEntityVisualizeVisualizeEntity_VISUALTYPE_DRUGS.rawValue)) as! ComFqHalcyonEntityVisualizeVisualizeEntity_VISUALTYPEEnum))
        let controller = VisualChoosePatientViewController()
        controller.data = data
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTittle("药物分析图表")
        hiddenRightImage(true)
        sureButton.enabled = false
        UITools.setRoundBounds(5, view: sureButton)
        UITools.setButtonWithColor(ColorType.EMERALD, btn: sureButton, isOpposite: false)
        nameLabel.lineBreakMode = NSLineBreakMode.ByTruncatingTail
        getMedicineList()
        mTableView.dataSource = self
        mTableView.delegate = self
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyWordsChange:", name: UITextFieldTextDidChangeNotification, object: keyWordsTextField)
    }

    override func getXibName() -> String {
        return "MedicalAnalysisViewController"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Int(mMedicines.count)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "cell"
        var cell: UITableViewCell? = (tableView.dequeueReusableCellWithIdentifier(cellIdentifier))
        if(cell == nil){
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: cellIdentifier)
        }
        cell!.textLabel!.font = UIFont.systemFontOfSize(14.0)
        cell!.textLabel!.text = mMedicines[indexPath.row].getName()
        if(indexPath.row == mSelectedItem){
            cell!.textLabel!.textColor = UIColor(red: 98/255, green: 192/255, blue: 180/255, alpha: 1.0)
        }else{
            cell!.textLabel!.textColor = UIColor.blackColor()
        }
        return cell!
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        mSelectedItem = indexPath.row
        nameLabel.text = mMedicines[indexPath.row].getName()
        if(nameLabel.text != nil && nameLabel.text != ""){
            sureButton.enabled = true
        }else{
            sureButton.enabled = false
        }
        tableView.reloadData()
    }
    
    //获取药物列表
    func getMedicineList(){
        loadingDialog = UIAlertViewTool.getInstance().showLoadingDialog("获取药物列表...")
        ComFqHalcyonLogic2RequestMedicineLogic().requestMedicineWithComFqHalcyonLogic2RequestMedicineLogic_RequetMedicineInf(self, withNSString: keyWords)
    }
    
    //回调
    func feedMedicineWithJavaUtilArrayList(medicine: JavaUtilArrayList!) {
        mMedicines.removeAll(keepCapacity: true)
        for var i = 0; i < Int(medicine.size()); i++ {
            mMedicines.append(medicine.getWithInt(Int32(i)) as! ComFqHalcyonEntityMedicine)
        }
        mTableView.reloadData()
        loadingDialog.close()
    }
    
    func onErrorWithInt(code: Int32, withJavaLangThrowable error: JavaLangThrowable!) {
        loadingDialog.close()
        UIAlertViewTool.getInstance().showAutoDismisDialog("获取药物列表失败", width: 210, height: 120)
    }

    func keyWordsChange(sender:NSNotification){
        if(keyWordsTextField.text != nil){
            keyWords = keyWordsTextField.text!
            getMedicineList()
        }
    }
}
