/*!
 @header    UnitCell.m
 @abstract  显示成员的原子View
 @author    丁磊
 @version   1.0.0 2014/05/28 Creation
 */

#import "UnitCell.h"
#import "DoctorPlus_ios-Swift.h"
@interface UnitCell ()

// user的头像url
@property (nonatomic, strong) NSString *icon;

// user的名称
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) progressView *progressView;
@end

@implementation UnitCell

- (id)initWithFrame:(CGRect)frame andIcon:(NSString *)icon andName:(NSString *)name{
    _icon = icon;
    _name = name;
    self = [super initWithFrame:frame];
    if (self) {
        [self setProperty];
    }
    return self;
}

/*
 *@method 设置UnitCell的属性
 */
- (void)setProperty
{
    self.userInteractionEnabled = YES;
    self.layer.masksToBounds = YES;
//    self.layer.cornerRadius = 4.0;
    self.progressView = [[progressView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    
    [self addSubview:self.progressView];
    [self setBackgroundImage:[UIImage imageNamed:_icon] forState:UIControlStateNormal];
}

- (void)setProgress:(NSString*)value{
    if ([value  isEqual: @"100%"]){
        [self progressView].progressLabel.text = @"";
        [self progressView].backgroundColor = [UIColor clearColor];
        [self progressView].progressLabel.hidden = YES;
    }else{
       [self progressView].progressLabel.text = value;
        [self progressView].progressLabel.textColor = [UIColor whiteColor];
        [self progressView].progressLabel.hidden = NO;
    }
}

- (void)setVisible:(BOOL)visible{
    [self progressView].imageView.hidden = !visible;
}

- (BOOL)getVisible{
    return [self progressView].imageView.hidden == YES;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    oldCenter = self.center;
    CGPoint point = [[touches anyObject] locationInView:self];
    startPoint = point;
    [self.superview bringSubviewToFront:self];
}

-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    CGPoint point = [[touches anyObject] locationInView:self];
    float dy = point.y - startPoint.y;
    newCenter = CGPointMake(self.center.x, self.center.y + dy);
    float halfy = CGRectGetMidY(self.bounds);
    newCenter.y = MIN( halfy, newCenter.y);
    newCenter.y = MAX(-self.superview.bounds.size.height*2 + halfy, newCenter.y);
    self.center = newCenter;
}

- (void) touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if(-(self.center.y - oldCenter.y) > self.bounds.size.height){
        [_delegate unitCellTouched:self];
    }else if(self.center.y == oldCenter.y){
        //处理点击事件
        [_delegate unitCellClicked:self];
        NSLog(@"xxxxx");
    }else{
        self.center = oldCenter;
    }
}

@end
