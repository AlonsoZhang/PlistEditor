//
//  ViewController.m
//  PlistEditor
//
//  Created by Alonso on 2018/5/30.
//  Copyright © 2018 Alonso. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    rootTreeNode =[NSTreeNode new];
    parentItems = [NSMutableArray new];
    NSArray *Types = @[@"String",@"Boolean",@"Number",@"Array",@"Dictionary"];
    [_AddType removeAllItems];
    [_AddType addItemsWithTitles:Types];
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
}

// The NSOutlineView uses 'nil' to indicate the root item. We return our root tree node for that case.
- (NSArray *)childrenForItem:(id)item {
    if (item == nil) {
        return [rootTreeNode childNodes];
    } else {
        return [item childNodes];
    }
}

// Required methods.
- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item {
    // 'item' may potentially be nil for the root item.
    NSArray *children = [self childrenForItem:item];
    // This will return an NSTreeNode with our model object as the representedObject
    return [children objectAtIndex:index];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item {
    // 'item' will always be non-nil. It is an NSTreeNode, since those are always the objects we give NSOutlineView. We access our model object from it.
    SimpleNodeData *nodeData = [item representedObject];
    // We can expand items if the model tells us it is a container
    return nodeData.container;
}

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item {
    // 'item' may potentially be nil for the root item.
    NSArray *children = [self childrenForItem:item];
    return [children count];
}

// To get the "group row" look, we implement this method.
- (BOOL)outlineView:(NSOutlineView *)outlineView isGroupItem:(id)item
{
    SimpleNodeData *nodeData ;
    nodeData = [item representedObject];
    return NO;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldExpandItem:(id)item {
    // Query our model for the answer to this question
    SimpleNodeData *nodeData = [item representedObject];
    return nodeData.expandable;
}

- (void)outlineView:(NSOutlineView *)outlineView willDisplayCell:(NSCell *)cell forTableColumn:(NSTableColumn *)tableColumn item:(id)item {
    SimpleNodeData *nodeData = [item representedObject];
    // For all the other columns, we don't do anything.
    NSString *identifier =[tableColumn identifier];
    if ([identifier isEqualToString:@"name"])
    {
        CenterTextFieldCell *textCell =(CenterTextFieldCell*)cell;
        [textCell setStringValue:nodeData.name];
    }
    if ([identifier isEqualToString:@"type"])
    {
        CenterTextFieldCell *textCell =(CenterTextFieldCell*)cell;
        [textCell setStringValue:nodeData.type];
    }
    else if ([identifier isEqualToString:@"number"])
    {
        CenterTextFieldCell *textCell =(CenterTextFieldCell*)cell;
        [textCell setStringValue:nodeData.number];
    }
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item
{
    id objectValue = nil;
    return objectValue;
}

-(OutlineViewData*) doLoadData:(NSURL *)selectedPlistURL
{
    rootData =[OutlineViewData new];
    [rootData setName:@"root"];
    [rootData setIsParentRoot:YES];
    PlistArray = [NSMutableArray arrayWithContentsOfURL:selectedPlistURL];
    PlistDictionary = [NSMutableDictionary dictionaryWithContentsOfURL:selectedPlistURL];
    if (PlistArray != nil)
    {
        OutlineViewData *ii =[OutlineViewData new];
        [ii setName:@"Root"];
        [ii setType:@"Array"];
        [ii setNumber:[NSString stringWithFormat:@"(%lu items)",(unsigned long)PlistArray.count]];
        [ii setIsParentRoot:YES];
        [ii setIsHasChild:YES];
        [ii.arrayDatas addObjectsFromArray:[self dealWithContents:PlistArray]];
        [rootData.arrayDatas addObject:ii];
    }
    else if (PlistDictionary != nil)
    {
        OutlineViewData *ii =[OutlineViewData new];
        [ii setName:@"Root"];
        [ii setType:@"Dictionary"];
        [ii setNumber:[NSString stringWithFormat:@"(%lu items)",(unsigned long)PlistDictionary.allKeys.count]];
        [ii setIsParentRoot:YES];
        [ii setIsHasChild:YES];
        [ii.arrayDatas addObjectsFromArray:[self dealWithContents:PlistDictionary]];
        [rootData.arrayDatas addObject:ii];
    }
    return rootData;
}

-(NSMutableArray *) dealWithContents:(id) contents
{
    NSMutableArray *DataArray = [NSMutableArray new];
    if ( [contents isKindOfClass:[NSArray class]] )
    {
        NSArray *tmpcontents = (NSArray *)contents;
        for (int i =0 ; i < tmpcontents.count ; i++)
        {
            id item = [tmpcontents objectAtIndex:i];
            OutlineViewData *temp =[OutlineViewData new];
            [temp setName:[NSString stringWithFormat:@"Item %d",i]];
            if ([item isKindOfClass:[NSDictionary class]])
            {
                [temp setType:@"Dictionary"];
                NSDictionary *item_D = (NSDictionary *)item;
                [temp setNumber:[NSString stringWithFormat:@"(%lu items)",(unsigned long)item_D.allKeys.count]];
                [temp.arrayDatas addObjectsFromArray:[self dealWithContents:item]];
                if (item_D.allKeys.count > 0)
                {
                    [temp setIsHasChild:YES];
                }
            }
            else if ([item isKindOfClass:[NSArray class]])
            {
                [temp setType:@"Array"];
                NSArray *item_A = (NSArray *)item;
                [temp setNumber:[NSString stringWithFormat:@"(%lu items)",(unsigned long)item_A.count]];
                [temp.arrayDatas addObjectsFromArray:[self dealWithContents:item]];
                if (item_A.count > 0)
                {
                    [temp setIsHasChild:YES];
                }
            }
            else if ( [item isKindOfClass:[NSString class]] )
            {
                [temp setType:@"String"];
                [temp setNumber:item];
                [temp setIsHasChild:NO];
            }else if ( [item isKindOfClass:[NSNumber class]] )
            {
                NSString *descripe = [NSString stringWithFormat:@"%@",[item class]];
                if ([descripe rangeOfString:@"Boolean"].location != NSNotFound)
                {
                    [temp setType:@"Boolean"];
                    if ([item boolValue])
                    {
                        [temp setNumber:@"YES"];
                    }else
                    {
                        [temp setNumber:@"NO"];
                    }
                    [temp setIsHasChild:NO];
                }
                else
                {
                    [temp setType:@"Number"];
                    [temp setNumber:item];
                    [temp setIsHasChild:NO];
                }
            }
            [DataArray addObject:temp];
        }
    }
    else if ( [contents isKindOfClass:[NSDictionary class]] )
    {
        NSDictionary *tmpcontents = (NSDictionary *)contents;
        for (NSString *key  in tmpcontents.allKeys)
        {
            id item = [tmpcontents objectForKey:key];
            OutlineViewData *temp =[OutlineViewData new];
            [temp setName:key];
            if ([item isKindOfClass:[NSDictionary class]])
            {
                [temp setType:@"Dictionary"];
                NSDictionary *item_D = (NSDictionary *)item;
                [temp setNumber:[NSString stringWithFormat:@"(%lu items)",(unsigned long)item_D.allKeys.count]];
                [temp.arrayDatas addObjectsFromArray:[self dealWithContents:item]];
                if (item_D.allKeys.count > 0)
                {
                    [temp setIsHasChild:YES];
                }
            }
            else if ([item isKindOfClass:[NSArray class]])
            {
                [temp setType:@"Array"];
                NSArray *item_A = (NSArray *)item;
                [temp setNumber:[NSString stringWithFormat:@"(%lu items)",(unsigned long)item_A.count]];
                [temp.arrayDatas addObjectsFromArray:[self dealWithContents:item]];
                if (item_A.count > 0)
                {
                    [temp setIsHasChild:YES];
                }
            }
            else if ( [item isKindOfClass:[NSString class]] )
            {
                [temp setType:@"String"];
                [temp setNumber:item];
                [temp setIsHasChild:NO];
            }else if ( [item isKindOfClass:[NSNumber class]] )
            {
                NSString *descripe = [NSString stringWithFormat:@"%@",[item class]];
                if ([descripe rangeOfString:@"Boolean"].location != NSNotFound)
                {
                    [temp setType:@"Boolean"];
                    if ([item boolValue])
                    {
                        [temp setNumber:@"YES"];
                    }else
                    {
                        [temp setNumber:@"NO"];
                    }
                    [temp setIsHasChild:NO];
                }
                else
                {
                    [temp setType:@"Number"];
                    [temp setNumber:item];
                    [temp setIsHasChild:NO];
                }
            }
            [DataArray addObject:temp];
        }
    }
    return DataArray;
}

- (NSTreeNode*) doTreeNodeFromArray:(OutlineViewData *) data
{
    OutlineViewData *tempData = data;
    NSMutableArray *children =tempData.arrayDatas;
    SimpleNodeData *nodeData = [SimpleNodeData nodeDataWithTreeData:tempData];
    // The image for the nodeData is lazily filled in, for performance.
    // Create a NSTreeNode to wrap our model object. It will hold a cache of things such as the children.
    NSTreeNode *result = [NSTreeNode treeNodeWithRepresentedObject:nodeData];
    // Walk the dictionary and create NSTreeNodes for each child.
    for (OutlineViewData * item in children) {
        // A particular item can be another dictionary (ie: a container for more children), or a simple string
        NSTreeNode *childTreeNode;
        //if ([item isKindOfClass:[OutlineViewData class]])
        if (item.isHasChild)
        {
            // Recursively create the child tree node and add it as a child of this tree node
            childTreeNode = [self doTreeNodeFromArray:item];
        } else {
            // It is a regular leaf item with just the name
            SimpleNodeData *childNodeData = [[SimpleNodeData alloc] initWithTreeData:item];
            childNodeData.container = NO;
            childTreeNode = [NSTreeNode treeNodeWithRepresentedObject:childNodeData];
            // [childNodeData release];
        }
        // Now add the child to this parent tree node
        [[result mutableChildNodes] addObject:childTreeNode];
    }
    return result;
}

- (NSArray *)draggedNodes{
    return nil;
}

- (NSArray *)selectedNodes{
    return [self selectedItems];
}

- (NSArray *)selectedItems {
    NSMutableArray *items = [NSMutableArray array];
    NSIndexSet *selectedRows = [_outlineView selectedRowIndexes];
    if (selectedRows != nil)
    {
        for (NSInteger row = [selectedRows firstIndex]; row != NSNotFound; row = [selectedRows indexGreaterThanIndex:row])
        {
            [items addObject:[_outlineView itemAtRow:row]];
        }
        if (items.count == 1)
        {
            selectedLevel = [_outlineView levelForItem:[items firstObject]];
            parentItems = [NSMutableArray new];
            if (selectedLevel > 1)
            {
                NSInteger level = selectedLevel;
                id currentItem = [items firstObject];
                do
                {
                    currentItem = [_outlineView parentForItem:currentItem];
                    [parentItems addObject:currentItem];
                    level -= 1 ;
                } while (level>1);
            }
        }
    }
    return items;
}

- (void)outlineViewSelectionDidChange:(NSNotification *)notification
{
    NSArray *selectedNodes = [self selectedNodes];
    if ([selectedNodes count] > 1)
    {
        NSLog(@"Multiple Rows Selected");
    }
    else if ([selectedNodes count] == 1)
    {
        SimpleNodeData *data = [[selectedNodes lastObject] representedObject];
        _selectedKey.stringValue = data.name;
        _selectedType.stringValue = data.type;
        _selectedValue.stringValue = data.number;
        if ([_selectedKey.stringValue isEqualToString:@"Root"])
        {
            [_selectedKey setEditable:NO];
        }else
        {
            [_selectedKey setEditable:YES];
        }
        if ([_selectedType.stringValue isEqualToString:@"Array"] || [_selectedType.stringValue isEqualToString:@"Dictionary"])
        {
            [_selectedValue setEditable:NO];
        }else
        {
            [_selectedValue setEditable:YES];
        }
        if (parentItems.count > 0)
        {
            SimpleNodeData *ParentData = [[parentItems lastObject] representedObject];
            if ([ParentData.type isEqualToString:@"Array"])
            {
                [_selectedKey setEditable:NO];
            }else
            {
                [_selectedKey setEditable:YES];
            }
        }
        beforKey = _selectedKey.stringValue ;
        beforType = _selectedType.stringValue ;
        beforValue = _selectedValue.stringValue ;
        if ([_selectedType.stringValue isEqualToString:@"Array"])
        {
            _AddKey.placeholderString = @"Item x";
            _AddValue.placeholderString = @"Value";
        }
        else if ([_selectedType.stringValue isEqualToString:@"Dictionary"])
        {
            _AddKey.placeholderString = @"Key";
            _AddValue.placeholderString = @"Value";
        }else
        {
            if (parentItems.count > 0)
            {
                SimpleNodeData *ParentData = [[parentItems lastObject] representedObject];
                if ([ParentData.type isEqualToString:@"Array"])
                {
                    _AddKey.placeholderString = @"Item x";
                    _AddValue.placeholderString = @"Value";
                }else if ([ParentData.type isEqualToString:@"Dictionary"])
                {
                    _AddKey.placeholderString = @"Key";
                    _AddValue.placeholderString = @"Value";
                }
            }else
            {
                _AddKey.placeholderString = @"Key";
                _AddValue.placeholderString = @"Value";
            }
        }
    }
}

-(IBAction)ChooseAppFile:(id)sender
{
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setDirectoryURL:[NSURL fileURLWithPath:[NSHomeDirectory() stringByAppendingPathComponent:@"Desktop"]]];
    [panel setAllowsMultipleSelection:NO];
    [panel setCanChooseDirectories:NO];
    [panel setCanChooseFiles:YES];
    [panel setAllowedFileTypes:@[@"app"]];
    [panel setAllowsOtherFileTypes:NO];
    if ([panel runModal] == NSModalResponseOK)
    {
        NSString *path = [panel.URLs.firstObject path];
        if ([path length] > 0)
        {
            [self ListPlistFile:path];
        }
    }
}

- (void)ListPlistFile:(NSString *)apppath
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *path = [apppath stringByAppendingPathComponent:@"Contents/Resources"];
    path = [path stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSURL *bundleURL =  [NSURL URLWithString:path];
    NSArray *contents = [fileManager contentsOfDirectoryAtURL:bundleURL
                                   includingPropertiesForKeys:@[]
                                                      options:0
                                                        error:nil];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"pathExtension == 'plist'"];
    plistURLs = [NSMutableArray new];
    plistPaths = [NSMutableArray new];
    for (NSURL *fileURL in [contents filteredArrayUsingPredicate:predicate])
    {
        [plistURLs addObject:fileURL];
        NSString *pathString = [fileURL path];
        [plistPaths addObject:[pathString lastPathComponent]];
    }
    if (_PlistPathsComboBox.numberOfItems > 0)
    {
        [_PlistPathsComboBox removeAllItems];
    }
    if ([plistPaths count] == 0) {
        [self showAlertViewWith:@"No Plist!!!"];
    }else{
        [_PlistPathsComboBox addItemsWithObjectValues:plistPaths];
        [_PlistPathsComboBox selectItemAtIndex:0];
        [self ChoosePlistFile:nil];
    }
}

-(IBAction)ChoosePlistFile:(id)sender
{
    NSURL *selectedPlistURL = [plistURLs objectAtIndex:_PlistPathsComboBox.indexOfSelectedItem];
    plistURL = selectedPlistURL;
    OutlineViewData *data= [self doLoadData:selectedPlistURL];
    rootTreeNode = [self doTreeNodeFromArray:data];
    [_outlineView setIndentationMarkerFollowsCell:YES];
    [_outlineView setIgnoresMultiClick:YES];
    [_outlineView expandItem:rootTreeNode expandChildren:YES];
    [_outlineView reloadData];
    //设置子项的展开
    [_outlineView isExpandable:[rootTreeNode.mutableChildNodes objectAtIndex:0]];
    [_outlineView expandItem:[rootTreeNode.mutableChildNodes objectAtIndex:0] expandChildren:NO];
}

-(void) refreshOutLineView:(id) Contents
{
    OutlineViewData *data= [self doreLoadData:Contents];
    rootTreeNode = [self doTreeNodeFromArray:data];
    [_outlineView setIndentationMarkerFollowsCell:YES];
    [_outlineView setIgnoresMultiClick:YES];
    [_outlineView expandItem:rootTreeNode expandChildren:YES];
    [_outlineView reloadData];
    //设置子项的展开
    [_outlineView isExpandable:[rootTreeNode.mutableChildNodes objectAtIndex:0]];
    [_outlineView expandItem:[rootTreeNode.mutableChildNodes objectAtIndex:0] expandChildren:NO];
}

-(OutlineViewData*) doreLoadData:(id)Contents
{
    rootData =[OutlineViewData new];
    [rootData setName:@"root"];
    [rootData setIsParentRoot:YES];
    if ([Contents isKindOfClass:[NSArray class]])
    {
        OutlineViewData *ii =[OutlineViewData new];
        [ii setName:@"Root"];
        [ii setType:@"Array"];
        [ii setNumber:[NSString stringWithFormat:@"(%lu items)",(unsigned long)PlistArray.count]];
        [ii setIsParentRoot:YES];
        [ii setIsHasChild:YES];
        [ii.arrayDatas addObjectsFromArray:[self dealWithContents:Contents]];
        [rootData.arrayDatas addObject:ii];
    }
    else if ([Contents isKindOfClass:[NSDictionary class]])
    {
        OutlineViewData *ii =[OutlineViewData new];
        [ii setName:@"Root"];
        [ii setType:@"Dictionary"];
        [ii setNumber:[NSString stringWithFormat:@"(%lu items)",(unsigned long)PlistDictionary.allKeys.count]];
        [ii setIsParentRoot:YES];
        [ii setIsHasChild:YES];
        [ii.arrayDatas addObjectsFromArray:[self dealWithContents:Contents]];
        [rootData.arrayDatas addObject:ii];
    }
    return rootData;
}

-(void)showAlertViewWith:(NSString *)InformativeText
{
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:@"提 示"];
    [alert setInformativeText:InformativeText];
    [alert addButtonWithTitle:@"OK"];
    [alert setAlertStyle:NSAlertStyleWarning];
    [alert runModal];
}

