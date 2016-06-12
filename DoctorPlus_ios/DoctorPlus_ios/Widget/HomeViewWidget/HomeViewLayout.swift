//
//  HomeViewLayout.swift
//  DoctorPlus_ios
//
//  Created by 廖敏 on 15/4/30.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

import UIKit

class HomeViewLayout: UICollectionViewFlowLayout {
    
    var array:NSMutableArray = NSMutableArray()
    
    var allAttr:NSMutableDictionary = NSMutableDictionary()
    
     override func prepareLayout(){
        super.prepareLayout()
        self.scrollDirection = UICollectionViewScrollDirection.Horizontal
    }
    
    func getCellWidth()->CGFloat{
        let homeCollectionView = self.collectionView as! HomeCollectionView
        return homeCollectionView.getItemWidth()
    }
    
    override func collectionViewContentSize() -> CGSize {
        if(self.collectionView != nil){
            var size = super.collectionViewContentSize()
            let sections:CGFloat = CGFloat(self.collectionView!.numberOfSections())
            if(sections > 0){
                size.width = self.getCellWidth() * sections
            }
            return size
        }
       return super.collectionViewContentSize()
    }
    
    override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes! {
        var attributes:UICollectionViewLayoutAttributes!
        if allAttr[indexPath] != nil{
            attributes = allAttr[indexPath] as! UICollectionViewLayoutAttributes
        }else{
            attributes  = UICollectionViewLayoutAttributes(forCellWithIndexPath:indexPath)
            allAttr[indexPath] = attributes
            let width = getCellWidth()
            if(indexPath.row == 7){
                attributes.size = CGSizeMake(Home_month_heigth, Home_month_heigth)
                attributes.frame.origin = CGPointMake(CGFloat(indexPath.section)*width, 7*width)
            }else{
                attributes.size = CGSizeMake(width, width)
                attributes.frame.origin = CGPointMake(CGFloat(indexPath.section)*width, CGFloat(indexPath.row)*width)
            }
        }
        return attributes;
    }
    
    override func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool {
        return true
    }
   
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        array.removeAllObjects()
        let isNil = self.collectionView?.numberOfSections()
        if(isNil != nil && isNil > 0)
        {
            for var i = 0; i < self.collectionView?.numberOfSections() ; i++ {
                for var j = 0; j < self.collectionView?.numberOfItemsInSection(i) ; j++ {
                    let att = self.layoutAttributesForItemAtIndexPath(NSIndexPath(forRow: j, inSection: i))
                    array.addObject(att)
                }
            }
        }
        return array as [AnyObject] as! [UICollectionViewLayoutAttributes]
    }
}
