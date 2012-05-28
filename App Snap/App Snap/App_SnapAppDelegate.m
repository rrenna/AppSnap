//
//  App_SnapAppDelegate.m
//  App Snap
//
//  Created by Ryan Renna on 11-02-13.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "App_SnapAppDelegate.h"
#import "WindowSnapper.h"
#import "IOSSimulatorSnapper.h"
#import "AndroidSimulatorSnapper.h"
#import "HistoryController.h"

@implementation App_SnapAppDelegate
@synthesize window;
@synthesize settings;
@synthesize snapper;
@synthesize snapHelper;
@synthesize historyController;
@synthesize appMode;
@synthesize autoSave;
@synthesize cropiOSSimulator;
@synthesize cropiOSToolbar;
@synthesize cropAndroidSimulator;
@synthesize hideDesktopIcons;
@synthesize useStockDesktopBackground;
@synthesize resizeDesktop;
@synthesize windowPickerController;
@synthesize toolbar;
@synthesize imageView;
@synthesize drawer;
@synthesize pathControl;
@synthesize appOptionsTabView;
@synthesize cropiOSToolbarButton;
@synthesize windowPickerButton;
@synthesize autoSaveButton;
@synthesize autoSaveView;
@synthesize finderButton;
@synthesize snapTipLabel;
@synthesize iOSCropSimulatorTipLabel;
@synthesize windowSelectTipLabel;
@synthesize androidCropSimulatorTipLabel;

