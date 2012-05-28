//
//  DraggableImageView.m
//  App Snap
//
//  Created by Ryan Renna on 11-02-13.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DraggableImageView.h"


@implementation DraggableImageView

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

-(void)mouseDown:(NSEvent *)e
{
    
    NSPasteboard *pb = [NSPasteboard pasteboardWithName:(NSString *)
                        NSDragPboard];
    if ([e clickCount] > 1) {
        ;
    }
    
    NSArray *types = [NSArray arrayWithObject:NSPasteboardTypeTIFF];
    [pb declareTypes:types owner:nil];
    
    //bool pasted = [pb writeObjects:[NSArray arrayWithObject:self.image]];
    NSData* tiffDataOfImage = [self.image TIFFRepresentation];
    bool pasted = [pb setData:tiffDataOfImage forType:NSPasteboardTypeTIFF];
    
    if (pasted) 
    {
        
        CGRect rect;
        NSPoint origin;
        origin = self.frame.origin;
        
        rect.origin.x = ([e locationInWindow].x - origin.x);
        rect.origin.y = ([e locationInWindow].y - origin.y);
        rect.size.width = 1;
        rect.size.height = 1;
             
        [self dragPromisedFilesOfTypes:types fromRect:rect source:self slideBack:YES event:(NSEvent *)e];
    }
}
- (NSDragOperation) draggingSourceOperationMaskForLocal:(BOOL)flag
{
    return NSDragOperationCopy;
}
- (BOOL) acceptsFirstMouse:(NSEvent *)theEvent
{
    return YES;
}
- (NSArray *)namesOfPromisedFilesDroppedAtDestination:(NSURL *)dropDestination;
{
    NSDateComponents* components = [[NSCalendar currentCalendar] components:NSMinuteCalendarUnit | NSSecondCalendarUnit | NSHourCalendarUnit fromDate:[NSDate date]];
    
    int hour = [components hour];
    int minute = [components minute];
    int second = [components second];
    NSString* amPm = (hour >= 12) ? @"pm" : @"am";
    
    NSString* filename = [NSString stringWithFormat:@"snap - %i.%i.%i.%@.png",hour % 12,minute,second,amPm];
    NSString* path = [NSString stringWithFormat:@"%@/%@",[dropDestination path],filename];

    NSData *imageData = [self.image TIFFRepresentation];
    NSBitmapImageRep *imageRep = [NSBitmapImageRep imageRepWithData:imageData];
    NSDictionary *imageProps = [NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:1.0] forKey:NSImageCompressionFactor];
    imageData = [imageRep representationUsingType:NSPNGFileType properties:imageProps];
        
    BOOL saved = [imageData writeToFile:path atomically: NO];
    return [NSArray arrayWithObject:filename];
}
@end
