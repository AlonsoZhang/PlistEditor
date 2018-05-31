//
//  SimpleNodeData.m
//  PlistEditor
//
//  Created by Alonso on 2018/5/31.
//  Copyright © 2018 Alonso. All rights reserved.
//

#import "SimpleNodeData.h"
#import "OutlineViewData.h"

@implementation SimpleNodeData
@synthesize name,type,number, expandable, selectable, container
,isHasChild,isParentRoot;

- (id)init {
    self = [super init];
    
    name = @"Untitled";
    type = @"";
    number =@"0";
    
    expandable = YES;
    selectable = YES;
    container = YES;
    isHasChild =NO;
    isParentRoot =NO;
    return self;
}

-(id) initWithTreeData:(id) data
{
    self = [self init];
    OutlineViewData *ii =data;
    name = ii.name;
    type = ii.type;
    number =ii.number;
    
    isHasChild =ii.isHasChild;
    isParentRoot =ii.isParentRoot;
    
    return self;
}

+ (SimpleNodeData *)nodeDataWithTreeData:(id)data
{
    return [[SimpleNodeData alloc] initWithTreeData:data];
}
@end