- (BOOL)isPureDouble:(NSString*)string{
    NSScanner* scan = [NSScanner scannerWithString:string];
    double val;
    return[scan scanDouble:&val] && [scan isAtEnd];
}

-(IBAction)Change:(id)sender
{
    if ([_selectedKey.stringValue length] == 0)
    {
        return;
    }
    NSArray * NewParentItems = [[parentItems reverseObjectEnumerator] allObjects];
    NSMutableArray *parents = [NSMutableArray new];
    if (PlistArray != nil)
    {
        [parents addObject:@[@"Array",PlistArray,@"Root"]];
    }
    else if (PlistDictionary != nil)
    {
        [parents addObject:@[@"Dictionary",PlistDictionary,@"Root"]];
    }
    for (int i = 0; i < NewParentItems.count ; i++)
    {
        id object = [[parents lastObject] objectAtIndex:1];
        NSString *type = [[parents lastObject] objectAtIndex:0];
        SimpleNodeData *Adata = [[NewParentItems objectAtIndex:i] representedObject];
        if ([type isEqualToString:@"Array"])
        {
            int index = [[[Adata.name substringFromIndex:NSMaxRange([Adata.name rangeOfString:@"Item "])] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] intValue];
            id Tobject = [object objectAtIndex:index];
            [parents addObject:@[Adata.type,Tobject,[NSString stringWithFormat:@"%d",index]]];
        }
        else if ([type isEqualToString:@"Dictionary"])
        {
            id Tobject = [object objectForKey:Adata.name];
            [parents addObject:@[Adata.type,Tobject,Adata.name]];
        }
    }
    NSArray * NewParents = [[parents reverseObjectEnumerator] allObjects];
    NSArray *FParent = [NewParents firstObject];
    id object = [FParent objectAtIndex:1];
    NSString *type = [FParent objectAtIndex:0];
    NSString *Key_Index = [FParent objectAtIndex:2];
    if ([type isEqualToString:@"Array"])
    {
        int index = [[[_selectedKey.stringValue substringFromIndex:NSMaxRange([_selectedKey.stringValue rangeOfString:@"Item "])] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] intValue];
        if ([_selectedType.stringValue isEqualToString:@"Number"])
        {
            if ([self isPureDouble:_selectedValue.stringValue])
            {
                [object replaceObjectAtIndex:index withObject:[NSNumber numberWithDouble:[_selectedValue.stringValue doubleValue]]];
            }else
            {
                [self showAlertViewWith:@"请输入 Number 类型的 Value !!!"];
                return;
            }
        }
        else if ([_selectedType.stringValue isEqualToString:@"Boolean"])
        {
            if ([_selectedValue.stringValue isEqualToString:@"YES"] || [_selectedValue.stringValue isEqualToString:@"NO"])
            {
                [object replaceObjectAtIndex:index withObject:[NSNumber numberWithBool:[_selectedValue.stringValue boolValue]]];
            }else
            {
                [self showAlertViewWith:@"请输入 Boolean 类型的 Value ( YES or NO ) !!!"];
                return;
            }
        }else
        {
            [object replaceObjectAtIndex:index withObject:_selectedValue.stringValue];
        }
    }
    else if ([type isEqualToString:@"Dictionary"])
    {
        if ([_selectedKey.stringValue isEqualToString:beforKey])
        {
            if ([_selectedType.stringValue isEqualToString:@"Number"])
            {
                if ([self isPureDouble:_selectedValue.stringValue])
                {
                    [object setObject:[NSNumber numberWithDouble:[_selectedValue.stringValue doubleValue]] forKey:_selectedKey.stringValue];
                }else
                {
                    [self showAlertViewWith:@"请输入 Number 类型的 Value !!!"];
                    return;
                }
            }
            else if ([_selectedType.stringValue isEqualToString:@"Boolean"])
            {
                if ([_selectedValue.stringValue isEqualToString:@"YES"] || [_selectedValue.stringValue isEqualToString:@"NO"])
                {
                    [object setObject:[NSNumber numberWithBool:[_selectedValue.stringValue boolValue]] forKey:_selectedKey.stringValue];
                }else
                {
                    [self showAlertViewWith:@"请输入 Boolean 类型的 Value ( YES or NO ) !!!"];
                    return;
                }
            }else
            {
                [object setObject:_selectedValue.stringValue forKey:_selectedKey.stringValue];
            }
        }else
        {
            if ([[object allKeys] containsObject:_selectedKey.stringValue])
            {
                [self showAlertViewWith:@"请注意 : Key 值重复 !!! \n"];
                _selectedKey.stringValue = beforKey;
                _selectedValue.stringValue = beforValue;
            }else
            {
                [object removeObjectForKey:beforKey];
                if ([_selectedType.stringValue isEqualToString:@"Number"])
                {
                    if ([self isPureDouble:_selectedValue.stringValue])
                    {
                        [object setObject:[NSNumber numberWithDouble:[_selectedValue.stringValue doubleValue]] forKey:_selectedKey.stringValue];
                    }else
                    {
                        [self showAlertViewWith:@"请输入 Number 类型的 Value !!!"];
                        return;
                    }
                }
                else if ([_selectedType.stringValue isEqualToString:@"Boolean"])
                {
                    if ([_selectedValue.stringValue isEqualToString:@"YES"] || [_selectedValue.stringValue isEqualToString:@"NO"])
                    {
                        [object setObject:[NSNumber numberWithBool:[_selectedValue.stringValue boolValue]] forKey:_selectedKey.stringValue];
                    }else
                    {
                        [self showAlertViewWith:@"请输入 Boolean 类型的 Value ( YES or NO ) !!!"];
                        return;
                    }
                }else
                {
                    [object setObject:_selectedValue.stringValue forKey:_selectedKey.stringValue];
                }
            }
        }
    }
    for (int i = 1; i < NewParents.count ; i++)
    {
        id TmpObject = [[NewParents objectAtIndex:i] objectAtIndex:1];
        NSString *Tmptype = [[NewParents objectAtIndex:i] objectAtIndex:0];
        if ([Tmptype isEqualToString:@"Array"])
        {
            [TmpObject replaceObjectAtIndex:[Key_Index intValue] withObject:object];
        }
        else if ([Tmptype isEqualToString:@"Dictionary"])
        {
            [TmpObject removeObjectForKey:Key_Index];
            
            [TmpObject setObject:object forKey:Key_Index];
        }
        object = TmpObject;
        Key_Index = [[NewParents objectAtIndex:i] objectAtIndex:2];
    }
    [self refreshOutLineView:object];
}

