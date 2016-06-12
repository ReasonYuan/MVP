/*!
 @header    UnitCell.h
 @abstract  显示成员的原子View
 @author    丁磊
 @version   1.0.0 2014/05/28 Creation
 */

#import <UIKit/UIKit.h>


@class UnitCell;

@protocol UnitCellDelegate<NSObject>

// 通知cell被点击，执行删除操作
- (void) unitCellTouched:(UnitCell *)unitCell;
- (void) unitCellClicked:(UnitCell *)unitCell;

@end

@interface UnitCell : UIButton
{
    CGPoint startPoint;
    CGPoint newCenter;
    CGPoint oldCenter;
}

@property (nonatomic, assign) id<UnitCellDelegate>delegate;
@property (nonatomic, assign) NSInteger status;
/*
    method：初始化函数
    frame:坐标
    icon：成员头像
    name：成员名字
 */
- (id)initWithFrame:(CGRect)frame andIcon:(NSString *)icon andName:(NSString *)name;
- (void)setProgress:(NSString*)value;
- (void)setVisible:(BOOL)visible;
- (BOOL)getVisible;
@end
