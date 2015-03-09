//
//  PanelView.m
//  Scratch
//
//  Created by hanks on 2/12/15.
//  Copyright (c) 2015 com.hanks. All rights reserved.
//

#import "PanelView.h"

@implementation PanelView

@synthesize m_activeTouches;

- (id)initWithFrame:(NSRect)frameRect {
    self = [super initWithFrame:frameRect];
    if (self) {
        // init
        m_activeTouches = [[NSMutableDictionary alloc] init];
        
        // Accept trackpad events
        [self setAcceptsTouchEvents:YES];
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
    // For each active touch
    for (NSTouch *l_touch in m_activeTouches.allValues)
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
        l_cursor.origin.x = l_touchNP.x - (D_FINGER_CURSOR_SIZE /
                                           2);
        l_cursor.origin.y = l_touchNP.y - (D_FINGER_CURSOR_SIZE /
                                           2);
        l_cursor.size.width = D_FINGER_CURSOR_SIZE;
        l_cursor.size.height = D_FINGER_CURSOR_SIZE;
        
        // Set the color of the cursor
        [[NSColor colorWithDeviceRed: D_FINGER_CURSOR_RED
                               green: D_FINGER_CURSOR_GREEN
                                blue: D_FINGER_CURSOR_BLUE 
                               alpha: D_FINGER_CURSOR_ALPHA] set];
        
        // Draw the cursor as a circle
        [[NSBezierPath bezierPathWithOvalInRect: l_cursor] fill];
    }
    
    // preserve the graphics content
    [NSGraphicsContext saveGraphicsState];
    
    [[NSColor clearColor] set];
    
    if ([[self window] firstResponder] == self) {
        NSSetFocusRingStyle(NSFocusRingAbove);
    }
    
    [[NSBezierPath bezierPathWithRect:[self bounds]] fill];
    
    [NSGraphicsContext restoreGraphicsState];
}

- (BOOL)acceptsFirstResponder {
    return YES;
}

- (void)touchesBeganWithEvent:(NSEvent *)event {
    NSLog(@"began touch");
    
    // Get the set of began touches
    NSSet *l_touches =
    [event touchesMatchingPhase:NSTouchPhaseBegan
                         inView:self];
    
    // For each began touch, add the touch
    // to the active touches dictionary
    // using its identity as the key
    for (NSTouch *l_touch in l_touches)
    {
        [m_activeTouches setObject:l_touch forKey:l_touch.
         identity];
    }
    
    // Redisplay the view
    [self setNeedsDisplay:YES];
}

- (void)touchesMovedWithEvent:(NSEvent *)event {
    NSLog(@"move touch");
    
    NSSet *l_touches =
    [event touchesMatchingPhase:NSTouchPhaseMoved
                         inView:self];
    
    
    // For each move touch, update the touch
    // in the active touches dictionary
    // using its identity as the key
    for (NSTouch *l_touch in l_touches)
    {
        // Update the touch only if it is found
        // in the active touches dictionary
        if ([m_activeTouches objectForKey:l_touch.identity])
        {
            [m_activeTouches setObject:l_touch
                                forKey:l_touch.identity];
        }
    }
    
    // Redisplay the view
    [self setNeedsDisplay:YES];
}

- (void)touchesEndedWithEvent:(NSEvent *)event {
    NSLog(@"end touch");
    
    // Get the set of ended touches
    NSSet *l_touches =
    [event touchesMatchingPhase:NSTouchPhaseEnded
                         inView:self];
    
    
    // For each ended touch, remove the touch
    // from the active touches dictionary
    // using its identity as the key
    for (NSTouch *l_touch in l_touches)
    {
        [m_activeTouches removeObjectForKey:l_touch.identity];
    }
    
    // Redisplay the view
    [self setNeedsDisplay:YES];
}

- (void)touchesCancelledWithEvent:(NSEvent *)event {
    NSLog(@"cancel touch");
    
    // Get the set of cancelled touches
    NSSet *l_touches =
    [event touchesMatchingPhase:NSTouchPhaseCancelled
                         inView:self];
    
    // For each cancelled touch, remove the touch
    // from the active touches dictionary
    // using its identity as the key
    for (NSTouch *l_touch in l_touches)
    {
        [m_activeTouches removeObjectForKey:l_touch.identity];
    }
    
    // Redisplay the view
    [self setNeedsDisplay:YES];
}

@end
