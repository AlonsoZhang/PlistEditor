//
//  SimpleNodeData.h
//  PlistEditor
//
//  Created by Alonso on 2018/5/31.
//  Copyright © 2018 Alonso. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface SimpleNodeData : NSObject {
    //@private
    // ivars for the properties declared below
    NSString *name;
    NSString *type;
    NSString *number;
    
    //表格状态标识
    BOOL isHasChild;
    BOOL isParentRoot;
    
    BOOL expandable;
    BOOL selectable;
    BOOL container;
}
@property(readwrite, copy) NSString *name;
@property(readwrite, copy) NSString *type;
@property(readwrite, copy) NSString *number;

@property(readwrite, getter=isExpandable) BOOL expandable;
@property(readwrite, getter=isSelectable) BOOL selectable;
@property(readwrite, getter=isContainer) BOOL container;
@property(readwrite,assign) BOOL isHasChild;
@property(readwrite,assign) BOOL isParentRoot;

-(id) initWithTreeData:(id) data;
+ (SimpleNodeData *)nodeDataWithTreeData:(id)data;

@end
