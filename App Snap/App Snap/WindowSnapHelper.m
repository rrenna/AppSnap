//
//  WindowSnapController.m
//  App Snap
//
//  Created by Ryan Renna on 11-02-13.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "WindowSnapHelper.h"


@implementation WindowSnapHelper
@synthesize windowArray;

typedef struct
{
	// Where to add window information
	NSMutableArray * outputArray;
	// Tracks the index of the window when first inserted
	// so that we can always request that the windows be drawn in order.
	int order;
} WindowListApplierData;
enum
{
	// Constants that correspond to the rows in the
	// Single Window Option matrix.
	kSingleWindowAboveOnly = 0,
	kSingleWindowAboveIncluded = 1,
	kSingleWindowOnly = 2,
	kSingleWindowBelowIncluded = 3,
	kSingleWindowBelowOnly = 4,
};
NSString *kAppNameKey = @"applicationName";	// Application Name & PID
NSString *kWindowOriginKey = @"windowOrigin";	// Window Origin as a string
NSString *kWindowSizeKey = @"windowSize";		// Window Size as a string
NSString *kWindowIDKey = @"windowID";			// Window ID
NSString *kWindowLevelKey = @"windowLevel";	// Window Level
NSString *kWindowOrderKey = @"windowOrder";	// The overall front-to-back ordering of the windows as returned by the window server

// Simple helper to twiddle bits in a uint32_t. 
/*uint32_t ChangeBits(uint32_t currentBits, uint32_t flagsToChange, BOOL setFlags)
{
	if(setFlags)
	{	// Set Bits
		return currentBits | flagsToChange;
	}
	else
	{	// Clear Bits
		return currentBits & ~flagsToChange;
	}
}*/

