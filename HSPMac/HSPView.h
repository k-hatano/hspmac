//
//  HSPView.h
//  HSPMac
//
//  Created by kenta on 2013/04/29.
//  Copyright (c) 2013年 kenta. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "HSPDocument.h"

@interface HSPView : NSView{
    IBOutlet HSPDocument* document;
    
    BOOL prepared;
}

@end
