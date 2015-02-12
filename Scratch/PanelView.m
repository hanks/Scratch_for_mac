//
//  PanelView.m
//  Scratch
//
//  Created by hanks on 2/12/15.
//  Copyright (c) 2015 com.hanks. All rights reserved.
//

#import "PanelView.h"

@implementation PanelView

- (id)initWithFrame:(NSRect)frameRect {
    self = [super initWithFrame:frameRect];
    if (self) {
        // init
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
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

@end
