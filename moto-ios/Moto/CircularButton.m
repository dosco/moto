//
//  CircularButton.m
//  Test
//
//  Created by Vikram Rangnekar on 10/15/13.
//  Copyright (c) 2013 Vikram Rangnekar. All rights reserved.
//

#import "CircularButton.h"

@implementation CircularButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextAddEllipseInRect(ctx, CGRectMake(90, 205, 145.0, 145.0));
    CGContextSetFillColor(ctx, CGColorGetComponents([[UIColor blueColor] CGColor]));
    CGContextFillPath(ctx);
}

@end
