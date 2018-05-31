//
//  ViewController.h
//  PlistEditor
//
//  Created by Alonso on 2018/5/30.
//  Copyright © 2018 Alonso. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "OutlineViewData.h"
#import "SimpleNodeData.h"
#import "CenterTextFieldCell.h"

@interface ViewController : NSViewController<NSOutlineViewDelegate,NSOutlineViewDataSource,NSComboBoxDelegate,NSComboBoxDataSource>
{
    NSTreeNode *rootTreeNode;
    NSInteger selectedLevel;
    NSString *beforKey;
    NSString *beforType;
    NSString *beforValue;
    NSMutableArray *plistURLs;
    NSMutableArray *plistPaths;
    NSURL *plistURL;
    OutlineViewData *rootData;
    NSMutableArray *PlistArray;
    NSMutableDictionary *PlistDictionary;
    NSMutableArray *parentItems;
}

@property (weak) IBOutlet NSOutlineView *outlineView;
@property (weak) IBOutlet NSComboBox *PlistPathsComboBox;
@property (weak) IBOutlet NSTextField *selectedKey;
@property (weak) IBOutlet NSTextField *selectedType;
@property (weak) IBOutlet NSTextField *selectedValue;
@property (weak) IBOutlet NSTextField *AddKey;
@property (weak) IBOutlet NSPopUpButtonCell *AddType;
@property (weak) IBOutlet NSTextField *AddValue;

//IBOutlet NSTextView *textView;

-(IBAction)ChooseAppFile:(id)sender;
-(IBAction)ChoosePlistFile:(id)sender;
-(IBAction)Remove:(id)sender;
-(IBAction)Add:(id)sender;
-(IBAction)Change:(id)sender;
-(IBAction)Save:(id)sender;

- (NSArray *)draggedNodes;
- (NSArray *)selectedNodes;

@end

