//
//  NSArray+HSPSentence.m
//  HSPMac
//
//  Created by kenta on 2013/12/27.
//  Copyright (c) 2013年 kenta. All rights reserved.
//

#import "NSArray+HSPSentence.h"

@implementation NSArray (HSPSentence)

- (NSString*)toString{
    NSMutableString* res=[NSMutableString string];
    
    for(NSDictionary* item in self){
        [res appendString:[item objectForKey:@"value"]];
        [res appendString:@" "];
    }
    
    return res;
}

@end
