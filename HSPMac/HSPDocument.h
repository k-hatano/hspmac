//
//  HSPDocument.h
//  HSPMac
//
//  Created by kenta on 2013/04/29.
//  Copyright (c) 2013年 kenta. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "HSPObject.h"

@interface HSPDocument : NSDocument{
    IBOutlet id view;
    IBOutlet NSPanel* codeViewerPanel;
    IBOutlet NSTextView* codeViewerView;
    
    HSPObject* object;
}

- (IBAction)showCodeViewerPanel:(id)sender;

- (id)view;
- (HSPObject*)object;

@end
