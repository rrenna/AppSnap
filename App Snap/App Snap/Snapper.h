//
//  Snapper.h
//  App Snap
//
//  Created by Ryan Renna on 11-03-20.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
@class WindowSnapHelper;

@interface Snapper : NSObject 
{}
@property (retain) WindowSnapHelper* Helper;
@property (retain) NSMutableArray* Windows;
@property (retain) NSMutableArray* BackgroundWindows;
@property (assign) BOOL Valid;
@property (assign) NSRect RenderFrame;
@property (assign) NSRect ScreenFrame;

-(id)initWithHelper:(WindowSnapHelper*)helper;
-(NSImage*)SnapWithWindowName:(NSString*)name;
-(NSImage*)SnapWithWindowID:(int)windowID;
-(NSImage*)SnapWithWindowIDs:(NSArray*)windowIDs;

-(NSString*)ensureValid;
-(void)setCaptureArea;
-(NSString*)collectBackgroundLayers;
-(void)drawBackground;
-(void)drawForeground;
-(NSImage*)transformImage : (NSImage*) image;
@end
