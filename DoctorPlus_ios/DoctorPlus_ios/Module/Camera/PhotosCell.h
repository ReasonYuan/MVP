//
//  PhotosCell.h
//  DoctorPlus_ios
//
//  Created by 廖敏 on 15/7/19.
//  Copyright (c) 2015年 廖敏. All rights reserved.
//

#import "java/util/ArrayList.h"
#import "PhotoRecord.h"

#define CELL_IDENTIFY_NORMAL @"NormalCell"

#define CELL_IDENTIFY_GROUP @"GroupCell"

@interface PhotosNormalCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *ImageView;

@property (weak, nonatomic) UIButton *groupRemoveBtn;

-(void)reset;
-(void)hideStatus:(BOOL)hide;
-(void)setTime:(long)time;

@property (nonatomic,assign) BOOL edit;
@property (nonatomic,assign) BOOL selecte;
@property (nonatomic,assign) NSInteger status;


@end


@interface PhotosGroupCell : PhotosNormalCell

@property (nonatomic,weak) JavaUtilArrayList* data;

@end

@protocol PhotosGroupLargeCellDelegate <NSObject>

-(void)onRemove:(ComFqHalcyonEntityPhotoRecord*)item;

-(void)onTap:(ComFqHalcyonEntityPhotoRecord*)item;

@end

/**
 *图片组预览时的view
 */
@interface PhotosGroupLargeCell : PhotosGroupCell


@property (nonatomic,assign) NSInteger group;

@property (nonatomic,weak) id<PhotosGroupLargeCellDelegate> delegate;

@end