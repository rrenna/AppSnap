//
//  WindowPickerController.m
//  App Snap
//
//  Created by Ryan Renna on 11-02-16.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "WindowPickerController.h"
#import "RegexKitLite.h"

@implementation WindowPickerController
@synthesize snapHelper;
@synthesize selectedWindowName;
@synthesize selectedWindowID;
@synthesize filteredWindowNames;
@synthesize windowArray;
@synthesize imageView;
@synthesize tableView;
@synthesize closeButton;
@synthesize usageTipLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
    {
        // Initialization code here.
        self.filteredWindowNames = [NSArray arrayWithObjects:@"Finder",@"SystemUIServer",@"Window Server",@"Dock",@"Xcode",@"iTunes",@"App Store",nil];
        [self refresh];
    }
    return self;
}
- (void)loadView 
{
    [super loadView];
    [self.closeButton setTitle:NSLocalizedString(@"Close", nil)];
    [self.usageTipLabel setTitleWithMnemonic:NSLocalizedString(@"Window must be on screen", nil)];
}
- (void)dealloc
{
    [snapHelper release];
    [selectedWindowName release];
    [selectedWindowID release];
    [filteredWindowNames release];
    [windowArray release];
    [imageView release];
    [tableView release];
    [closeButton release];
    [usageTipLabel release];
    [super dealloc];
}
/* IBActions */
-(IBAction)dismiss : (id)sender
{
    [self.view.window setIsVisible:NO];
}
/* Custom Methods */
-(void)refresh
{
    self.windowArray = [NSMutableArray new];
    self.snapHelper = [[[WindowSnapHelper alloc] init] autorelease];
    
    for(NSDictionary* window in [self.snapHelper windowList])
    {
        BOOL valid = YES;
        int width = 0;
        int height = 0;
        const int minWidth = 150;
        const int minHeight = 150;
        
        NSString* windowName = [window objectForKey:@"applicationName"];
        NSArray* windowSizeComponents = [[window objectForKey:@"windowSize"] componentsSeparatedByString:@"*"];
        
        NSLog(@"%@",windowName);
        
        if([windowSizeComponents count] > 1)
        {
            width = [[windowSizeComponents objectAtIndex:0] intValue];
            height = [[windowSizeComponents objectAtIndex:1] intValue];
        }
        
        for(NSString* filteredWindowName in self.filteredWindowNames)
        {
            //If too small, or in the ignore list, mark as invalid
            if
            (
               (width < minWidth || height < minHeight) ||
               ([windowName rangeOfString:filteredWindowName].location != NSNotFound)
            )
            {
                valid = NO;
                break;
            }
        }
        if(valid)
        {
            [self.windowArray addObject:window];
        }
    }
    //Reload table
    [tableView reloadData];
}
/* NSTableview datasource and delegate methods */
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return [self.windowArray count];
}
- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    NSDictionary* window = [self.windowArray objectAtIndex:row];
    if([[tableColumn identifier] isEqualToString:@"name"])
    {
        return [window objectForKey:@"applicationName"];
    }
    else
    {
         return [window objectForKey:@"windowSize"];
    }
}
-(BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row
{
    NSDictionary* window = [windowArray objectAtIndex:row];
    NSString* windowName = [window objectForKey:@"applicationName"];
    NSNumber* windowIDNumber = [window objectForKey:@"windowID"];
    CGWindowID windowID = (CGWindowID)[windowIDNumber intValue];
    
    //This was an attempt to extract the application name, and run an applescript command to bring that application to the screen
    //NSString* applicationName = [[windowName stringByReplacingOccurrencesOfRegex:@"(.*)(\\(.*\\))" withString:@"$1"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    //Maximize the windows of this Application, to ensure a Snap can be taken
    //NSString * source = @"tell application \"System Events\" to set visible of process \"%@\" to true";
    //NSAppleScript * script = [[NSAppleScript alloc] initWithSource:[NSString stringWithFormat:source,applicationName]];
    //[script executeAndReturnError:nil];
    //[script release];

    
    //Sets the bounds to zero to hug the graphical element
    [snapHelper setImageBounds:CGRectZero];
    NSImage* image = [snapHelper createSingleWindowShot:windowID];
    [self.imageView setImage:image];
    //Sets the selected window name
    self.selectedWindowName = windowName;
    self.selectedWindowID = windowIDNumber;
    //Notify app that a new window has been selected
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_WINDOW_PICKER_WINDOW_SELECTED object:nil];
    return YES;
}
@end
