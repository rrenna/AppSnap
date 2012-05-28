//
//  WindowSnapper.m
//  App Snap
//
//  Created by Ryan Renna on 11-03-20.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "WindowSnapper.h"


@implementation WindowSnapper
@synthesize UseStockDesktopBackground;
@synthesize HideDesktopIcons;
@synthesize SmartTransform;
@synthesize WindowSize;
@synthesize WindowOrigin;

-(id)init
{
    self = [super init];
    if(self)
    {
        self.UseStockDesktopBackground = NO;
        self.HideDesktopIcons = NO;
        self.SmartTransform = NO;
    }
    return self;
}
-(void) dealloc
{
    //UseStockDesktopBackground - do not release
    //HideDesktopIcons - do not release
    //SmartTransform - do not release
    //WindowSize - do not release
    //WindowOrigin - do not release
    [super dealloc];
}
-(NSString*)ensureValid
{
    int width,height;
    NSArray* screens  = [NSScreen screens];
    NSDictionary* selectedWindow = ([self.Windows count] > 0) ? [self.Windows objectAtIndex:0] : nil;
    
    //Ensure user isn't selecting a window on a non-main window
    if(selectedWindow && screens)
    {
        NSScreen* firstScreen = [screens objectAtIndex:0];
        NSString* selectedWindowOriginString = [selectedWindow objectForKey:@"windowOrigin"];
        NSArray* stringComponentsForWindowsOrigin = [selectedWindowOriginString componentsSeparatedByString:@"/"];
        NSArray* windowSizeComponents = [[selectedWindow objectForKey:@"windowSize"] componentsSeparatedByString:@"*"];
        
        CGRect firstScreenFrame = [firstScreen frame];
        NSPoint origin;
        origin.x = [[stringComponentsForWindowsOrigin objectAtIndex:0] intValue];
        origin.y = [[stringComponentsForWindowsOrigin objectAtIndex:1] intValue];
        self.WindowOrigin = origin;
        
        CGSize size;
        size.width = [[windowSizeComponents objectAtIndex:0] intValue];
        size.height = [[windowSizeComponents objectAtIndex:1] intValue];
        self.WindowSize = size;
       
        
        //On 2nd monitor to the right
        if(origin.x > firstScreenFrame.origin.x + firstScreenFrame.size.width || self.WindowOrigin.x < firstScreenFrame.origin.x - firstScreenFrame.size.width)
        {
            self.Valid = NO;
            return NSLocalizedString(@"App Snap doesn't currently support multiple viewing devices, move the window to your primary monitor.",nil);
            //[[NSAlert alertWithMessageText:@"I'm confused" defaultButton:@"Ok" alternateButton:nil otherButton:nil informativeTextWithFormat:@"App Snap doesn't currently support multiple viewing devices, move the window to your primary monitor."] runModal];
        }
    }
    else
    {
        self.Valid = NO;
        return NSLocalizedString(@"A valid window is not selected.",nil);
    }
    
    return nil;
}
-(void)setCaptureArea
{
    //Find desktop size & Set bounds of snap helper
    //self.ScreenFrame = [window screen].frame;
    self.ScreenFrame = [NSScreen mainScreen].frame;
    CGRect screenOriginFrame = CGRectMake(0, 0, self.ScreenFrame.size.width, self.ScreenFrame.size.height);
    [self.Helper setImageBounds:self.ScreenFrame];
    //Decide if we're scaling this desktop
    if(self.SmartTransform)
    {
        int pixelCount = self.ScreenFrame.size.width * self.ScreenFrame.size.height;
        int dif1280 = (1280*800) - pixelCount;
        int dif1440 = (1440*900) - pixelCount;
        //Screen is <= 1280x800
        if(dif1280 < dif1440)
        {
            self.RenderFrame = CGRectMake(0, 0, 1280, 800);
        }
        //Screen is => 1440*900
        else
        {
            self.RenderFrame = CGRectMake(0, 0, 1440, 900);
        }
    }
    else
    {
        self.RenderFrame = screenOriginFrame;
    }
}
-(NSString*)collectBackgroundLayers
{
    if(!self.UseStockDesktopBackground)
    {
        //Capture user desktop elements
        [self.BackgroundWindows addObjectsFromArray:[self.Helper getInformationForWindowsNamed:@"Window Server"]];
    }
    
    //Add finder windows if hide desktop icons is off
    if(!self.HideDesktopIcons)
    {
        [self.BackgroundWindows addObjectsFromArray:[self.Helper getInformationForWindowsNamed:@"Finder"]];
    }
    
    return nil;
}
-(void)drawBackground
{
    //If injecting desktop, must be done first
    if(self.UseStockDesktopBackground)
    {
        NSImage* stockDesktop = [NSImage imageNamed:@"stock-desktop"];
        CGRect stockBackgroundFrame = CGRectMake(0, 0, 1280, 800);
        [stockDesktop drawInRect:self.RenderFrame fromRect:stockBackgroundFrame operation:NSCompositeSourceOver fraction:1.0];
    }
    [super drawBackground];
}
-(void)drawForeground
{
    //If we're auto scaling the background, we have to smart translate the window so that it stays within the new bounds
    if(self.SmartTransform)
    {
        int xPadding = (self.RenderFrame.size.width - self.WindowSize.width) / 2;
        int yPadding = (self.RenderFrame.size.height - self.WindowSize.height) / 2;
        [self.Helper setImageBounds:CGRectMake(self.WindowOrigin.x  - xPadding, self.WindowOrigin.y  - yPadding, 1200, 800)];
    }
    [super drawForeground];
}
@end
