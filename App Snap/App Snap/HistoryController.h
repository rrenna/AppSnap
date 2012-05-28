//
//  HistoryController.h
//  App Snap
//
//  Created by Ryan Renna on 11-03-24.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>

@interface HistoryController : NSViewController 
{
    int selectedIndexForSaveEvent;
}
@property (retain) IBOutlet IKImageBrowserView* ImageBrowserView;
@property (retain) IBOutlet NSMutableArray* Items;

-(IBAction)clearHistory:(id)sender;

-(void)addImageByPath:(NSString*)path;
-(void)scanCacheDirectory;

@end