-(IBAction)Remove:(id)sender
{
    if ([_selectedKey.stringValue length] == 0)
    {
        return;
    }
    NSArray * NewParentItems = [[parentItems reverseObjectEnumerator] allObjects];
    NSMutableArray *parents = [NSMutableArray new];
    if (PlistArray != nil)
    {
        [parents addObject:@[@"Array",PlistArray,@"Root"]];
    }
    else if (PlistDictionary != nil)
    {
        [parents addObject:@[@"Dictionary",PlistDictionary,@"Root"]];
    }
    for (int i = 0; i < NewParentItems.count ; i++)
    {
        id object = [[parents lastObject] objectAtIndex:1];
        NSString *type = [[parents lastObject] objectAtIndex:0];
        SimpleNodeData *Adata = [[NewParentItems objectAtIndex:i] representedObject];
        if ([type isEqualToString:@"Array"])
        {
            int index = [[[Adata.name substringFromIndex:NSMaxRange([Adata.name rangeOfString:@"Item "])] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] intValue];
            id Tobject = [object objectAtIndex:index];
            [parents addObject:@[Adata.type,Tobject,[NSString stringWithFormat:@"%d",index]]];
        }
        else if ([type isEqualToString:@"Dictionary"])
        {
            id Tobject = [object objectForKey:Adata.name];
            [parents addObject:@[Adata.type,Tobject,Adata.name]];
        }
    }
    NSArray * NewParents = [[parents reverseObjectEnumerator] allObjects];
    NSArray *FParent = [NewParents firstObject];
    id object = [FParent objectAtIndex:1];
    NSString *type = [FParent objectAtIndex:0];
    NSString *Key_Index = [FParent objectAtIndex:2];
    if ([type isEqualToString:@"Array"])
    {
        int index = [[[_selectedKey.stringValue substringFromIndex:NSMaxRange([_selectedKey.stringValue rangeOfString:@"Item "])] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] intValue];
        [object removeObjectAtIndex:index];
    }
    else if ([type isEqualToString:@"Dictionary"])
    {
        [object removeObjectForKey:beforKey];
    }
    for (int i = 1; i < NewParents.count ; i++)
    {
        id TmpObject = [[NewParents objectAtIndex:i] objectAtIndex:1];
        NSString *Tmptype = [[NewParents objectAtIndex:i] objectAtIndex:0];
        if ([Tmptype isEqualToString:@"Array"])
        {
            [TmpObject replaceObjectAtIndex:[Key_Index intValue] withObject:object];
        }
        else if ([Tmptype isEqualToString:@"Dictionary"])
        {
            [TmpObject removeObjectForKey:Key_Index];
            
            [TmpObject setObject:object forKey:Key_Index];
        }
        object = TmpObject;
        Key_Index = [[NewParents objectAtIndex:i] objectAtIndex:2];
    }
    [self refreshOutLineView:object];
}