- (void)applicationWillFinishLaunching:(NSNotification *)notification
{
    NSLog(@"x");
}
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    self.snapHelper = [[[WindowSnapHelper alloc] init] autorelease];
    
    // Set HOTKEY for SNAP button
	DDHotKeyCenter * c = [[DDHotKeyCenter alloc] init];
	if (![c registerHotKeyWithKeyCode:1 modifierFlags:NSAlternateKeyMask target:self action:@selector(snap:) object:nil]) 
    {
	} 
    else 
    {
	}
	[c release];
    
    //Check if there's been a auto-save directory stored in NSUserDefaults
    NSString* lastAutoSavedSnapDirectory = [[NSUserDefaults standardUserDefaults] valueForKey:@"lastAutoSavedSnapDirectory"];
    if(lastAutoSavedSnapDirectory)
    {
        //Only set the path control to the stored folder if the destination still exists, and is writable
        if([[NSFileManager defaultManager] fileExistsAtPath:lastAutoSavedSnapDirectory] && [[NSFileManager defaultManager] isWritableFileAtPath:lastAutoSavedSnapDirectory])
        {
            //Need to use fileURLWithPath as NSPathControl has to know this is a file url it's dealing with
            [pathControl setURL:[NSURL fileURLWithPath:lastAutoSavedSnapDirectory]];
            
        }
    }
    //If there is no auto-save location saved, this is the first startup, we'll default to a '/' path
    else
    {
        NSString* defaultPath = @"/";
        [pathControl setURL:[NSURL fileURLWithPath:defaultPath]];
    }
    
    //Subscribes to notification of when the window selector is used
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateWindowPickerButtonTitle) name:NOTIFICATION_WINDOW_PICKER_WINDOW_SELECTED object:nil];
    
    [self changeToIOSAppMode:nil];
    //AutoSave is off by default now that we've added history
    self.autoSave = NO;
    self.cropiOSSimulator = YES;
    self.cropiOSToolbar = YES;
    self.cropAndroidSimulator = YES;
    self.useStockDesktopBackground = YES;
    self.hideDesktopIcons = YES;
    self.resizeDesktop = YES;
    
    //Handle localization
    [self.finderButton setTitle:NSLocalizedString(@"Finder", nil)];
    [self.windowPickerButton setTitle:NSLocalizedString(@"No Window Selected", nil)];
    [self.snapTipLabel setTitleWithMnemonic:NSLocalizedString(@"Saves every Snap to the chosen location", nil)];
    [self.iOSCropSimulatorTipLabel setTitleWithMnemonic:NSLocalizedString(@"Crops out the iPhone or iPad simulator. Required for uploading to iTunes Connect",nil)];
    NSString* x = NSLocalizedString(@"Select the window of the Mac App you would like to Snap", nil);
    [self.windowSelectTipLabel setTitleWithMnemonic:NSLocalizedString(@"Select the window of the Mac App you would like to Snap", nil)];
    [self.androidCropSimulatorTipLabel setTitleWithMnemonic:NSLocalizedString(@"Crops out the Android simulator",nil)];
}
- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [snapper release];
    [snapHelper release];
    //appMode - do not release
    //cropiOSSimulator - do not release
    //cropiOSToolbar - do not release
    //cropAndroidSimulator - do not release
    //useStockDesktopBackground - do not release
    //resizeDesktop - do not release
    [windowPickerController release];
    [historyController release];
    [drawer release];
    [toolbar release];
    [appOptionsTabView release];
    [imageView release];
    [pathControl release];
    [cropiOSToolbarButton release];
    [windowPickerButton release];
    [autoSaveButton release];
    [autoSaveView release];
    [finderButton release];
    [snapTipLabel release];
    [iOSCropSimulatorTipLabel release];
    [androidCropSimulatorTipLabel release];
    [windowSelectTipLabel release];
    [super dealloc];
}
- (BOOL)applicationShouldHandleReopen:(NSApplication *)theApplication hasVisibleWindows:(BOOL)flag
{
    [window orderFront:nil];
    return YES;
}
-(BOOL) applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication
{
    return NO;
}
/* Action Sheet Management */
- (void)didEndSheet:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
    [windowPickerController.view.window orderOut:self];
}
#pragma mark - IBActions
-(IBAction)snap : (id)sender
{
    NSImage* resultingImage = nil;
    NSString* snapType = nil;
    
    if(self.appMode == APP_MODE_IOS)
    {
        snapType = @"iOS";
        IOSSimulatorSnapper* iosSnapper = [[IOSSimulatorSnapper alloc] initWithHelper:self.snapHelper];
        iosSnapper.CropSimulator = self.cropiOSSimulator;
        iosSnapper.CropToolbar = self.cropiOSToolbar;
        //Support for various Languages - 'iOS Simulator' is not universal 
        NSString* iOSSimulatorWindowName = NSLocalizedString(@"ios simulator", nil);
        
        resultingImage = [iosSnapper SnapWithWindowName:iOSSimulatorWindowName];
        [iosSnapper release];
    }
    else if(self.appMode == APP_MODE_MAC)
    {
        snapType = @"Mac OS";
        WindowSnapper* windowSnapper = [[WindowSnapper alloc] initWithHelper:self.snapHelper];
        //Hook up Options from UI
        windowSnapper.SmartTransform = self.resizeDesktop;
        windowSnapper.HideDesktopIcons = self.hideDesktopIcons;
        windowSnapper.UseStockDesktopBackground = self.useStockDesktopBackground;
        
        resultingImage = [windowSnapper SnapWithWindowID:[self.windowPickerController.selectedWindowID intValue]];
        [windowSnapper release];
    }
    else
    {
        snapType = @"Android";
        AndroidSimulatorSnapper* androidSnapper = [[AndroidSimulatorSnapper alloc] initWithHelper:self.snapHelper];
        androidSnapper.CropSimulator = self.cropAndroidSimulator;
        
        resultingImage = [androidSnapper SnapWithWindowName:@"emulator"];
        [androidSnapper release];
    }
    
    //If image was produced, store in history
    if(resultingImage)
    {
        [self processImage:resultingImage forType:snapType];
        
        //This won't open the drawer if the app is not visible
        // or if no image was captured
        if([window isVisible])
        {
            //Open the image preview drawer
            [drawer open];
        }
    }
}
-(IBAction) setPathControlDirectory : (id)sender
{
	NSPathControl* control = (NSPathControl*)sender;
	NSURL* path = [[control clickedPathComponentCell] URL];
	[pathControl setURL:path];
}
-(IBAction)openMainWindow : (id) sender
{
        [window orderFront:nil];
}
-(IBAction)openHistory : (id)sender
{
    if(!self.historyController)
    {
        // Create history controller
        self.historyController = [[[HistoryController alloc] initWithNibName:@"History" bundle:nil] autorelease];
    }
    
    if(![self.historyController.view.window isVisible])
    {
        [self.historyController.view.window makeKeyAndOrderFront:sender];
    }
}
-(IBAction)openWindowPicker : (id)sender
{
    if(!self.windowPickerController)
    {
        //Create window picker controller
        self.windowPickerController = [[[WindowPickerController alloc] initWithNibName:@"WindowPicker" bundle:nil] autorelease];
    }
    else
    {
        //If this isn't the first time openning the window picker, refresh it's window list
        [self.windowPickerController refresh];
    }
    
    if(! [self.windowPickerController.view.window isVisible] )
    {
        [self.windowPickerController.view.window makeKeyAndOrderFront:sender];
    }
}
-(IBAction)openAutoSavePath : (id)sender
{
    [[NSWorkspace sharedWorkspace] openURL:[pathControl URL]];
}
-(IBAction)changeiOSCropSimulator:(id)sender
{
    NSButton* button = (NSButton*)sender;
    if([button state] == 0)
    {
        self.cropiOSSimulator = NO;
        //Fade out dependant control
        [[cropiOSToolbarButton animator] setAlphaValue:0.0];
    }
    else
    {
        self.cropiOSSimulator = YES;
        //Fade in dependant control
        [[cropiOSToolbarButton animator] setAlphaValue:1.0];
    }
}
-(IBAction)changeiOSCropToolbar:(id)sender
{
    NSButton* button = (NSButton*)sender;
    if([button state] == 0)
    {
        self.cropiOSToolbar = NO;
    }
    else
    {
        self.cropiOSToolbar = YES;
    }
}
-(IBAction)changeAndroidCropSimulator:(id)sender
{
    NSButton* button = (NSButton*)sender;
    if([button state] == 0)
    {
        self.cropAndroidSimulator = NO;
    }
    else
    {
        self.cropAndroidSimulator = YES;
    }
}
-(IBAction)changeAutoSave:(id)sender
{
    NSButton* button = (NSButton*)sender;
    CGRect autoSaveButtonFrame = self.autoSaveButton.frame;
    double autoSaveButtonNewOriginY;
    
    if([button state] == 0)
    {
        self.autoSave = NO;

        //disable all interaction
        for(NSView* subview in [self.autoSaveView subviews])
        {
            if([subview respondsToSelector:@selector(setEnabled:)])
            {
                [subview setEnabled:NO];
            }
        }
    }
    else
    {
        self.autoSave = YES;
        //disable all interaction
        for(NSView* subview in [self.autoSaveView subviews])
        {
            if([subview respondsToSelector:@selector(setEnabled:)])
            {
                [subview setEnabled:YES];
            }
        }
        
    }
}
-(IBAction)changeUseStockDesktop :(id)sender
{
    NSButton* button = (NSButton*)sender;
    if([button state] == 0)
    {
        self.useStockDesktopBackground = NO;
    }
    else
    {
        self.useStockDesktopBackground = YES;
    }
    
}
-(IBAction)changeHideDesktopIcons:(id)sender
{
    NSButton* button = (NSButton*)sender;
    if([button state] == 0)
    {
        self.hideDesktopIcons = NO;
    }
    else
    {
        self.hideDesktopIcons = YES;
    }
}
-(IBAction)changeResizeDesktop :(id)sender
{
    NSButton* button = (NSButton*)sender;
    if([button state] == 0)
    {
        self.resizeDesktop = NO;
    }
    else
    {
        self.resizeDesktop = YES;
    }
}
-(IBAction)changeToIOSAppMode : (id)sender
{
    self.appMode = APP_MODE_IOS;
    [toolbar setSelectedItemIdentifier:@"iOS"];
    [appOptionsTabView selectTabViewItemAtIndex:0];
}
-(IBAction)changeToMacAppMode : (id)sender
{
    self.appMode = APP_MODE_MAC;
    [toolbar setSelectedItemIdentifier:@"Mac"];
    [appOptionsTabView selectTabViewItemAtIndex:1];
}
-(IBAction)changeToAndroidAppMode : (id)sender
{
    self.appMode = APP_MODE_ANDROID;
    [toolbar setSelectedItemIdentifier:@"Android"];
    [appOptionsTabView selectTabViewItemAtIndex:2];
}
-(IBAction)flipToWindow:(id)sender
{
    [window flipToShowWindow:settings forward:YES];
}
-(IBAction)flipToSettings:(id)sender
{
    [settings flipToShowWindow:window forward:YES];
}
- (IBAction)flipAction:(id)sender 
{
	[self performSelector:([NSApp keyWindow]==window)?@selector(flipToWindow:):@selector(flipToSettings:) withObject:nil afterDelay:0.0];
}
#pragma mark
-(void)processImage : (NSImage*)image forType: (NSString*) snapType
{
    [imageView setImage:image];
    
    NSDateComponents* components = [[NSCalendar currentCalendar] components:NSMinuteCalendarUnit | NSSecondCalendarUnit | NSHourCalendarUnit fromDate:[NSDate date]];
    
    int hour = [components hour];
    int minute = [components minute];
    int second = [components second];
    
    NSString* amPm = (hour >= 12) ? @"pm" : @"am";
    NSString* filename = [NSString stringWithFormat:@"snap-%i.%i.%i.%@.png",hour % 12,minute,second,amPm];
    
    NSData *imageData = [image TIFFRepresentation];
    NSBitmapImageRep *imageRep = [NSBitmapImageRep imageRepWithData:imageData];
    NSDictionary *imageProps = [NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:1.0] forKey:NSImageCompressionFactor];
    imageData = [imageRep representationUsingType:NSPNGFileType properties:imageProps];

    //If auto save is enabled, save the image in the auto save folder
    if (self.autoSave) 
    {
        NSString* path = [NSString stringWithFormat:@"%@/%@",[[pathControl URL] path],filename];
        BOOL saved = [imageData writeToFile:path atomically:NO];
        
        if(saved)
        {
            //If this is a confirmed legit auto-save path, save the path in the NSUserDefaults for next time
            [[NSUserDefaults standardUserDefaults] setValue:[[pathControl URL] path] forKey:@"lastAutoSavedSnapDirectory"];
        }
        else
        {
            //TODO : alert box if this didn't work
        }
    }
    //Save in Cache directory
    NSString *path = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    //Retrive path to Cache directory
    if ([paths count])
    {
        NSString *bundleName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
        path = [[paths objectAtIndex:0] stringByAppendingPathComponent:bundleName];
        NSString* typePath = [NSString stringWithFormat:@"%@/%@",path,snapType];
        
        //Ensure cache folder for app exists
        BOOL *isDir;
        if(![[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir])
        {
            [[NSFileManager defaultManager] createDirectoryAtPath:path attributes:nil]; 
        }
        //Ensure snap type folder for app exists
        if(![[NSFileManager defaultManager] fileExistsAtPath:typePath isDirectory:&isDir])
        {
            [[NSFileManager defaultManager] createDirectoryAtPath:typePath attributes:nil]; 
        }
        
        path = [NSString stringWithFormat:@"%@/%@",typePath,filename];
        
        BOOL saved = [imageData writeToFile:path atomically:NO];
    }
    [self.historyController addImageByName:filename andPath:path forType:snapType];
}
-(void)updateWindowPickerButtonTitle
{
    if(self.windowPickerController.selectedWindowName)
    {
        windowPickerButton.title = self.windowPickerController.selectedWindowName;
    }
}
@end
