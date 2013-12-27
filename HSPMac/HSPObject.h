//
//  HSPObject.h
//  HSPMac
//
//  Created by kenta on 2013/04/29.
//  Copyright (c) 2013年 kenta. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HSPDocument.h"
#import "openhsp.h"
#import "HSPCodeViewerUtils.h"
#import "NSArray+HSPSentence.h"
#import "NSDictionary+HSPValue.h"

@class HSPDocument;

#define BUFMAX 12

@interface HSPObject : NSObject{
    BOOL docPrepared,viewPrepared,omit_flag;
    int code_length,data_length,label_length,orig;
    int code_position;
    int waitTick;
    
    NSDocument* document;
    
    NSImage* buffers[BUFMAX];
    NSView* view;
    NSMutableArray* sentence;
    NSMutableArray* stack;
    NSTimer* timer;
    NSMutableArray* subviews;
    NSMutableDictionary* variables;
    NSMutableArray* buttons;
    NSMutableString* codeViewerText;
    
    NSPoint point;
    NSColor* color;
    
    HSPHED hed;
    unsigned char* code;
    unsigned char* data;
    unsigned long* label;
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
- (void)buildCodeViewText;
- (void)pushTextToCodeView:(NSTextView*)codeViewerView;

- (int)exceptionDialogWithMessage:(NSString*)str information:(NSString*)inf;


@end
