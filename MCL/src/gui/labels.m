#import "MCL/gui/labels.h"
#import "MCL/frame.h"

#import <Cocoa/Cocoa.h>

void MCL_AddLabel(MCL_Frame *frame, MCL_Label label) {
    // check if frame is null
            if (!frame) {
        fprintf(stderr, "Failed to add label! The frame is null!\n");
        return;
    }
    // get the ns view
    NSView *nsView = (__bridge NSView *)(frame->_this);

    // create the label
    NSString *labelText = [NSString stringWithUTF8String:label.text];
    NSRect frameRect = NSMakeRect(label.x, label.y, 0, 0);
    NSTextField *nsLabel = [[NSTextField alloc] initWithFrame:frameRect];
    NSColor *labelColor = [NSColor colorWithCalibratedRed:label.color.r
                                                    green:label.color.g
                                                    blue:label.color.b
                                                    alpha:label.color.a];
    // set the label text
    [nsLabel setStringValue:labelText];
    // set the label color
    [nsLabel setTextColor:labelColor];
    // set the label font
    NSString *labelFontName = [NSString stringWithUTF8String:label.font];
    NSFont *labelFont = [NSFont fontWithName:labelFontName size:label.font_size];
    [nsLabel setFont:labelFont];
    [nsLabel sizeToFit];
    // set the label's properties
    [nsLabel setEditable:NO];
    [nsLabel setBordered:NO];
    [nsLabel setDrawsBackground:NO];

    // add the label to the view
    [nsView addSubview:nsLabel];
    [nsView setNeedsDisplay:YES];
}

void MCL_RemoveLabel(MCL_Frame *frame, MCL_Label label)
{

}

void MCL_GetAvailableFonts()
{
    NSArray *fontFamilies = [NSFontManager sharedFontManager].availableFontFamilies;
    for (NSString *fontFamily in fontFamilies) {
        printf("%s\n", [fontFamily UTF8String]);
    }
}