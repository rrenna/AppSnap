//
//  IOSSimulatorSnapper.m
//  App Snap
//
//  Created by Ryan Renna on 11-03-21.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "IOSSimulatorSnapper.h"


@implementation IOSSimulatorSnapper
@synthesize CropToolbar;

-(void)dealloc
{
    //CropToolbar - do not release
    [super dealloc];
}

-(NSString*)ensureValid
{
    if([self.Windows count] > 0)
    {
        //Sometimes multiple windows are found, there is a 2nd, useless 'ios simulator' window, remove if found
        
        NSDictionary* win = [self.Windows objectAtIndex:0];
        NSString* originStringValue = [win objectForKey:@"windowOrigin"];
        //We can filter out the secondary window by checking for "100/100"
        if([originStringValue isEqualToString:@"100/100"])
        {
            [self.Windows removeObject:win];
        }
        return nil;
    }
    else
    {
        self.Valid = NO;
        return NSLocalizedString(@"You don't seem to have an instance of the iOS Simulator open.", @"");
    }
}

const int minSimulatorDimension = 320;
-(void)setCaptureArea
{
    NSMutableArray* windowsToRemove = [[NSMutableArray new] autorelease];
    //Iterate over all matching windows and only set the Capture area when a matching
    // window's bounds match a pre-validated size
    for(NSDictionary* window in self.Windows)
    {
        NSString* sizeStringValue = [window objectForKey:@"windowSize"];
        NSString* originStringValue = [window objectForKey:@"windowOrigin"];
        
        int x = [[[originStringValue componentsSeparatedByString:@"/"] objectAtIndex:0] intValue];
        int y = [[[originStringValue componentsSeparatedByString:@"/"] objectAtIndex:1] intValue];
        int width = [[[sizeStringValue componentsSeparatedByString:@"*"] objectAtIndex:0] intValue];
        int height = [[[sizeStringValue componentsSeparatedByString:@"*"] objectAtIndex:1] intValue];
        
        if(width >= minSimulatorDimension && height >= minSimulatorDimension)
        {
            int toolbarHeight = 20;
            //Construct the bounds
            int leftPadding = 0,rightPadding = 0,bottomPadding = 0,topPadding = 0;
            //Only crop if user selected
            if(self.CropSimulator)
            {
                if(width == 368 && height == 716)
                {
                    leftPadding = 24;
                    rightPadding = 24;
                    topPadding = 118;
                    bottomPadding = 118;
                }
                //iPhone - landscape
                else if(width == 716 && height == 368)
                {
                    leftPadding = 118;
                    rightPadding = 118;
                    topPadding = 24;
                    bottomPadding = 24;
                }
                //iPhone Retina 50% - portrait
                else if(width == 402 && height == 584)
                {
                    leftPadding = 41;
                    rightPadding = 41;
                    topPadding = 63;
                    bottomPadding = 41;
                }
                //iPhone Retina 50% - portrait
                else if(width == 562 && height == 424)
                {
                    leftPadding = 41;
                    rightPadding = 41;
                    topPadding = 63;
                    bottomPadding = 41;
                }
                //iPhone Retina 100% - landscape
                else if(width == 724 &  height == 1044)
                {
                    //override toolbar height
                    toolbarHeight = 40;
                    
                    leftPadding = 42;
                    rightPadding = 42;
                    topPadding = 42;
                    bottomPadding = 42;
                }
                //iPhone Retina 100% - landscape - secondary
                else if(width == 1099 &  height == 801)
                {
                    //override toolbar height
                    toolbarHeight = 40;
                    
                    leftPadding = 60;
                    rightPadding = 79;
                    topPadding = 84;
                    bottomPadding = 77;
                }
                //iPhone Retina 100% - portrait
                else if(width == 1044 &  height == 724)
                {
                    //override toolbar height
                    toolbarHeight = 40;
                    
                    leftPadding = 42;
                    rightPadding = 42;
                    topPadding = 42;
                    bottomPadding = 42;
                }                //iPhone Retina 100% - landscape - old
                else if(width == 1099 &  height == 801)
                {
                    leftPadding = 60;
                    rightPadding = 79;
                    topPadding = 84;
                    bottomPadding = 77;
                }
                //iPhone Retina 100% - portrait - secondary
                else if(width == 779 &  height == 1136)
                {
                    //override toolbar height
                    toolbarHeight = 40;
                    
                    leftPadding = 60;
                    rightPadding = 79;
                    topPadding = 99;
                    bottomPadding = 77;
                }
                //iPad 50% - portrait
                else if(width == 466 && height == 616)
                {
                    //override toolbar height
                    toolbarHeight = 10;
                    
                    leftPadding = 41;
                    rightPadding = 41;
                    topPadding = 63;
                    bottomPadding = 41;   
                }
                //iPad 50% - landscape
                else if(width == 594 && height == 488)
                {
                    //override toolbar height
                    toolbarHeight = 10;
                    
                    leftPadding = 41;
                    rightPadding = 41;
                    topPadding = 63;
                    bottomPadding = 41;   
                }
                //iPad 100% - portrait
                else if(width == 852 && height == 1108)
                {
                    leftPadding = 42;
                    rightPadding = 42;
                    topPadding = 42;
                    bottomPadding = 42; 
                }
                //iPad 100% - portrait - secondary
                else if(width == 907 && height == 1185)
                {
                    leftPadding = 60;
                    rightPadding = 79;
                    topPadding = 84;
                    bottomPadding = 77;   
                }
                //iPad 100% - portrait - ternary
                else if(width == 892 && height == 1170)
                {
                    leftPadding = 62;
                    rightPadding = 62;
                    topPadding = 84;
                    bottomPadding = 61;   
                }
                //iPad 100% - landscape
                else if(width == 1108 && height == 852)
                {
                    leftPadding = 42;
                    rightPadding = 42;
                    topPadding = 42;
                    bottomPadding = 42; 
                }
                //iPad 100% - landscape - secondary
                else if(width == 1163 && height == 929)
                {
                    leftPadding = 62;
                    rightPadding = 77;
                    topPadding = 83;
                    bottomPadding = 78; 
                }
                //iPad 100% - landscape - ternary 
                else if (width == 1148 && height == 914)
                {
                    leftPadding = 62;
                    rightPadding = 62;
                    topPadding = 84;
                    bottomPadding = 62; 
                }
            
            }
            
            if(self.CropToolbar)
            {
                topPadding += toolbarHeight;
            }
            
            CGRect bounds = CGRectMake(x + leftPadding, y + topPadding, width - leftPadding - rightPadding, height - topPadding - bottomPadding);
            CGRect frame = CGRectMake(0, 0, bounds.size.width, bounds.size.height);
            
            [self.Helper setImageBounds:bounds];
            self.RenderFrame = frame;
            break; //Break the loop, this is a valid simulator
        }
        else
        {
            //Record this window to be removed
            [windowsToRemove addObject:window];
        }
    }
    //Remove all invalid windows
    [self.Windows removeObjectsInArray:windowsToRemove];
}
@end
