//
//  PanelView.h
//  Scratch
//
//  Created by hanks on 2/12/15.
//  Copyright (c) 2015 com.hanks. All rights reserved.
//

#import <Cocoa/Cocoa.h>

// Define the size of the cursor that
// will be drawn in the view for each
// finger on the trackpad
#define D_FINGER_CURSOR_SIZE 20
// Define the color values that will
// be used for the finger cursor
#define D_FINGER_CURSOR_RED 1.0
#define D_FINGER_CURSOR_GREEN 0.0
#define D_FINGER_CURSOR_BLUE 0.0
#define D_FINGER_CURSOR_ALPHA 0.5

@interface PanelView : NSView

@property (strong) NSMutableDictionary *m_activeTouches;

@end
