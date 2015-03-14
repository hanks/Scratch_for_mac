//
//  ScratchPoint.h
//  Scratch
//
//  Created by hanks on 3/14/15.
//  Copyright (c) 2015 com.hanks. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ScratchPoint : NSObject <NSCoding> {
    NSPoint m_point;
}

- (instancetype)initWithNSPoint:(NSPoint)a_point;
- (NSPoint)point;
- (CGFloat)x;
- (CGFloat)y;

@end
