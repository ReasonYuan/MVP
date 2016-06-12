//
//  TestViewController.swift
//  DoctorPlus_ios
//
//  Created by XiWang on 15-4-27.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit

class TestViewController: BaseViewController,UICollectionViewDataSource,UICollectionViewDelegate {
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    var count = 6
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.registerNib(UINib(nibName: "TestCell", bundle:nil), forCellWithReuseIdentifier: "TestCell")
    }
 
    override func getXibName() -> String {
        return "TestViewController"
    }
   
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
       let cell =  collectionView.dequeueReusableCellWithReuseIdentifier("TestCell", forIndexPath: indexPath)
        let gesture = MyGesture(target: self, action: "upSwipe:",index: indexPath.row)
        gesture.direction = UISwipeGestureRecognizerDirection.Up
        cell.addGestureRecognizer(gesture)
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
      return count
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func upSwipe(gesture:MyGesture){
        count = count - 1
        if count >= 0 {
            print(gesture.index)
            collectionView.deleteItemsAtIndexPaths([NSIndexPath(forItem: gesture.index, inSection: 0)])
            self.collectionView.reloadSections(NSIndexSet(index: 0))
        }
       
    }
}