- (BOOL)isPureInt:(NSString*)string
{
    NSScanner* scan = [NSScanner scannerWithString:string];
    int val;
    return[scan scanInt:&val] && [scan isAtEnd];
}

-(IBAction)Add:(id)sender
{
    if ([_selectedKey.stringValue length] == 0)
    {
        return;
    }
    NSArray * NewParentItems = [[parentItems reverseObjectEnumerator] allObjects];
    NSMutableArray *parents = [NSMutableArray new];
    if (PlistArray != nil)
    {
        [parents addObject:@[@"Array",PlistArray,@"Root"]];
    }
    else if (PlistDictionary != nil)
    {
        [parents addObject:@[@"Dictionary",PlistDictionary,@"Root"]];
    }
    for (int i = 0; i < NewParentItems.count ; i++)
    {
        id object = [[parents lastObject] objectAtIndex:1];
        NSString *type = [[parents lastObject] objectAtIndex:0];
        SimpleNodeData *Adata = [[NewParentItems objectAtIndex:i] representedObject];
        if ([type isEqualToString:@"Array"])
        {
            int index = [[[Adata.name substringFromIndex:NSMaxRange([Adata.name rangeOfString:@"Item "])] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] intValue];
            id Tobject = [object objectAtIndex:index];
            [parents addObject:@[Adata.type,Tobject,[NSString stringWithFormat:@"%d",index]]];
        }
        else if ([type isEqualToString:@"Dictionary"])
        {
            id Tobject = [object objectForKey:Adata.name];
            [parents addObject:@[Adata.type,Tobject,Adata.name]];
        }
    }
    NSArray * NewParents = [[parents reverseObjectEnumerator] allObjects];
    NSArray *FParent = [NewParents firstObject];
    id object = [FParent objectAtIndex:1];
    NSString *type = [FParent objectAtIndex:0];
    NSString *Key_Index = [FParent objectAtIndex:2];
    id valueForAdd ;
    if ([_AddType.selectedItem.title isEqualToString:@"Number"])
    {
        if ([self isPureDouble:_AddValue.stringValue])
        {
            valueForAdd = [NSNumber numberWithDouble:[_AddValue.stringValue doubleValue]];
        }else
        {
            [self showAlertViewWith:@"请输入 Number 类型的 Value !!!"];
            _AddValue.stringValue = @"";
            return;
        }
    }
    else if ([_AddType.selectedItem.title isEqualToString:@"Boolean"])
    {
        if ([_AddValue.stringValue isEqualToString:@"YES"] || [_AddValue.stringValue isEqualToString:@"NO"])
        {
            valueForAdd = [NSNumber numberWithBool:[_AddValue.stringValue boolValue]];
        }else
        {
            [self showAlertViewWith:@"请输入 Boolean 类型的 Value ( YES or NO ) !!!"];
            _AddValue.stringValue = @"";
            return;
        }
    }
    else if ([_AddType.selectedItem.title isEqualToString:@"Array"])
    {
        valueForAdd = [NSArray new];
    }
    else if ([_AddType.selectedItem.title isEqualToString:@"Dictionary"])
    {
        valueForAdd = [NSDictionary new];
    }else
    {
        valueForAdd = _AddValue.stringValue;
    }
    if ([_selectedType.stringValue isEqualToString:@"Array"])
    {
        if ([type isEqualToString:@"Array"])
        {
            int index = [[[_selectedKey.stringValue substringFromIndex:NSMaxRange([_selectedKey.stringValue rangeOfString:@"Item "])] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] intValue];
            NSMutableArray *tmp = [NSMutableArray arrayWithArray:[object objectAtIndex:index]];
            int ADDindex = 0;
            if ([_AddKey.stringValue hasPrefix:@"Item "])
            {
                NSString *INDEX = [[_AddKey.stringValue substringFromIndex:NSMaxRange([_AddKey.stringValue rangeOfString:@"Item "])] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                if ([self isPureInt:INDEX])
                {
                    ADDindex = [INDEX intValue];
                }
            }else
            {
                if ([self isPureInt:[_AddKey.stringValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]])
                {
                    ADDindex = [[_AddKey.stringValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] intValue];
                }else
                {
                    [self showAlertViewWith:@"请输入正确的格式 : Item %d 或者 %d !!!"];
                    
                    _AddKey.stringValue = @"";
                    return;
                }
            }
            if (!tmp)
            {
                tmp = [NSMutableArray new];
            }
            if (ADDindex >= tmp.count)
            {
                [tmp addObject:valueForAdd];
            }
            else if (ADDindex <= 0)
            {
                [tmp insertObject:valueForAdd atIndex:0];
            }else
            {
                [tmp insertObject:valueForAdd atIndex:ADDindex];
            }
            [object replaceObjectAtIndex:index withObject:tmp];
        }
        else if ([type isEqualToString:@"Dictionary"])
        {
            NSMutableArray *tmp = [NSMutableArray arrayWithArray:[object objectForKey:_selectedKey.stringValue]];
            int ADDindex = 0;
            if ([_AddKey.stringValue hasPrefix:@"Item "])
            {
                NSString *INDEX = [[_AddKey.stringValue substringFromIndex:NSMaxRange([_AddKey.stringValue rangeOfString:@"Item "])] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                if ([self isPureInt:INDEX])
                {
                    ADDindex = [INDEX intValue];
                }
            }else
            {
                if ([self isPureInt:[_AddKey.stringValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]])
                {
                    ADDindex = [[_AddKey.stringValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] intValue];
                }else
                {
                    [self showAlertViewWith:@"请输入正确的格式 : Item %d 或者 %d !!!"];
                    _AddKey.stringValue = @"";
                    return;
                }
            }
            if (!tmp)
            {
                tmp = [NSMutableArray new];
            }
            if (ADDindex >= tmp.count)
            {
                [tmp addObject:valueForAdd];
            }
            else if (ADDindex <= 0)
            {
                [tmp insertObject:valueForAdd atIndex:0];
            }else
            {
                [tmp insertObject:valueForAdd atIndex:ADDindex];
            }
            [object setObject:tmp forKey:_selectedKey.stringValue];
        }
    }
    else if ([_selectedType.stringValue isEqualToString:@"Dictionary"])
    {
        if ([type isEqualToString:@"Array"])
        {
            int index = [[[_selectedKey.stringValue substringFromIndex:NSMaxRange([_selectedKey.stringValue rangeOfString:@"Item "])] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] intValue];
            NSMutableDictionary *tmp = [NSMutableDictionary dictionaryWithDictionary:[object objectAtIndex:index]];
            if (!tmp) {
                tmp = [NSMutableDictionary new];
            }
            [tmp setObject:valueForAdd forKey:_AddKey.stringValue];
            [object replaceObjectAtIndex:index withObject:tmp];
        }
        else if ([type isEqualToString:@"Dictionary"])
        {
            NSMutableDictionary *tmp = [NSMutableDictionary dictionaryWithDictionary:[object objectForKey:_selectedKey.stringValue]];
            [tmp setObject:valueForAdd forKey:_AddKey.stringValue];
            [object setObject:tmp forKey:_selectedKey.stringValue];
        }
    }
    else if ([type isEqualToString:@"Array"])
    {
        NSMutableArray *Tobject =[NSMutableArray arrayWithArray:object];
        int ADDindex = 0;
        if ([_AddKey.stringValue hasPrefix:@"Item "])
        {
            NSString *INDEX = [[_AddKey.stringValue substringFromIndex:NSMaxRange([_AddKey.stringValue rangeOfString:@"Item "])] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            if ([self isPureInt:INDEX])
            {
                ADDindex = [INDEX intValue];
            }
        }else
        {
            if ([self isPureInt:[_AddKey.stringValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]])
            {
                ADDindex = [[_AddKey.stringValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] intValue];
            }else
            {
                [self showAlertViewWith:@"请输入正确的格式 : Item %d 或者 %d !!!"];
                
                _AddKey.stringValue = @"";
                return;
            }
        }
        if (ADDindex >= Tobject.count)
        {
            [Tobject addObject:valueForAdd];
        }
        else if (ADDindex <= 0)
        {
            [Tobject insertObject:valueForAdd atIndex:0];
        }else
        {
            [Tobject insertObject:valueForAdd atIndex:ADDindex];
        }
        object = Tobject;
    }
    else if ([type isEqualToString:@"Dictionary"])
    {
        NSMutableDictionary *tmp = [NSMutableDictionary dictionaryWithDictionary:object];
        [tmp setObject:valueForAdd forKey:_AddKey.stringValue];
        object = tmp;
    }
    for (int i = 1; i < NewParents.count ; i++)
    {
        id TmpObject = [[NewParents objectAtIndex:i] objectAtIndex:1];
        NSString *Tmptype = [[NewParents objectAtIndex:i] objectAtIndex:0];
        if ([Tmptype isEqualToString:@"Array"])
        {
            [TmpObject replaceObjectAtIndex:[Key_Index intValue] withObject:object];
        }
        else if ([Tmptype isEqualToString:@"Dictionary"])
        {
            [TmpObject removeObjectForKey:Key_Index];
            
            [TmpObject setObject:object forKey:Key_Index];
        }
        object = TmpObject;
        Key_Index = [[NewParents objectAtIndex:i] objectAtIndex:2];
    }
    [self refreshOutLineView:object];
    _AddKey.stringValue = @"";
    _AddValue.stringValue = @"";
}

-(IBAction)Save:(id)sender
{
    if (PlistArray != nil)
    {
        [PlistArray writeToURL:plistURL atomically:YES];
    }
    else if (PlistDictionary != nil)
    {
        [PlistDictionary writeToURL:plistURL atomically:YES];
    }
}

/*-(IBAction)Change:(id)sender
{
    if (parentItems.count > 0)
    {
        NSArray * NewParentItems = [[parentItems reverseObjectEnumerator] allObjects];
        NSMutableArray *parents = [NSMutableArray new];
        if (PlistArray != nil)
        {
            [parents addObject:@[@"Array",PlistArray,@"Root"]];
        }
        else if (PlistDictionary != nil)
        {
            [parents addObject:@[@"Dictionary",PlistDictionary,@"Root"]];
        }
        for (int i = 0; i < NewParentItems.count ; i++)
        {
            id object = [[parents lastObject] objectAtIndex:1];
            NSString *type = [[parents lastObject] objectAtIndex:0];
            SimpleNodeData *Adata = [[NewParentItems objectAtIndex:i] representedObject];
            if ([type isEqualToString:@"Array"])
            {
                int index = [[[Adata.name substringFromIndex:NSMaxRange([Adata.name rangeOfString:@"Item "])] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] intValue];
                id Tobject = [object objectAtIndex:index];
                [parents addObject:@[Adata.type,Tobject,[NSString stringWithFormat:@"%d",index]]];
            }
            else if ([type isEqualToString:@"Dictionary"])
            {
                id Tobject = [object objectForKey:Adata.name];
                [parents addObject:@[Adata.type,Tobject,Adata.name]];
            }
        }
        NSArray * NewParents = [[parents reverseObjectEnumerator] allObjects];
        NSArray *FParent = [NewParents firstObject];
        id object = [FParent objectAtIndex:1];
        NSString *type = [FParent objectAtIndex:0];
        NSString *Key_Index = [FParent objectAtIndex:2];
        if ([type isEqualToString:@"Array"])
        {
            int index = [[[_selectedKey.stringValue substringFromIndex:NSMaxRange([_selectedKey.stringValue rangeOfString:@"Item "])] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] intValue];
            if ([_selectedType.stringValue isEqualToString:@"Number"])
            {
                if ([self isPureDouble:_selectedValue.stringValue])
                {
                    [object replaceObjectAtIndex:index withObject:[NSNumber numberWithDouble:[_selectedValue.stringValue doubleValue]]];
                }else
                {
                    [self showAlertViewWith:@"请输入 Number 类型的 Value !!!"];
                    return;
                }
            }
            else if ([_selectedType.stringValue isEqualToString:@"Boolean"])
            {
                if ([_selectedValue.stringValue isEqualToString:@"YES"] || [_selectedValue.stringValue isEqualToString:@"NO"])
                {
                    [object replaceObjectAtIndex:index withObject:[NSNumber numberWithBool:[_selectedValue.stringValue boolValue]]];
                }else
                {
                    [self showAlertViewWith:@"请输入 Boolean 类型的 Value ( YES or NO ) !!!"];
                    return;
                }
            }else
            {
                [object replaceObjectAtIndex:index withObject:_selectedValue.stringValue];
            }
        }
        else if ([type isEqualToString:@"Dictionary"])
        {
            [object removeObjectForKey:beforKey];
            
            if ([_selectedType.stringValue isEqualToString:@"Number"])
            {
                if ([self isPureDouble:_selectedValue.stringValue])
                {
                    [object setObject:[NSNumber numberWithDouble:[_selectedValue.stringValue doubleValue]] forKey:_selectedKey.stringValue];
                }else
                {
                    [self showAlertViewWith:@"请输入 Number 类型的 Value !!!"];
                    return;
                }
            }
            else if ([_selectedType.stringValue isEqualToString:@"Boolean"])
            {
                if ([_selectedValue.stringValue isEqualToString:@"YES"] || [_selectedValue.stringValue isEqualToString:@"NO"])
                {
                    [object setObject:[NSNumber numberWithBool:[_selectedValue.stringValue boolValue]] forKey:_selectedKey.stringValue];
                }else
                {
                    [self showAlertViewWith:@"请输入 Boolean 类型的 Value ( YES or NO ) !!!"];
                    return;
                }
            }else
            {
                [object setObject:_selectedValue.stringValue forKey:_selectedKey.stringValue];
            }
        }
        for (int i = 1; i < NewParents.count ; i++)
        {
            id TmpObject = [[NewParents objectAtIndex:i] objectAtIndex:1];
            NSString *Tmptype = [[NewParents objectAtIndex:i] objectAtIndex:0];
            if ([Tmptype isEqualToString:@"Array"])
            {
                [TmpObject replaceObjectAtIndex:[Key_Index intValue] withObject:object];
            }
            else if ([Tmptype isEqualToString:@"Dictionary"])
            {
                [TmpObject removeObjectForKey:Key_Index];
                
                [TmpObject setObject:object forKey:Key_Index];
            }
            object = TmpObject;
            Key_Index = [[NewParents objectAtIndex:i] objectAtIndex:2];
        }
        [self refreshOutLineView:object];
    }else
    {
        if (PlistArray != nil)
        {
            int index = [[[_selectedKey.stringValue substringFromIndex:NSMaxRange([_selectedKey.stringValue rangeOfString:@"Item "])] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] intValue];
            if ([_selectedType.stringValue isEqualToString:@"Number"])
            {
                if ([self isPureDouble:_selectedValue.stringValue])
                {
                    [PlistArray replaceObjectAtIndex:index withObject:[NSNumber numberWithDouble:[_selectedValue.stringValue doubleValue]]];
                }else
                {
                    [self showAlertViewWith:@"请输入 Number 类型的 Value !!!"];
                    return;
                }
            }
            else if ([_selectedType.stringValue isEqualToString:@"Boolean"])
            {
                if ([_selectedValue.stringValue isEqualToString:@"YES"] || [_selectedValue.stringValue isEqualToString:@"NO"])
                {
                    [PlistArray replaceObjectAtIndex:index withObject:[NSNumber numberWithBool:[_selectedValue.stringValue boolValue]]];
                }else
                {
                    [self showAlertViewWith:@"请输入 Boolean 类型的 Value ( YES or NO ) !!!"];
                    return;
                }
            }else
            {
                [PlistArray replaceObjectAtIndex:index withObject:_selectedValue.stringValue];
            }
            [self refreshOutLineView:PlistArray];
        }
        else if (PlistDictionary != nil)
        {
            [PlistDictionary removeObjectForKey:beforKey];
            if ([_selectedType.stringValue isEqualToString:@"Number"])
            {
                if ([self isPureDouble:_selectedValue.stringValue])
                {
                    [PlistDictionary setObject:[NSNumber numberWithDouble:[_selectedValue.stringValue doubleValue]] forKey:_selectedKey.stringValue];
                }else
                {
                    [self showAlertViewWith:@"请输入 Number 类型的 Value !!!"];
                    return;
                }
            }
            else if ([_selectedType.stringValue isEqualToString:@"Boolean"])
            {
                if ([_selectedValue.stringValue isEqualToString:@"YES"] || [_selectedValue.stringValue isEqualToString:@"NO"])
                {
                    [PlistDictionary setObject:[NSNumber numberWithBool:[_selectedValue.stringValue boolValue]] forKey:_selectedKey.stringValue];
                }else
                {
                    [self showAlertViewWith:@"请输入 Boolean 类型的 Value ( YES or NO ) !!!"];
                    return;
                }
            }else
            {
                [PlistDictionary setObject:_selectedValue.stringValue forKey:_selectedKey.stringValue];
            }
            [self refreshOutLineView:PlistDictionary];
        }
    }
}*/

@end
