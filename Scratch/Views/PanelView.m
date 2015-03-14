//
//  PanelView.m
//  Scratch
//
//  Created by hanks on 2/12/15.
//  Copyright (c) 2015 com.hanks. All rights reserved.
//

#import "PanelView.h"
#import "ScratchStroke.h"
#import "ScratchStrokeView.h"

// Define the size of the cursor that
// will be drawn in the view for each
// finger on the trackpad
static const NSInteger kFingerCursorSize = 20;
// Define the color values that will
// be used for the finger cursor
static const CGFloat kFingerCursorRed = 1.0f;
static const CGFloat kFingerCursorGreen = 0.0f;
static const CGFloat kFingerCursorBlue = 0.0f;
static const CGFloat kFingerCursorAlpha = 0.5f;
// click number for double click detectin
static const NSInteger kDoubleClickCount = 2;
// width of stroke
static const CGFloat kStrokeWidth = 2.0f;
// the min number of point to draw
static const NSInteger kMinPoints = 2;

@interface PanelView() {
    BOOL m_cursorIsHidden;
    BOOL m_mouseIsInView;
    BOOL m_switchIsOn;
}

@property (strong, nonatomic) NSMutableDictionary *m_activeTouches;
@property (strong, nonatomic) NSMutableDictionary *m_activeStrokes;

@end

@implementation PanelView

