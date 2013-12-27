//
//  HSPCodeViewerUtils.h
//  HSPMac
//
//  Created by kenta on 2013/12/18.
//  Copyright (c) 2013年 kenta. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "openhsp.h"
#import "NSArray+HSPSentence.h"

#define TYPE_MARK       0
#define TYPE_VAR        1
#define TYPE_STR        2
#define TYPE_FLOAT      3
#define TYPE_INT        4
#define TYPE_STRUCT     5
#define TYPE_XLABEL     6
#define TYPE_LABEL      7
#define TYPE_CMD        8
#define TYPE_XCMD       9
#define TYPE_XVAR       10
#define TYPE_CMPCMD     11
#define TYPE_MODCMD     12
#define TYPE_FNC        13
#define TYPE_SYSVAR     14
#define TYPE_PRGCMD     15
#define TYPE_DLLFNC     16
#define TYPE_DLLCTR     17
#define TYPE_USRDEF     18

NSString* disasm(HSPCODE current,unsigned char* data,unsigned long* label);

@interface HSPCodeViewerUtils : NSObject

+ (NSString*)disasmStringWithType:(int)type code:(int)code data:(unsigned char*)data label:(unsigned long*)label;

@end
