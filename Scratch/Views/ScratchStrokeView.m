//
//  ScratchStrokeView.m
//  Scratch
//
//  Created by hanks on 3/14/15.
//  Copyright (c) 2015 com.hanks. All rights reserved.
//

#import "ScratchStrokeView.h"

@implementation ScratchStrokeView

- (void)awakeFromNib {
    // init
    DDLogInfo(@"strove view init");
    self.m_Strokes = [[NSMutableArray alloc] init];
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
    
    // colour the background transparent
    [[NSColor whiteColor] set];
    
    // Fill the view with fully transparent
    // color so that we can see through it
    // to whatever is below
    [[NSBezierPath bezierPathWithRect:dirtyRect] fill];
    
    // Get the current graphics context
    NSGraphicsContext *	l_GraphicsContext =
    [NSGraphicsContext currentContext];
    
    // Get the low level Core Graphics context
    // from the high level NSGraphicsContext
    // so that we can use Core Graphics to
    // draw
    CGContextRef l_CGContextRef	=
    (CGContextRef) [l_GraphicsContext graphicsPort];
    
    // We will need to reference the array of
    // points in each store
    NSMutableArray *l_points;
    
    // We will need a reference to individual
    // points
    ScratchPoint *l_point;
    
    // We will need to know how many points
    // are in each stroke
    NSUInteger l_pointCount;
    
    // We will need a reference to the
    // first point in each stroke
    ScratchPoint * l_firsttPoint;
    
    // For all of the active strokes
    for (ScratchStroke *l_stroke in self.m_Strokes )
    {
        // Set the stroke width for line
        // drawing
        CGContextSetLineWidth(l_CGContextRef,
                              [l_stroke width]);
        
        // Set the color for line drawing
        CGContextSetRGBStrokeColor(l_CGContextRef,
                                   [l_stroke red],
                                   [l_stroke green],
                                   [l_stroke blue],
                                   [l_stroke alpha]);
        // Get the array of points
        l_points = [l_stroke points];
        
        // Get the number of points
        l_pointCount = [l_points count];
        
        // Get the first point
        l_firsttPoint = [l_points objectAtIndex:0];
        
        // Create a new path
        CGContextBeginPath(l_CGContextRef);
        
        // Move to the first point of the stroke
        CGContextMoveToPoint(l_CGContextRef,
                             [l_firsttPoint x],
                             [l_firsttPoint y]);
        
        // For the remaining points
        for (NSUInteger i = 1; i < l_pointCount; i++)
        {
            // note the index starts at 1
            // Get the SECOND point
            l_point = [l_points objectAtIndex:i];
            
            // Add a line segment to the stroke
            CGContextAddLineToPoint(l_CGContextRef,
                                    [l_point x],
                                    [l_point y]);
        }
        
        // Draw the path
        CGContextDrawPath(l_CGContextRef,kCGPathStroke);
        
    }
}

- (void) addStroke: (ScratchStroke *)a_stroke {
    [self.m_Strokes addObject: a_stroke];
}

- (void) clear {
    [self.m_Strokes removeAllObjects];
    [self setNeedsDisplay:YES];
}

@end
