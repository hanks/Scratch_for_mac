//
//  ScratchStroke.m
//  Scratch
//
//  Created by hanks on 3/14/15.
//  Copyright (c) 2015 com.hanks. All rights reserved.
//

#import "ScratchStroke.h"

// How close is too close for
// points be be considered unique
#define D_TOO_CLOSE 5

// Keys to access the archived values
#define kBTS_RED_COLOR @"m_red"
#define kBTS_GREEN_COLOR @"m_green"
#define kBTS_BLUE_COLOR @"m_blue"
#define kBTS_ALPHA_COLOR @"m_alpha"
#define kBTS_WIDTH_COLOR @"m_width"
#define kBTS_POINTS_COLOR @"m_points"

@implementation ScratchStroke

- (instancetype)initWithWidth:(float)aWidth
                          red:(float)aRed
                        green:(float)aGreen
                         blue:(float)aBlue
                        alpha:(float)aAlpha {
    if (self = [super init]) {
        m_red = aRed;
        m_green = aGreen;
        m_blue = aBlue;
        m_alpha = aAlpha;
        m_width = aWidth;
        
        self.m_points = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)addPoint:(ScratchPoint *)aPoint {
    // Get the last point added to the stroke
    ScratchPoint *l_lastPoint = [self.m_points lastObject];
    
    // Calculate the distance between the
    // last point and this point
    float l_distance =
    sqrtf(powf(l_lastPoint.x - aPoint.x, 2) +
          powf(l_lastPoint.y - aPoint.y, 2));
    
    // Ignore the point if it is too close
    if (l_distance < D_TOO_CLOSE) {
        DDLogInfo(@"too close! skip to add point");
        return;
    }
    DDLogInfo(@"add point: %@", aPoint);
    // Add the new point to the stroke
    [self.m_points addObject:aPoint];
}

- (NSMutableArray *)points {
    return self.m_points;
}

- (float)red {
    return m_red;
}

- (float)green {
    return m_green;
}

- (float)blue {
    return m_blue;
}

- (float)alpha {
    return m_alpha;
}

- (float)width {
    return m_width;
}

- (void) encodeWithCoder: (NSCoder *)coder {
    // The archiver provides a convenience
    // method for encodeFloat:forKey:, so just use it
    // for RGBA and Widh
    [coder encodeFloat:m_red forKey:kBTS_RED_COLOR];
    [coder encodeFloat:m_green forKey:kBTS_GREEN_COLOR];
    [coder encodeFloat:m_blue forKey:kBTS_BLUE_COLOR];
    [coder encodeFloat:m_alpha forKey:kBTS_ALPHA_COLOR];
    [coder encodeFloat:m_width forKey:kBTS_WIDTH_COLOR];
    
    // Encode the NSArray object
    [coder encodeObject:self.m_points forKey:kBTS_POINTS_COLOR];
    
}

- (instancetype) initWithCoder: (NSCoder *)code {
    if (self = [super init]) {
        // The unarchiver provides a convenience
        // method for decodeFloatForKey:, so just use it
        // for RGBA and Widh
        m_red = [code decodeFloatForKey:kBTS_RED_COLOR];
        m_green = [code decodeFloatForKey:kBTS_GREEN_COLOR];
        m_blue = [code decodeFloatForKey:kBTS_BLUE_COLOR];
        m_alpha = [code decodeFloatForKey:kBTS_ALPHA_COLOR];
        m_width = [code decodeFloatForKey:kBTS_WIDTH_COLOR];
        
        // Decode the NSArray object
        self.m_points = [code decodeObjectForKey:kBTS_POINTS_COLOR];
    }
    
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p, points count: %zd>", NSStringFromClass([self class]), self, [self.m_points count]];
}

@end
