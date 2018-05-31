//
//  OutlineViewData.m
//  PlistEditor
//
//  Created by Alonso on 2018/5/31.
//  Copyright © 2018 Alonso. All rights reserved.
//

#import "OutlineViewData.h"

@implementation OutlineViewData
@synthesize name;
@synthesize type;
@synthesize number;

@synthesize isHasChild;
@synthesize isParentRoot;
@synthesize arrayDatas;

-(id) init
{
    self =[super init];
    name = nil;
    type = @"";
    number =@"0";
    isHasChild =NO;
    isParentRoot =NO;
    
    arrayDatas = [NSMutableArray new];
    return self;
}

@end
