//
//  HSPView.m
//  HSPMac
//
//  Created by kenta on 2013/04/29.
//  Copyright (c) 2013年 kenta. All rights reserved.
//

#import "HSPView.h"

@implementation HSPView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        prepared=NO;
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    [[NSColor whiteColor] set];
    NSRectFill([self bounds]);
    
    if(prepared==NO){
        prepared=YES;
        document.object.viewPrepared=self;
    }
    
    NSImage* buffer=[document.object drawableBuffer];
    [buffer drawAtPoint:NSMakePoint(0.0f, 0.0f) fromRect:NSMakeRect(0.0f, 0.0f, [buffer size].width, [buffer size].height) operation:NSCompositeSourceOver fraction:1.0f];
}


@end
