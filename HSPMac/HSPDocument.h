//
//  HSPDocument.h
//  HSPMac
//
//  Created by kenta on 2013/04/29.
//  Copyright (c) 2013年 kenta. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "HSPObject.h"

@class HSPObject;

@interface HSPDocument : NSDocument{
    IBOutlet id view;
    IBOutlet NSPanel* codeViewerPanel;
    IBOutlet NSTextView* codeViewerView;
    IBOutlet NSTextField* codePositionField;
    
    HSPObject* object;
}

- (IBAction)showCodeViewerPanel:(id)sender;

- (id)view;
- (HSPObject*)object;

- (void)showCodePosition:(int)cp;

@end
