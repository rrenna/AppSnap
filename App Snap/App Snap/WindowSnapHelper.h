//
//  WindowSnapController.h
//  App Snap
//
//  Created by Ryan Renna on 11-02-13.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface WindowSnapHelper : NSObject {
@private
    CGWindowListOption listOptions;
	CGWindowListOption singleWindowListOptions;
	CGWindowImageOption imageOptions;
    CGRect imageBounds;
}
@property (retain) NSMutableArray* windowArray;

-(CGWindowListOption)singleWindowOption;
-(void)setImageBounds:(CGRect)bounds;
-(NSArray*)windowList;
-(void)updateWindowList;
-(CFArrayRef)newWindowListFromSelection:(NSArray*)selection;
-(NSDictionary*)getInformationForWindowID:(CGWindowID)windowID;
-(NSArray*)getInformationForWindowsNamed:(NSString*)name;

-(NSImage*)createSingleWindowShot:(CGWindowID)windowID;
-(NSImage*)createMultiWindowShot:(NSArray*)windowArray;
@end
