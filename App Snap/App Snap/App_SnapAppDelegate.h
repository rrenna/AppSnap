//
//  App_SnapAppDelegate.h
//  App Snap
//
//  Created by Ryan Renna on 11-02-13.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "WindowSnapHelper.h"
#import "DDHotKeyCenter.h"
#import "HistoryController.h"
#import "WindowPickerController.h"
@class Snapper;

typedef enum
{
    APP_MODE_IOS = 0,
    APP_MODE_MAC = 1,
    APP_MODE_ANDROID = 2
} APP_MODE;

@interface App_SnapAppDelegate : NSObject <NSApplicationDelegate> {
@private
    NSWindow *window;
}

@property (retain) Snapper* snapper;
@property (retain) WindowSnapHelper* snapHelper;
@property (retain) HistoryController* historyController;
@property (retain) WindowPickerController* windowPickerController;
@property (assign) APP_MODE appMode;
@property (assign) BOOL autoSave;
@property (assign) BOOL cropiOSSimulator;
@property (assign) BOOL cropiOSToolbar;
@property (assign) BOOL cropAndroidSimulator;
@property (assign) BOOL useStockDesktopBackground;
@property (assign) BOOL hideDesktopIcons;
@property (assign) BOOL resizeDesktop;
//UI Elements
@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSWindow * settings;
@property (retain,nonatomic) IBOutlet NSToolbar* toolbar;
@property (retain,nonatomic) IBOutlet NSDrawer* drawer;
@property (retain,nonatomic) IBOutlet NSImageView* imageView;
@property (retain,nonatomic) IBOutlet NSTabView* appOptionsTabView;
@property (retain,nonatomic) IBOutlet NSPathControl* pathControl;
@property (retain,nonatomic) IBOutlet NSButton* windowPickerButton;
@property (retain,nonatomic) IBOutlet NSTextField* snapTipLabel;
@property (retain,nonatomic) IBOutlet NSTextField* iOSCropSimulatorTipLabel;
@property (retain,nonatomic) IBOutlet NSTextField* windowSelectTipLabel;
@property (retain,nonatomic) IBOutlet NSTextField* androidCropSimulatorTipLabel;
//Animated Elements
@property (retain,nonatomic) IBOutlet NSButton* cropiOSToolbarButton;
@property (retain,nonatomic) IBOutlet NSButton* autoSaveButton;
@property (retain,nonatomic) IBOutlet NSView* autoSaveView;
@property (retain,nonatomic) IBOutlet NSButton* finderButton;

/* IBActions */
-(IBAction)snap : (id)sender;
-(IBAction)setPathControlDirectory : (id)sender;
-(IBAction)openMainWindow : (id) sender;
-(IBAction)openWindowPicker : (id)sender;
-(IBAction)openHistory : (id)sender;
-(IBAction)openAutoSavePath : (id)sender;
-(IBAction)changeiOSCropSimulator:(id)sender;
-(IBAction)changeiOSCropToolbar:(id)sender;
-(IBAction)changeAndroidCropSimulator:(id)sender;
-(IBAction)changeAutoSave:(id)sender;
-(IBAction)changeHideDesktopIcons:(id)sender;
-(IBAction)changeUseStockDesktop :(id)sender;
-(IBAction)changeResizeDesktop :(id)sender;
-(IBAction)changeToAndroidAppMode : (id)sender;
-(IBAction)changeToIOSAppMode : (id)sender;
-(IBAction)changeToMacAppMode : (id)sender;
-(IBAction)flipToWindow:(id)sender;
-(IBAction)flipToSettings:(id)sender;
- (IBAction)flipAction:(id)sender;
/* Custom Methods */
-(void)androidSnap;
-(void)iOSSnap;
-(void)macSnap;
-(void)processImage : (NSImage*)image forType: (NSString*) snapType;
-(void)updateWindowPickerButtonTitle;
@end
