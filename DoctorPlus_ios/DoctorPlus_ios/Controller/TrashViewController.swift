//
//  TrashViewController.swift
//  DoctorPlus_ios
//
//  Created by 廖敏 on 15/7/1.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit

class TrashViewController: BaseViewController ,UITableViewDataSource,UITableViewDelegate{

    var mTrashElements = [ComFqHalcyonPracticeTrash_TrashElement]()

    @IBOutlet weak var trashTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let allElement = mTrash.getAllElement()
        for var i:Int32 = 0 ; i < allElement.size() ; i++ {
            mTrashElements.append(allElement.getWithInt(i) as! ComFqHalcyonPracticeTrash_TrashElement)
        }
        setTittle("回收站")
        setRightBtnTittle("清空")
        
        trashTableView.registerNib(UINib(nibName: "TrashCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "TrashCell")
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    override func getXibName() -> String {
        return "TrashViewController"
    }
    
    func deleteListener(sender:UIButton){
        let row = sender.tag
        let element = mTrashElements[row]
        mTrash.deleteFromTrashWithNSString(element.getType(), withInt: element.getId())
        mTrashElements.removeAtIndex(row)
        trashTableView.reloadData()
    }
    
    func resumeListener(sender:UIButton){
        let row = sender.tag
        let element = mTrashElements[row]
        mTrash.resumeFromTrashWithNSString(element.getType(), withInt: element.getId())
        mTrashElements.removeAtIndex(row)
        trashTableView.reloadData()
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TrashCell") as! TrashCell
//        cell.delete.addTarget(self, action: "deleteListener:", forControlEvents: UIControlEvents.TouchUpInside)
//        cell.resume.addTarget(self, action: "resumeListener:", forControlEvents: UIControlEvents.TouchUpInside)
//        cell.name.text = mTrashElements[indexPath.row].getDescription()
//        cell.resume.tag = indexPath.row
//        cell.delete.tag = indexPath.row
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mTrashElements.count
    }
    
  
    
    override func onRightBtnOnClick(sender: UIButton) {
        mTrash.deleteAll()
        mTrashElements = [ComFqHalcyonPracticeTrash_TrashElement]()
        trashTableView.reloadData()
    }
}
