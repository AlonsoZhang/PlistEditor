//
//  OutlineViewData.h
//  PlistEditor
//
//  Created by Alonso on 2018/5/31.
//  Copyright © 2018 Alonso. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OutlineViewData : NSObject

@property (readwrite,copy) NSString *name;
@property (readwrite,copy) NSString *type;
@property (readwrite,copy) NSString *number;

@property (readwrite,assign) BOOL isHasChild;
@property (readwrite,assign) BOOL isParentRoot;
@property  NSMutableArray *arrayDatas;

@end
