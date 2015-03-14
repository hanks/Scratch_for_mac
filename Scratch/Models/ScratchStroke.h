//
//  ScratchStroke.h
//  Scratch
//
//  Created by hanks on 3/14/15.
//  Copyright (c) 2015 com.hanks. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ScratchPoint.h"

@interface ScratchStroke : NSObject <NSCoding> {
    float m_red;
    float m_green;
    float m_blue;
    float m_alpha;
    float m_width;
}

@property (strong, nonatomic) NSMutableArray *m_points;

- (instancetype)initWithWidth:(float)aWidth
                          red:(float)aRed
                        green:(float)aGreen
                         blue:(float)aBlue
                        alpha:(float)aAlpha;

- (void)addPoint:(ScratchPoint *)aPoint;
- (NSMutableArray *)points;
- (float)red;
- (float)green;
- (float)blue;
- (float)alpha;
- (float)width;

@end
