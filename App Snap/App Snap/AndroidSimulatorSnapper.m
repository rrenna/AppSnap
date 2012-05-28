//
//  AndroidSimulatorSnapper.m
//  App Snap
//
//  Created by Ryan Renna on 11-03-22.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AndroidSimulatorSnapper.h"


@implementation AndroidSimulatorSnapper

-(NSString*)ensureValid
{
    if([self.Windows count] > 0)
    {
        return nil;
    }
    else
    {
        self.Valid = NO;
        return NSLocalizedString(@"You don't seem to have an instance of the Android Simulator open.", nil);
    }
}

-(void)setCaptureArea
{
    NSDictionary* win = [self.Windows objectAtIndex:0];
    NSNumber* windowIDNumber = [win objectForKey:@"windowID"];
    NSString* sizeStringValue = [win objectForKey:@"windowSize"];
    NSString* originStringValue = [win objectForKey:@"windowOrigin"];
    
    CGWindowID windowID = (CGWindowID)[windowIDNumber intValue];
    int x = [[[originStringValue componentsSeparatedByString:@"/"] objectAtIndex:0] intValue];
    int y = [[[originStringValue componentsSeparatedByString:@"/"] objectAtIndex:1] intValue];
    int width = [[[sizeStringValue componentsSeparatedByString:@"*"] objectAtIndex:0] intValue];
    int height = [[[sizeStringValue componentsSeparatedByString:@"*"] objectAtIndex:1] intValue];
    
    //Construct the bounds
    int leftPadding = 0,rightPadding = 0,bottomPadding = 0,topPadding = 0;
    //Only crop if user selected
    if(self.CropSimulator)
    {
        //HVGA - portrait
        if(width == 791 && height == 556)
        {
            leftPadding = 28;
            rightPadding = 443;
            topPadding = 49;
            bottomPadding = 27;
        }
        //QVGA - portrait
        else if(width == 711 && height == 457)
        {
            leftPadding = 28;
            rightPadding = 443;
            topPadding = 80;
            bottomPadding = 57;
        }
        //WQVGA400 - portrait
        else if(width == 711 && height == 476)
        {
            leftPadding = 28;
            rightPadding = 443;
            topPadding = 49;
            bottomPadding = 27;
        }
        //WQVGA432 - portrait
        else if(width == 711 && height == 508)
        {
            leftPadding = 28;
            rightPadding = 443;
            topPadding = 49;
            bottomPadding = 27;
        }
        //WVGA800 - portrait
        else if(width == 950 && height == 876)
        {
            leftPadding = 27;
            rightPadding = 443;
            topPadding = 49;
            bottomPadding = 27;
        }
        //WVGA854 - portrait
        else if(width == 950 && height == 930)
        {
            leftPadding = 27;
            rightPadding = 443;
            topPadding = 49;
            bottomPadding = 27;
        }
        //WXGA - portrait
        else if(width == 1333 && height == 877)
        {
            leftPadding = 27;
            rightPadding = 26;
            topPadding = 50;
            bottomPadding = 27;
        }

    }
    
    CGRect bounds = CGRectMake(x + leftPadding, y + topPadding, width - leftPadding - rightPadding, height - topPadding - bottomPadding);
    CGRect frame = CGRectMake(0, 0, bounds.size.width, bounds.size.height);
    
    [self.Helper setImageBounds:bounds];
    self.RenderFrame = frame;
    
}

@end
