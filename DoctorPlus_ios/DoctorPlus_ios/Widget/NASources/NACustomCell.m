//
//  NACustomCell.m
//  NAPickerView
//
//  Created by iNghia on 8/5/13.
//  Copyright (c) 2013 nghialv. All rights reserved.
//

#import "NACustomCell.h"

@implementation NACustomCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier cellWidth:(CGFloat)cellWidth
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.avatar = [[UIImageView alloc] initWithFrame:CGRectMake(50.f, 10.f, 50, 60)];
        [self addSubview:self.avatar];
        self.label = [[UILabel alloc] initWithFrame:CGRectMake(130, 0, cellWidth - 130, 60)];
        self.label.textAlignment = UITextAlignmentLeft;
        self.label.font = [UIFont systemFontOfSize:20];
        self.label.backgroundColor = [UIColor clearColor];
        self.label.textColor = [UIColor grayColor];
        [self addSubview:self.label];
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

+ (CGFloat)cellHeight
{
    return 60.f;
}

@end