- (id)init
{
    self = [super init];
    if (self) {
        
        // Set the initial list options to match the UI.
        listOptions = kCGWindowListOptionAll;
        
        /*listOptions = ChangeBits(listOptions, kCGWindowListOptionOnScreenOnly, [listOffscreenWindows intValue] == NSOffState);
        listOptions = ChangeBits(listOptions, kCGWindowListExcludeDesktopElements, [listDesktopWindows intValue] == NSOffState);
        
        // Set the initial image options to match the UI.
        imageOptions = kCGWindowImageDefault;
        imageOptions = ChangeBits(imageOptions, kCGWindowImageBoundsIgnoreFraming, [imageFramingEffects intValue] == NSOnState);
        imageOptions = ChangeBits(imageOptions, kCGWindowImageShouldBeOpaque, [imageOpaqueImage intValue] == NSOnState);
        imageOptions = ChangeBits(imageOptions, kCGWindowImageOnlyShadows, [imageShadowsOnly intValue] == NSOnState);
        */
         
        // Set initial single window options to match the UI.
        singleWindowListOptions = [self singleWindowOption];
        
        // CGWindowListCreateImage & CGWindowListCreateImageFromArray will determine their image size dependent on the passed in bounds.
        // This sample only demonstrates passing either CGRectInfinite to get an image the size of the desktop
        // or passing CGRectNull to get an image that tightly fits the windows specified, but you can pass any rect you like.
        
        imageBounds = CGRectInfinite;
        
        //Set flags
        imageOptions = 0;
    }
    
    return self;
}
- (void)dealloc
{
    [windowArray release];
    [super dealloc];
}
-(CGWindowListOption)singleWindowOption
{
    //Always the window selected and nothing more
    return kCGWindowListOptionIncludingWindow;
}
void WindowListApplierFunction(const void *inputDictionary, void *context);
void WindowListApplierFunction(const void *inputDictionary, void *context)
{
	NSDictionary *entry = (NSDictionary*)inputDictionary;
	WindowListApplierData *data = (WindowListApplierData*)context;
	
	// The flags that we pass to CGWindowListCopyWindowInfo will automatically filter out most undesirable windows.
	// However, it is possible that we will get back a window that we cannot read from, so we'll filter those out manually.
	int sharingState = [[entry objectForKey:(id)kCGWindowSharingState] intValue];
	if(sharingState != kCGWindowSharingNone)
	{
		NSMutableDictionary *outputEntry = [[[NSMutableDictionary alloc] init] autorelease];
		
		// Grab the application name, but since it's optional we need to check before we can use it.
		NSString *applicationName = [entry objectForKey:(id)kCGWindowOwnerName];
		if(applicationName != NULL)
		{
			// PID is required so we assume it's present.
			NSString *nameAndPID = [NSString stringWithFormat:@"%@ (%@)", applicationName, [entry objectForKey:(id)kCGWindowOwnerPID]];
			[outputEntry setObject:nameAndPID forKey: kAppNameKey];
		}
		else
		{
			// The application name was not provided, so we use a fake application name to designate this.
			// PID is required so we assume it's present.
			NSString *nameAndPID = [NSString stringWithFormat:@"((unknown)) (%@)", [entry objectForKey:(id)kCGWindowOwnerPID]];
			[outputEntry setObject:nameAndPID forKey:kAppNameKey];
		}
		
		// Grab the Window Bounds, it's a dictionary in the array, but we want to display it as a string
		CGRect bounds;
		CGRectMakeWithDictionaryRepresentation((CFDictionaryRef)[entry objectForKey:(id)kCGWindowBounds], &bounds);
		NSString *originString = [NSString stringWithFormat:@"%.0f/%.0f", bounds.origin.x, bounds.origin.y];
		[outputEntry setObject:originString forKey:kWindowOriginKey];
		NSString *sizeString = [NSString stringWithFormat:@"%.0f*%.0f", bounds.size.width, bounds.size.height];
		[outputEntry setObject:sizeString forKey:kWindowSizeKey];
		
		// Grab the Window ID & Window Level. Both are required, so just copy from one to the other
		[outputEntry setObject:[entry objectForKey:(id)kCGWindowNumber] forKey:kWindowIDKey];
		[outputEntry setObject:[entry objectForKey:(id)kCGWindowLayer] forKey:kWindowLevelKey];
		
		// Finally, we are passed the windows in order from front to back by the window server
		// Should the user sort the window list we want to retain that order so that screen shots
		// look correct no matter what selection they make, or what order the items are in. We do this
		// by maintaining a window order key that we'll apply later.
		[outputEntry setObject:[NSNumber numberWithInt:data->order] forKey:kWindowOrderKey];
		data->order++;
		
		[data->outputArray addObject:outputEntry];
	}
}
-(void)setImageBounds:(CGRect)bounds
{
    imageBounds = bounds;
}
-(NSArray*)windowList
{
    // Ask the window server for the list of windows.
	CFArrayRef windowList = CGWindowListCopyWindowInfo(listOptions, kCGNullWindowID);
	
	// Copy the returned list, further pruned, to another list. This also adds some bookkeeping
	// information to the list as well as 
	NSMutableArray * prunedWindowList = [NSMutableArray array];
	WindowListApplierData data = {prunedWindowList, 0};
	CFArrayApplyFunction(windowList, CFRangeMake(0, CFArrayGetCount(windowList)), &WindowListApplierFunction, &data);
	CFRelease(windowList);
	
    return prunedWindowList;

}
-(void)updateWindowList
{
	// Ask the window server for the list of windows.
	CFArrayRef windowList = CGWindowListCopyWindowInfo(listOptions, kCGNullWindowID);
	
	// Copy the returned list, further pruned, to another list. This also adds some bookkeeping
	// information to the list as well as 
	NSMutableArray * prunedWindowList = [NSMutableArray array];
	WindowListApplierData data = {prunedWindowList, 0};
	CFArrayApplyFunction(windowList, CFRangeMake(0, CFArrayGetCount(windowList)), &WindowListApplierFunction, &data);
	CFRelease(windowList);
	
	// Set the new window list
	//[arrayController setContent:prunedWindowList];
    self.windowArray = prunedWindowList;
}
-(CFArrayRef)newWindowListFromSelection:(NSArray*)selection
{
	// Create a sort descriptor array. It consists of a single descriptor that sorts based on the kWindowOrderKey in ascending order
	NSArray * sortDescriptors = [NSArray arrayWithObject:[[[NSSortDescriptor alloc] initWithKey:kWindowOrderKey ascending:YES] autorelease]];
    
	// Next sort the selection based on that sort descriptor array
	NSArray * sortedSelection = [selection sortedArrayUsingDescriptors:sortDescriptors];
    
	// Now we Collect the CGWindowIDs from the sorted selection
	CGWindowID *windowIDs = calloc([sortedSelection count], sizeof(CGWindowID));
	int i = 0;
	for(NSMutableDictionary *entry in sortedSelection)
	{
		windowIDs[i++] = [[entry objectForKey:kWindowIDKey] unsignedIntValue];
	}
	// CGWindowListCreateImageFromArray expect a CFArray of *CGWindowID*, not CGWindowID wrapped in a CF/NSNumber
	// Hence we typecast our array above (to avoid the compiler warning) and use NULL CFArray callbacks
	// (because CGWindowID isn't a CF type) to avoid retain/release.
	CFArrayRef windowIDsArray = CFArrayCreate(kCFAllocatorDefault, (const void**)windowIDs, [sortedSelection count], NULL);
	free(windowIDs);
	
	// And send our new array on it's merry way
	return windowIDsArray;
}
-(NSDictionary*)getInformationForWindowID:(CGWindowID)windowID
{
    [self updateWindowList];

    NSDictionary* window = Nil;    
    for(id object in self.windowArray)
    {
        int winid = [[(NSDictionary*)object objectForKey:@"windowID"] intValue];
        if( winid == windowID )
        {
            window = (NSDictionary*)object;
            break;
        }
    }
    return window;
}
-(NSArray*)getInformationForWindowsNamed:(NSString*)name
{
    [self updateWindowList];

    NSMutableArray* windows = [[[NSMutableArray alloc] init] autorelease];
    NSDictionary* window;
    
    for(id object in self.windowArray)
    {
        window = (NSDictionary*)object;
        if([[window objectForKey:@"applicationName"] rangeOfString:name options:NSCaseInsensitiveSearch].location != NSNotFound)
        {
            [windows addObject:window];
        }
    }
    //If no window id was set, there was no window with that name found
    return windows;
}
-(NSImage*)createSingleWindowShot:(CGWindowID)windowID
{
	// Create an image from the passed in windowID with the single window option selected by the user.
	//CGImageRef windowImage = CGWindowListCreateImage(imageBounds, singleWindowListOptions, windowID, imageOptions);
    CGImageRef windowImage = CGWindowListCreateImage(imageBounds, kCGWindowListOptionAll | kCGWindowListOptionIncludingWindow, windowID, imageOptions);
    
    NSBitmapImageRep *bitmapRep = [[NSBitmapImageRep alloc] initWithCGImage:windowImage];
    
    // Create an NSImage and add the bitmap rep to it...
    NSImage *image = [[[NSImage alloc] init] autorelease];
    [image addRepresentation:bitmapRep];
    
    [bitmapRep release];
    CGImageRelease(windowImage);
    return image;
}
-(NSImage*)createMultiWindowShot:(NSArray*)windowArray
{
    // Get the correctly sorted list of window IDs. This is a CFArrayRef because we need to put integers in the array
	// instead of CFTypes or NSObjects.
	CFArrayRef windowIDs = [self newWindowListFromSelection:windowArray];
    
	CGImageRef windowImage = CGWindowListCreateImageFromArray(imageBounds, windowIDs, imageOptions);
    NSBitmapImageRep *bitmapRep = [[NSBitmapImageRep alloc] initWithCGImage:windowImage];
    
    // Create an NSImage and add the bitmap rep to it...
    NSImage *image = [[[NSImage alloc] init] autorelease];
    [image addRepresentation:bitmapRep];
    
    [bitmapRep release];
    CGImageRelease(windowImage);
    return image;
}
@end
