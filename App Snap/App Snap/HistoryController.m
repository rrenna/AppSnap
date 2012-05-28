//
//  HistoryController.m
//  App Snap
//
//  Created by Ryan Renna on 11-03-24.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Quartz/Quartz.h>

@interface HistoryImage : NSObject
{
}
@property (retain) NSString* path;
@property (retain) NSString* name;
@property (retain) NSString* UUID;
@property (retain) NSString* title;
@property (retain) NSString* subtitle;
@end

@implementation HistoryImage
@synthesize path;
@synthesize name;
@synthesize UUID;
@synthesize title;
@synthesize subtitle;

- (void) dealloc
{
    [path release];
    [name release];
    [UUID release];
    [title release];
    [subtitle release];
    [super dealloc];
}
- (NSString *)  imageRepresentationType
{
	return IKImageBrowserPathRepresentationType;
}
- (id)  imageRepresentation
{
	return path;
}
- (NSString *) imageUID
{
    return UUID;
}
- (id) imageTitle
{
	return title;
}
- (id) imageSubtitle
{
    return subtitle;
}
@end


#import "HistoryController.h"

@implementation HistoryController
@synthesize ImageBrowserView;
@synthesize Items;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
    {
        self.Items = [[[NSMutableArray alloc] init] autorelease];
        //Add all images currently cached
        [self scanCacheDirectory];
    }
    return self;
}
- (void) awakeFromNib
{
    [ImageBrowserView reloadData];
    [ImageBrowserView setDraggingDestinationDelegate:self];
}
- (void)dealloc
{
    [ImageBrowserView release];
    [Items release];
    [super dealloc];
}
//IBActions 
-(IBAction)clearHistory:(id)sender
{
    [self.Items removeAllObjects];
    
    NSString *bundleName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString* path = [[paths objectAtIndex:0] stringByAppendingPathComponent:bundleName];
    NSFileManager *flManager = [NSFileManager defaultManager];
    BOOL isDir;
    //If cache folder exists, iterate over child folders
    if([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir] && isDir)
    {
        [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
    }
    //Refresh history
    [ImageBrowserView reloadData];
}
//Custom Methods
-(void)addImageByName : (NSString*)name andPath:(NSString*)path forType:(NSString*)snapType
{
    //Add image to history
    HistoryImage* historyImage = [[HistoryImage alloc] init];
    historyImage.name = name;
    historyImage.path = path;
    //historyImage.title = @"title";
    historyImage.subtitle = snapType;
    historyImage.UUID = [NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970]];
    //
    [Items insertObject:historyImage atIndex:0];
    [historyImage release]; 
    //Refresh history
    [ImageBrowserView reloadData];
}
-(void)scanCacheDirectory
{
    NSString *bundleName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString* path = [[paths objectAtIndex:0] stringByAppendingPathComponent:bundleName];
    NSFileManager *flManager = [NSFileManager defaultManager];
    BOOL isDir;
    //If cache folder exists, iterate over child folders
    if([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir] && isDir)
    {
        NSArray *ContentOfCache=[[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:NULL];
        int contentcount=[ContentOfCache count];
        int i;
        for(i=0;i<contentcount;i++)
        {
            NSString *fileName=[ContentOfCache objectAtIndex:i];
			NSString* subpath = [NSString stringWithFormat:@"%@/%@",path,fileName];
            
            [[NSFileManager defaultManager] fileExistsAtPath:subpath isDirectory:&isDir];
            //Ignore non-directory children
            if(isDir)
            {
                NSArray *ContentOfType =[[NSFileManager defaultManager] contentsOfDirectoryAtPath:subpath error:NULL];
                for(NSString* subfileName in ContentOfType)
                {
                    NSString* subfilePath = [NSString stringWithFormat:@"%@/%@",subpath,subfileName];
                    [self addImageByName: subfileName andPath:subfilePath forType:fileName];
                }
            }				
        }
    }
}
-(void)saveImageAtSelectedIndex : (id) sender
{
    //Get HistoryImage to set default filename
    HistoryImage* file = [self.Items objectAtIndex:selectedIndexForSaveEvent];
    
    NSSavePanel *spanel = [NSSavePanel savePanel];
    NSString *path = @"/";
    [spanel setDirectory:[path stringByExpandingTildeInPath]];
    [spanel setPrompt:NSLocalizedString(@"Save",nil)];
    //[spanel setRequiredFileType:@"rtfd"];
    [spanel beginSheetForDirectory:NSHomeDirectory()
                              file:file.name
                    modalForWindow:[[self view] window]
                     modalDelegate:self
                    didEndSelector:@selector(didEndSaveSheet:returnCode:conextInfo:)
                       contextInfo:NULL];
    
}
//NSSavePanel Methods
-(void)didEndSaveSheet:(NSSavePanel *)savePanel returnCode:(int)returnCode conextInfo:(void *)contextInfo
{
    //Save selected image if 'Save' is pressed
    if (returnCode == NSOKButton)
    {
        //Get HistoryImage to copy it to it's new destination
        HistoryImage* file = [self.Items objectAtIndex:selectedIndexForSaveEvent];
        
        NSString* destination = [[savePanel URL] absoluteString];
        //Filter out 'file:/' substring
        NSRange rangeOfUnwantedCharacters = [destination rangeOfString:@"file://localhost"];
        if(rangeOfUnwantedCharacters.length > 0)
        {
            destination = [destination substringFromIndex:rangeOfUnwantedCharacters.length];
        }
        NSFileManager * fm = [NSFileManager defaultManager];
    

        
        //Save image at desired path
        NSError * error = nil;

        if(![fm copyItemAtPath:file.path toPath:destination error:&error])
            NSLog(@"error: %@", error);
        
    }
}
//IKImageBrowserView Delegate & Datasource Methods
- (void) imageBrowser:(IKImageBrowserView *) aBrowser cellWasDoubleClickedAtIndex:(NSUInteger) index
{
}
- (NSUInteger) numberOfItemsInImageBrowser:(IKImageBrowserView *) aBrowser
{
    return [Items count];
}
- (id) imageBrowser:(IKImageBrowserView *) aBrowser itemAtIndex:(NSUInteger)index
{
    return [Items objectAtIndex:index];
}
- (void) imageBrowser:(IKImageBrowserView *) aBrowser
cellWasRightClickedAtIndex:(NSUInteger) index withEvent:(NSEvent *)
event
{
    //Set selected index globally
    selectedIndexForSaveEvent = index;
    
    //contextual menu for item index
    NSMenu*  menu;
    menu = [[NSMenu alloc] initWithTitle:@"menu"];
    [menu setAutoenablesItems:NO];
    
    [menu addItemWithTitle:[NSString stringWithFormat:NSLocalizedString(@"Save As...", nil)] action:
     @selector(saveImageAtSelectedIndex:) keyEquivalent:@""];    
    [NSMenu popUpContextMenu:menu withEvent:event forView:aBrowser];
    
    [menu release];
}
@end
