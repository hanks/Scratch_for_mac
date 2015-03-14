//
//  ScratchStrokeView.h
//  Scratch
//
//  Created by hanks on 3/14/15.
//  Copyright (c) 2015 com.hanks. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ScratchStroke.h"

@interface ScratchStrokeView : NSView

@property (strong) NSMutableArray *m_Strokes;

- (void) addStroke: (ScratchStroke *)a_stroke;
- (void) clear;

@end
