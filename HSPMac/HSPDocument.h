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
    HSPObject* object;
}

- (id)view;
- (HSPObject*)object;

@end
