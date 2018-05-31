//
//  CenterTextFieldCell.m
//  PlistEditor
//
//  Created by Alonso on 2018/5/31.
//  Copyright © 2018 Alonso. All rights reserved.
//

#import "CenterTextFieldCell.h"

@implementation CenterTextFieldCell

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
    NSRect rectCenter = cellFrame;
    NSSize size = [[self title] sizeWithAttributes:nil];
    CGFloat offset = (rectCenter.size.height-size.height)/2;
    rectCenter.origin.y = rectCenter.origin.y+offset;
    rectCenter.size.height = cellFrame.size.height-offset;
    [super drawWithFrame:rectCenter inView:controlView];
}

@end
