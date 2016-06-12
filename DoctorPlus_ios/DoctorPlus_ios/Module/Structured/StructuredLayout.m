//
//  StructuredLayout.m
//  DoctorPlus_ios
//
//  Created by 廖敏 on 15/7/23.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

#import "StructuredLayout.h"

@implementation StructuredLayout

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        self.minimumInteritemSpacing = 0;
        self.minimumLineSpacing = 0;
    }
    return self;
}

-(CGSize)itemSize
{
    return CGSizeMake(self.collectionView.frame.size.width/4.f, STRUCT_CELL_HEIGTH);
}

@end
