//
//  BrowRecordTopView.swift
//  DoctorPlus_ios
//
//  Created by XiWang on 15-5-19.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit

class BrowRecordTopView: UIView,iCarouselDataSource, iCarouselDelegate {
    @IBOutlet weak var carousel: iCarousel!
    var items: [Int] = []
    var topViewIndexCallBack:TopViewCurrentIndexCallBack?
    var itemList = JavaUtilArrayList()
    var mRecordTypesList = JavaUtilArrayList()
    var size = 0
    override init(frame: CGRect) {
        super.init(frame: frame)
        let view = NSBundle.mainBundle().loadNibNamed("BrowRecordTopView", owner: self, options: nil)[0] as! UIView
        view.frame = CGRectMake(0, 0, frame.size.width, frame.size.height)
        self.addSubview(view)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initData(mRecordTypes:JavaUtilArrayList){
        itemList.clear()
        mRecordTypesList.clear()
        mRecordTypesList = mRecordTypes
        size = Int(mRecordTypes.size())
        for i in 0..<size
        {
            itemList.addAllWithJavaUtilCollection((mRecordTypes.getWithInt(Int32(i)) as! ComFqHalcyonEntityRecordType).getItemList())
        }
       
        carousel.delegate = self
        carousel.dataSource = self
        carousel.type = .Linear
        carousel.pagingEnabled = true
        carousel.reloadData()
    }
    
    func refreshData(mRecordTypes:JavaUtilArrayList){
         mRecordTypesList = mRecordTypes
        itemList.clear()
        size = Int(mRecordTypes.size())
        for i in 0..<size
        {
            itemList.addAllWithJavaUtilCollection((mRecordTypes.getWithInt(Int32(i)) as! ComFqHalcyonEntityRecordType).getItemList())
        }
        carousel.reloadData()
    }


    func numberOfItemsInCarousel(carousel: iCarousel!) -> Int
    {
        return size
    }
    
    func carousel(carousel: iCarousel!, viewForItemAtIndex index: Int, reusingView view: UIView!) -> UIView! {
        var tmpView = view
        if (tmpView == nil)
        {
            tmpView = BrowRecordTopItem(frame: carousel.bounds)
        }
        var count:Int32 = 0
        let record:ComFqHalcyonEntityRecordType = mRecordTypesList.getWithInt(Int32(index)) as! ComFqHalcyonEntityRecordType
        if record.getItemWithInt(0).getRecStatus() != ComFqHalcyonEntityRecordItemSamp_REC_NONE_DATA {
            count = (record.getItemList() as JavaUtilArrayList).size()
        }
        (tmpView as! BrowRecordTopItem).centerLabel.text = "\(ComFqLibRecordRecordConstants.getTypeTitleByRecordTypeWithInt(record.getRecordType()))(\(count))"
        
        var lf:Int32 = Int32(index) - 1
        var rf:Int32 = Int32(index) + 1
        var recordType = record.getRecordType()
        
        if lf < 0 {
            lf = mRecordTypesList.size() - 1
        }
        
        if rf == mRecordTypesList.size() {
            rf =  0
        }
        
        (tmpView as! BrowRecordTopItem).leftLabel.text = "\(ComFqLibRecordRecordConstants.getTypeTitleByRecordTypeWithInt(mRecordTypesList.getWithInt(lf).getRecordType()))"
        (tmpView as! BrowRecordTopItem).rightLabel.text = "\(ComFqLibRecordRecordConstants.getTypeTitleByRecordTypeWithInt(mRecordTypesList.getWithInt(rf).getRecordType()))"
        return tmpView
    }
    
    
    func carousel(mCarousel: iCarousel!, valueForOption option: iCarouselOption, withDefault value: CGFloat) -> CGFloat
    {
            return 1.0
    }
    
    func carousel(mCarousel: iCarousel!, didSelectItemAtIndex index: Int) {
//        println("\(index)")
    }
    
    func carouselCurrentItemIndexDidChange(mCarousel: iCarousel!) {
//        println("\(carousel.currentItemIndex)")
        topViewIndexCallBack?.onTopViewCurrentIndexCallBack(carousel.currentItemIndex)
    }
    
    func getCurrentIndex() -> Int{
        return carousel.currentItemIndex
    }

    func scrollToIndex(index:Int){
//        if carousel.currentItemIndex != index {
            carousel.scrollToItemAtIndex(getItemSize(index), animated: false)
//        }
    }
    
    func getItemSize(index:Int) -> Int{
        let size = mRecordTypesList.size()
        var count:Int = Int(index)
        for i in 0..<size {
            count -= Int((mRecordTypesList.getWithInt(Int32(i)) as! ComFqHalcyonEntityRecordType).getItemList().size())
            if count < 0 {
                print("_________________________________\(i)")
                return Int(i)
               
            }else if count == 0 {
                return (Int(i) + 1)
            }
            
        }
        return 0
    }

}

protocol TopViewCurrentIndexCallBack{
    func onTopViewCurrentIndexCallBack(index:Int)
}
