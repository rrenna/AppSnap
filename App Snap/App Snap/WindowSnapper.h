//
//  WindowSnapper.h
//  App Snap
//
//  Created by Ryan Renna on 11-03-20.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Snapper.h"


@interface WindowSnapper : Snapper
{    
} 
@property (assign) BOOL UseStockDesktopBackground;
@property (assign) BOOL HideDesktopIcons;
@property (assign) BOOL SmartTransform;
@property (assign) NSSize WindowSize;
@property (assign) NSPoint WindowOrigin;
@end