- (void)awakeFromNib {
    // init
    _m_activeTouches = [[NSMutableDictionary alloc] init];
    _m_activeStrokes = [[NSMutableDictionary alloc] init];
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

- (void)drawStroke {
    // Get the current graphics context
    NSGraphicsContext *	l_GraphicsContext = [NSGraphicsContext currentContext];
    
    // Get the low level Core Graphics context
    // from the high level NSGraphicsContext
    // so that we can use Core Graphics to
    // draw
    CGContextRef l_CGContextRef	= (CGContextRef) [l_GraphicsContext graphicsPort];

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
    ScratchPoint *l_firsttPoint;
    
    // For all of the active strokes
    for (ScratchStroke *l_stroke in self.m_activeStrokes.allValues ) {
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
        for (NSUInteger i = 1; i < l_pointCount; i++) {
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

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    if (m_switchIsOn) {
        [self drawFocusRing];
        // not to draw touch point
        // [self drawTouchPoint];
        [self drawStroke];
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

#pragma mark -- Right Mouse Event

- (void)rightMouseDragged:(NSEvent *)theEvent {
    DDLogInfo(@"right mouse dragged");
    NSWindow *window = [self window];
    NSPoint windowOrigin = [window frame].origin;
    
    [window setFrameOrigin:NSMakePoint(windowOrigin.x + [theEvent deltaX], windowOrigin.y - [theEvent deltaY])];
}

# pragma mark -- Touch Evnet

- (void)touchesBeganWithEvent:(NSEvent *)event {
    if (!m_switchIsOn) {
        return ;
    }
    DDLogInfo(@"began touch");
    
    // Get the set of began touches
    NSSet *l_touches =
    [event touchesMatchingPhase:NSTouchPhaseBegan
                         inView:self];
    
    // For each began touch, add the touch
    // to the active touches dictionary
    // using its identity as the key
    for (NSTouch *l_touch in l_touches) {
        [self.m_activeTouches setObject:l_touch forKey:l_touch.identity];
        
        NSColor *l_color = [[NSColor blackColor] colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
        
        // create a new stroke object with the color
        ScratchStroke *l_stroke = [[ScratchStroke alloc] initWithWidth:kStrokeWidth
                                                                   red:[l_color redComponent]
                                                                 green:[l_color greenComponent]
                                                                  blue:[l_color blueComponent]
                                                                 alpha:[l_color alphaComponent]];
        // add stroke to the array of active strokes
        self.m_activeStrokes[l_touch.identity] = l_stroke;
        NSPoint l_touchNP = [l_touch normalizedPosition];
        l_touchNP.x = l_touchNP.x * self.bounds.size.width;
        l_touchNP.y = l_touchNP.y * self.bounds.size.height;
        
        ScratchPoint *l_point = [[ScratchPoint alloc] initWithNSPoint:l_touchNP];
        
        // add point to the stroke
        [l_stroke addPoint:l_point];
    }
    
    // Redisplay the view
    [self setNeedsDisplay:YES];
}

- (void)touchesMovedWithEvent:(NSEvent *)event {
    if (!m_switchIsOn) {
        return ;
    }
    
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
            self.m_activeTouches[l_touch.identity] = l_touch;
            
            // Retrieve the stroke for this touch
            ScratchStroke *l_Line = self.m_activeStrokes[l_touch.identity];
            
            // Create a new point at the location of the
            // finger touch.  This is done by getting the
            // normalized position (between 0 and 10 and
            // calculating the position in the view
            // bounds
            NSPoint l_touchNP = [l_touch normalizedPosition];
            l_touchNP.x = l_touchNP.x * self.bounds.size.width;
            l_touchNP.y = l_touchNP.y * self.bounds.size.height;
            ScratchPoint *l_point = [[ScratchPoint alloc]initWithNSPoint:l_touchNP];
            
            // Add the point to the stroke
            DDLogInfo(@"add point %@", l_point);
            [l_Line addPoint:l_point];
        }
    }
    
    // Redisplay the view
    [self setNeedsDisplay:YES];
}

- (void)touchesEndedWithEvent:(NSEvent *)event {
    if (!m_switchIsOn) {
        return ;
    }
    DDLogInfo(@"end touch");
    
    // Get the set of ended touches
    NSSet *l_touches =
    [event touchesMatchingPhase:NSTouchPhaseEnded
                         inView:self];
    
    ScratchStrokeView *l_strokeView = (ScratchStrokeView *)[self superview];
    // For each ended touch, remove the touch
    // from the active touches dictionary
    // using its identity as the key
    for (NSTouch *l_touch in l_touches) {
        if ([self.m_activeTouches objectForKey:l_touch.identity]) {
            // Get the active stroke for the touch
            ScratchStroke *l_stroke = self.m_activeStrokes[l_touch.identity];
            
            // If the stroke has at least 2 points
            // in it add it to the stroke view
            // object
            if (l_stroke.m_points.count > kMinPoints) {
                [l_strokeView addStroke: l_stroke];
                [l_strokeView setNeedsDisplay:YES];
            }
            
            [self.m_activeTouches removeObjectForKey:l_touch.identity];
            [self.m_activeStrokes removeObjectForKey:l_touch.identity];
        }
    }
    
    // Redisplay the view
    [self setNeedsDisplay:YES];
}

- (void)touchesCancelledWithEvent:(NSEvent *)event {
    if (!m_switchIsOn) {
        return ;
    }
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
        [self.m_activeStrokes removeObjectForKey:l_touch.identity];
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
    
    // set self view size
    NSRect f = self.frame;
    f.size.height = newRect.size.height;
    f.size.width = newRect.size.width;
    self.frame = f;
    
    // set stroke view size
    NSView *strokeView = [self superview];
    strokeView.frame = f;
}

#pragma mark -- Menu Action

- (IBAction)clearAction:(id)sender {
    [(ScratchStrokeView *)[self superview] clear];
}

- (IBAction)saveAsAction:(id)sender {
    NSSavePanel *savePanel = [NSSavePanel savePanel];
    [savePanel setNameFieldLabel: @"Untitle.png"];
    [savePanel setMessage: @"Choose the path to save the *png file"];
    [savePanel setAllowedFileTypes:@[@"png", @"jpeg"]];
    [savePanel setExtensionHidden:NO];
    
    [savePanel beginSheetModalForWindow: self.window
                      completionHandler: ^(NSInteger result) {
        if (NSFileHandlingPanelOKButton == result) {
            NSString *path = [[savePanel URL] path];
            DDLogInfo(@"save as path = %@", path);
            // Get the data into a bitmap.
            NSView *strokeView = [self superview];
            [strokeView lockFocus];
            NSBitmapImageRep *rep = [[NSBitmapImageRep alloc] initWithFocusedViewRect:[strokeView bounds]];
            [strokeView unlockFocus];
            NSData *data = [rep TIFFRepresentation];
            
            [data writeToFile:path atomically:YES];
        }
    }];
}

- (IBAction)helpAction:(id)sender {
    NSAlert *alert = [NSAlert alertWithMessageText:@"Help Message"
                                         defaultButton:@"Got it"
                                       alternateButton:nil
                                           otherButton:nil
                             informativeTextWithFormat:@"This is a simple panel drawing app for macbook, you can use your tracepad to do some scratches work by handy.\n\nUsage:\n1. Double click to activate editor mode, or to detach editor mode.\n\n2. Menu Editor->Clear(Command+R) to clear all scratch.\n\n3. Right-click to drag window directly.\n\n4. Menu File->Save as(Shift+Command+S) to save your scratch to png file.\n\n5. Use zoom in/out gesture to resize window, but still a little buggy.\n\n Power By Hanks. Thank you for your using."];
        
    NSUInteger action = [alert runModal];

    if(action == NSAlertDefaultReturn) {
        DDLogInfo(@"ok button clicked!");
    }
}

@end
