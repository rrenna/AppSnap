//
//  Snapper.m
//  App Snap
//
//  Created by Ryan Renna on 11-03-20.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Snapper.h"
#import "WindowSnapHelper.h"

@interface Snapper ()
-(NSImage*)snap;
-(NSImage*)draw;
@end

@implementation Snapper
@synthesize Helper;
@synthesize Windows;
@synthesize BackgroundWindows;
@synthesize Valid;
@synthesize RenderFrame;
@synthesize ScreenFrame;

-(void)dealloc
{
    [Helper release];
    [Windows release];
    [BackgroundWindows release];
    //Valid - do not release
    //RenderFrame - do not release
    //ScreenFrame - do not release
    [super dealloc];
}

-(id)initWithHelper:(WindowSnapHelper*)helper
{
    self = [self init];
    if(self)
    {
        self.Valid = YES;
        self.Helper = helper;
        self.Windows = [[[NSMutableArray alloc] initWithCapacity:1] autorelease];
        self.BackgroundWindows = [[[NSMutableArray alloc] initWithCapacity:1] autorelease];
    }
    return self;
}
//Private Snap Entry Points
-(NSImage*)snap
{
    NSImage* image;
    NSString* ensureValidError = [self ensureValid];
    NSString* collectBackgroundLayersError = nil;
    
    if(self.Valid)
    {
        collectBackgroundLayersError = [self collectBackgroundLayers];
    }
    
    if(self.Valid)
    {
        [self setCaptureArea];
        image = [self draw];
        image = [self transformImage : image];
        return image;
    }
    else
    {
        //Construct error message
        NSMutableString* errorString = [NSMutableString string];
        if(ensureValidError) 
        {   
            [errorString appendString:ensureValidError];
        }
        if(collectBackgroundLayersError) 
        {
            [errorString appendString:collectBackgroundLayersError];
        }
            
        [[NSAlert alertWithMessageText:NSLocalizedString(@"I'm sorry but...",@"") defaultButton:NSLocalizedString(@"OK",@"") alternateButton:nil otherButton:nil informativeTextWithFormat:@"%@",errorString] runModal];
        return nil;
    }
}
-(NSImage* )draw
{
    NSImage *image = [[[NSImage alloc] initWithSize:self.RenderFrame.size] autorelease];
    [image lockFocus];
    
    [self drawBackground];
    [self drawForeground];
    
    [image unlockFocus];
    return image;
}
//Public Snap Entry Points
-(NSImage*)SnapWithWindowName:(NSString*)name
{
    [self.Windows removeAllObjects];
    
    NSArray* results = [self.Helper getInformationForWindowsNamed:name];
    [self.Windows addObjectsFromArray:results];
    
    return [self snap];
}
-(NSImage*)SnapWithWindowID:(int)windowID
{
    [self.Windows removeAllObjects];
    
    NSDictionary* selectedWindow = [self.Helper getInformationForWindowID:windowID];
    
    if(selectedWindow)
    {
        [self.Windows addObject:selectedWindow];
    }
    return [self snap];
}
-(NSImage*)SnapWithWindowIDs:(NSArray*)windowIDs
{
    return [self snap];
}
//LifeCycle Methods
-(NSString*)ensureValid
{
    //Template method
    return nil;
}
-(void)setCaptureArea
{
    //Template method
}
-(NSString*)collectBackgroundLayers
{
    //Template method
    return nil;
}
-(void)drawBackground
{
    //sort valid desktop elements
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"windowOrder"
                                                  ascending:NO] autorelease];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    NSArray *sortedDesktopElementArray;
    sortedDesktopElementArray = [self.BackgroundWindows sortedArrayUsingDescriptors:sortDescriptors];
    
    //Overlap with valid elements (desktop icons, or real desktop background)
    for(NSDictionary* window in sortedDesktopElementArray)
    {
        //NSString* sizeStringValue = [window objectForKey:@"windowSize"];
        NSNumber* windowIDNumber = [window objectForKey:@"windowID"];
        CGWindowID windowID = (CGWindowID)[windowIDNumber intValue];
        //Retrieve Image
        NSImage* image = [self.Helper createSingleWindowShot:windowID];

        [image drawInRect:self.RenderFrame fromRect:self.ScreenFrame operation:NSCompositeSourceOver fraction:1.0];
    }
}
-(void)drawForeground
{
    //Default functionality : Draw first window in array
    NSDictionary* firstWindow = [self.Windows objectAtIndex:0];
    NSNumber* windowIDNumber = [firstWindow objectForKey:@"windowID"];
    CGWindowID windowID = (CGWindowID)[windowIDNumber intValue];
    
    NSImage* image = [self.Helper createSingleWindowShot:windowID];
    [image drawInRect:self.RenderFrame fromRect:self.RenderFrame operation:NSCompositeSourceOver fraction:1.0];
}
-(NSImage*)transformImage : (NSImage*) image
{
    //Template Methods
    return image;
}
@end
