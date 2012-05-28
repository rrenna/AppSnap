//
//  WindowPickerController.h
//  App Snap
//
//  Created by Ryan Renna on 11-02-16.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "WindowSnapHelper.h"

@interface WindowPickerController : NSViewController <NSTableViewDelegate,NSTableViewDataSource>
{   
}
@property (retain) WindowSnapHelper* snapHelper;
@property (retain) NSString* selectedWindowName;
@property (assign) NSNumber* selectedWindowID;
@property (retain) NSArray* filteredWindowNames;
@property (retain) NSMutableArray* windowArray;
@property (retain,nonatomic) IBOutlet NSImageView* imageView;
@property (retain,nonatomic) IBOutlet NSTableView* tableView;
@property (retain,nonatomic) IBOutlet NSButton* closeButton;
@property (retain,nonatomic) IBOutlet NSTextField* usageTipLabel;

-(void)refresh;
-(IBAction)dismiss : (id)sender;
-(IBAction)tableViewSelected : (id)sender;
@end
