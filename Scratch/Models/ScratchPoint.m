//
//  ScratchPoint.m
//  Scratch
//
//  Created by hanks on 3/14/15.
//  Copyright (c) 2015 com.hanks. All rights reserved.
//

#import "ScratchPoint.h"

@implementation ScratchPoint

- (instancetype)initWithNSPoint:(NSPoint)a_point {
    if (self = [super init]) {
        m_point.x = a_point.x;
        m_point.y = a_point.y;
    }
    
    return self;
}

- (NSPoint)point {
    return m_point;
}

- (CGFloat)x {
    return m_point.x;
}

- (CGFloat)y {
    return m_point.y;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodePoint:m_point forKey:@"m_point"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        m_point = [aDecoder decodePointForKey:@"m_point"];
    }
    return self;
}

@end
