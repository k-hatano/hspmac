//
//  HSPObject.h
//  HSPMac
//
//  Created by kenta on 2013/04/29.
//  Copyright (c) 2013年 kenta. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "openhsp.h"

#define BUFMAX 12

@interface HSPObject : NSObject{
    BOOL docPrepared,viewPrepared;
    int code_length,data_length,label_length;
    int code_position;
    int waitTick;
    
    NSImage* buffers[BUFMAX];
    NSDocument* document;
    NSView* view;
    NSMutableArray* sentence;
    NSMutableArray* stack;
    NSTimer* timer;
    NSMutableArray* subviews;
    NSMutableDictionary* variables;
    NSMutableArray* buttons;
    
    NSPoint point;
    
    HSPHED hed;
    unsigned char* code;
    char* data;
    long* label;
}

- (id)init;
- (void)dealloc;

- (void)idle:(NSTimer*)timer;
- (void)stopTimer;
- (BOOL)execute:(int)orig sentence:(NSArray*)sent;

- (BOOL)loadFromData:(NSData*)data;

- (NSImage*)drawableBuffer;

- (void)setDocPrepared:(NSDocument*)value;
- (void)setViewPrepared:(NSView*)value;

- (void)buttonPushed:(id)sender;

@end
