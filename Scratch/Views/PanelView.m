//
//  PanelView.m
//  Scratch
//
//  Created by hanks on 2/12/15.
//  Copyright (c) 2015 com.hanks. All rights reserved.
//

#import "PanelView.h"

// Define the size of the cursor that
// will be drawn in the view for each
// finger on the trackpad
static const NSInteger kFingerCursorSize = 20;
// Define the color values that will
// be used for the finger cursor
static const CGFloat kFingerCursorRed = 1.0;
static const CGFloat kFingerCursorGreen = 0.0;
static const CGFloat kFingerCursorBlue = 0.0;
static const CGFloat kFingerCursorAlpha = 0.5;
// click number for double click detectin
static const NSInteger kDoubleClickCount = 2;

@interface PanelView() {
    BOOL m_cursorIsHidden;
    BOOL m_mouseIsInView;
    BOOL m_switchIsOn;
}

@property (strong, nonatomic) NSMutableDictionary *m_activeTouches;

@end

@implementation PanelView

- (void)awakeFromNib {
    // init
    _m_activeTouches = [[NSMutableDictionary alloc] init];
    m_cursorIsHidden = NO;
    m_mouseIsInView = NO;
    m_switchIsOn = NO;
    
    // Accept trackpad events
    self.acceptsTouchEvents = YES;
}

- (void)drawFocusRing {
    // Preserve the graphics content
    // so that other things we draw
    // don't get focus rings
    [NSGraphicsContext saveGraphicsState];
    // color the background transparent
    [[NSColor clearColor] set];
    // If this view has accepted first responder
    // it should draw the focus ring
    if ([[self window] firstResponder] == self &&
        (YES == m_mouseIsInView)) {
        NSSetFocusRingStyle(NSFocusRingAbove);
    }
    // Fill the view with fully transparent
    // color so that we can see through it
    // to whatever is below
    [[NSBezierPath bezierPathWithRect:[self bounds]] fill];
    // Restore the graphics content
    // so that other things we draw
    // don't get focus rings
    [NSGraphicsContext restoreGraphicsState];
}

- (void)drawTouchPoint {
    // For each active touch
    for (NSTouch *l_touch in self.m_activeTouches.allValues)
    {
        // Create a rectangle reference to hold the
        // location of the cursor
        NSRect l_cursor;
        
        // Determine where the touch point
        NSPoint l_touchNP = [l_touch normalizedPosition];
        // Calculate the pixel position of the touch point
        l_touchNP.x = l_touchNP.x * [self bounds].size.width;
        l_touchNP.y = l_touchNP.y * [self bounds].size.height;
        
        // Calculate the rectangle around the cursor
        l_cursor.origin.x = l_touchNP.x - (kFingerCursorSize /
                                           2);
        l_cursor.origin.y = l_touchNP.y - (kFingerCursorSize /
                                           2);
        l_cursor.size.width = kFingerCursorSize;
        l_cursor.size.height = kFingerCursorSize;
        
        // Set the color of the cursor
        [[NSColor colorWithDeviceRed: kFingerCursorRed
                               green: kFingerCursorGreen
                                blue: kFingerCursorBlue
                               alpha: kFingerCursorAlpha] set];
        
        // Draw the cursor as a circle
        [[NSBezierPath bezierPathWithOvalInRect: l_cursor] fill];
    }
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    if (m_switchIsOn) {
        [self drawFocusRing];
        [self drawTouchPoint];
    }
}

- (BOOL)acceptsFirstResponder {
    return YES;
}

# pragma mark -- Mouse Evnet
- (void)viewDidMoveToWindow {
    // is the view window valid
    if ([self window] != nil) {
        // add a tracking rect such that
        // mouse entered, and mouse exited;
        // method will be automatically invoked
        [self addTrackingRect:[self bounds]
                        owner:self
                     userData:NULL
                 assumeInside:NO];
    }
}

- (void)mouseEntered:(NSEvent *)theEvent {
    DDLogInfo(@"mouse enter");
    m_mouseIsInView = YES;
    [self setNeedsDisplay:YES];
}

- (void)mouseExited:(NSEvent *)theEvent {
    DDLogInfo(@"mouse exit");
    m_mouseIsInView = NO;
    [self setNeedsDisplay:YES];
}

- (void)mouseDown:(NSEvent *)theEvent {
    if ([theEvent clickCount] == kDoubleClickCount) {
        DDLogInfo(@"double click");
        if (m_switchIsOn) {
            [self showMouseCursor];
        } else {
            [self hideMouseCursor];
        }
        
        m_switchIsOn = !m_switchIsOn;
    }
}

