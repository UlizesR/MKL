#import "MIA/m_view.h"
#import "MIA/m_window.h"

#import <Cocoa/Cocoa.h>
#include <stdio.h>

@implementation M_NSView
- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
}
@end

static int viewIDCounter = 0; // Initialize view ID counter

M_View* M_AddSubView(M_View* parent, int width, int height, int x, int y, float corner_radius, M_Color background_color)
{
    // Check if the parent view is NULL
    if (parent == NULL) {
        fprintf(stderr, "Error: Parent view is NULL\n");
        return NULL;
    }
    // Allocate memory for the subview and check if it failed
    M_View* subView = (M_View*)malloc(sizeof(M_View));
    if (subView == NULL) {
        fprintf(stderr, "Error: Failed to allocate memory for subview\n");
        return NULL;
    }
    // Set the subview's properties
    subView->background_color = background_color;
    subView->corner_radius = corner_radius;
    subView->size.width = width;
    subView->size.height = height;
    subView->position.x = x;
    subView->position.y = y;
    subView->id = viewIDCounter++;
    subView->parent = parent;
    // Create the NSView
    NSRect frame = NSMakeRect(x, y, width, height);
    M_NSView* nsView = [[M_NSView alloc] initWithFrame:frame];
    // Set the background color
    NSColor* bgColor = [NSColor colorWithRed:background_color.r
                                        green:background_color.g
                                        blue:background_color.b
                                        alpha:background_color.a];
    [nsView setWantsLayer:YES];
    [nsView.layer setBackgroundColor:bgColor.CGColor];
    // Set the corner radius
    [nsView.layer setCornerRadius:corner_radius];
    // redraw the view
    [nsView setNeedsDisplay:YES];
    // Add the NSView to the parent view
    NSView* parentView = (__bridge NSView*)parent->_this;
    [parentView addSubview:nsView];
    // Set the Objective-C view to the subview's _this property
    subView->_this = (__bridge void*)nsView;
    // Return the subview
    return subView;
}

M_View* M_AddContentView(M_Window* parent, M_Color background_color)
{
    // Check if the parent window is NULL
    if (parent == NULL) {
        fprintf(stderr, "Error: Parent window is NULL\n");
        return NULL;
    }
    // Allocate memory for the content view and check if it failed
    M_View* contentView = (M_View*)malloc(sizeof(M_View));
    if (contentView == NULL) {
        fprintf(stderr, "Error: Failed to allocate memory for content view\n");
        return NULL;
    }
    // Set the content view's properties
    contentView->background_color = background_color;
    contentView->size.width = parent->size.width;
    contentView->size.height = parent->size.height;
    contentView->position.x = 0;
    contentView->position.y = 0;
    contentView->id = viewIDCounter++;
    contentView->parent = NULL;
    // Create the NSView
    NSRect frame = NSMakeRect(0, 0, parent->size.width, parent->size.height);
    M_NSView* nsView = [[M_NSView alloc] initWithFrame:frame];
    // Set the background color
    NSColor* bgColor = [NSColor colorWithRed:background_color.r
                                        green:background_color.g
                                        blue:background_color.b
                                        alpha:background_color.a];
    [nsView setWantsLayer:YES];
    [nsView.layer setBackgroundColor:bgColor.CGColor];
    // redraw the view
    [nsView setNeedsDisplay:YES];
    // Add the NSView to the parent window
    NSWindow* parentWindow = (__bridge NSWindow*)parent->delegate;
    [parentWindow setContentView:nsView];
    // Set the Objective-C view to the content view's _this property
    contentView->_this = (__bridge void*)nsView;
    parent->content_view = contentView;
    // Return the content view
    return contentView;
}

void M_ChangeViewBGColor(M_View* view, M_Color color)
{
    // Check if the view is NULL
    if (view == NULL)
    {
        printf("ERROR: View is NULL. Cannot change background color.\n");
        return;
    }
    // Set the background color
    NSColor* nsColor = [NSColor colorWithRed:color.r green:color.g blue:color.b alpha:color.a];
    // Get the Objective-C view from the view's _this property
    M_NSView* nsView = (__bridge M_NSView*)view->_this;
    // Set the background color
    [nsView.layer setBackgroundColor:nsColor.CGColor];
    // redraw the view
    [nsView setNeedsDisplay:YES];
}

void M_HideView(M_View* view) 
{
    // Check if the view is NULL
    if (view == NULL) {
        printf("ERROR: View is NULL. Cannot hide the view.\n");
        return;
    }
    // Get the Objective-C view from the view's _this property
    NSView* nsView = (__bridge M_NSView*)view->_this;
    // Hide the view
    [nsView setHidden:YES];
}

void M_ShowView(M_View *view)
{
    // Check if the view is NULL
    if (view == NULL) {
        printf("ERROR: View is NULL. Cannot hide the view.\n");
        return;
    }
    // Get the Objective-C view from the view's _this property
    NSView* nsView = (__bridge M_NSView*)view->_this;
    // Show the view
    [nsView setHidden:NO];
}

void M_DestroyView(M_View* view)
{
    // Check if the view is NULL
    if (view == NULL) {
        printf("ERROR: View is NULL. Cannot destroy the view.\n");
        return;
    }
    if (view->parent == NULL) {
        printf("ERROR: Content view is destroyed in M_DestroyWindow function.\n");
        return;
    }
    // Get the Objective-C view from the view's _this property
    M_NSView* nsview = (__bridge M_NSView*)view->_this;
    // Remove the Objective-C view from its superview
    [nsview removeFromSuperview];
    // Free the allocated view memory
    free(view);
}