#pragma mark -- Right Mouse Event

- (void)rightMouseDragged:(NSEvent *)theEvent {
    DDLogInfo(@"right mouse dragged");
    NSWindow *window = [self window];
    NSPoint windowOrigin = [window frame].origin;
    
    [window setFrameOrigin:NSMakePoint(windowOrigin.x + [theEvent deltaX], windowOrigin.y - [theEvent deltaY])];
}

# pragma mark -- Touch Evnet

- (void)hideMouseCursor {
    // If the mouse curosr is not already hidden
    if (NO == m_cursorIsHidden) {
        DDLogInfo(@"hide mouse curse");
        CGAssociateMouseAndMouseCursorPosition(false);
        
        // hide the mousr cursor
        [NSCursor hide];
        
        // remember that we detached and hide the mousr cursor
        m_cursorIsHidden = YES;
    }
}

- (void)showMouseCursor {
    // If the mouse curosr is not already hidden
    if (YES == m_cursorIsHidden) {
        DDLogInfo(@"show mouse curse");
        CGAssociateMouseAndMouseCursorPosition(true);
        
        // hide the mousr cursor
        [NSCursor unhide];
        
        // remember that we detached and hide the mousr cursor
        m_cursorIsHidden = NO;
    }
}

- (void)touchesBeganWithEvent:(NSEvent *)event {
    DDLogInfo(@"began touch");
    
    // Get the set of began touches
    NSSet *l_touches =
    [event touchesMatchingPhase:NSTouchPhaseBegan
                         inView:self];
    
    // For each began touch, add the touch
    // to the active touches dictionary
    // using its identity as the key
    for (NSTouch *l_touch in l_touches) {
        [self.m_activeTouches setObject:l_touch forKey:l_touch.
         identity];
    }
    
    // Redisplay the view
    [self setNeedsDisplay:YES];
}

- (void)touchesMovedWithEvent:(NSEvent *)event {
    NSSet *l_touches =
    [event touchesMatchingPhase:NSTouchPhaseMoved
                         inView:self];
    
    
    // For each move touch, update the touch
    // in the active touches dictionary
    // using its identity as the key
    for (NSTouch *l_touch in l_touches) {
        // Update the touch only if it is found
        // in the active touches dictionary
        if ([self.m_activeTouches objectForKey:l_touch.identity]) {
            [self.m_activeTouches setObject:l_touch
                                forKey:l_touch.identity];
        }
    }
    
    // Redisplay the view
    [self setNeedsDisplay:YES];
}

- (void)touchesEndedWithEvent:(NSEvent *)event {
    DDLogInfo(@"end touch");
    
    // Get the set of ended touches
    NSSet *l_touches =
    [event touchesMatchingPhase:NSTouchPhaseEnded
                         inView:self];
    
    
    // For each ended touch, remove the touch
    // from the active touches dictionary
    // using its identity as the key
    for (NSTouch *l_touch in l_touches) {
        [self.m_activeTouches removeObjectForKey:l_touch.identity];
    }
    
    // Redisplay the view
    [self setNeedsDisplay:YES];
}

- (void)touchesCancelledWithEvent:(NSEvent *)event {
    DDLogInfo(@"cancel touch");
    
    // Get the set of cancelled touches
    NSSet *l_touches =
    [event touchesMatchingPhase:NSTouchPhaseCancelled
                         inView:self];
    
    // For each cancelled touch, remove the touch
    // from the active touches dictionary
    // using its identity as the key
    for (NSTouch *l_touch in l_touches) {
        [self.m_activeTouches removeObjectForKey:l_touch.identity];
    }

    // Redisplay the view
    [self setNeedsDisplay:YES];
}

# pragma mark -- Gesture event
- (void)magnifyWithEvent:(NSEvent *)event {
    CGFloat magcificaton = [event magnification];
    DDLogInfo(@"magnification value: %lf", magcificaton);
    
    // set window size
    NSWindow *window = [self window];
    NSRect newRect;
    newRect.size.width = window.frame.size.width * (magcificaton / 2 + 1.0);
    newRect.size.height = window.frame.size.height * (magcificaton / 2 + 1.0);
    newRect.origin.x = window.frame.origin.x;
    newRect.origin.y = window.frame.origin.y;
    
    [window setFrame:newRect display:YES];
}

@end
