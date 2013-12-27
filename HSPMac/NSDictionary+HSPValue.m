//
//  NSDictionary+HSPValue.m
//  HSPMac
//
//  Created by kenta on 2013/12/27.
//  Copyright (c) 2013年 kenta. All rights reserved.
//

#import "NSDictionary+HSPValue.h"

@implementation NSDictionary (HSPValue)

+ (NSDictionary*)getDictionaryValue:(NSString*)value as:(NSString*)kind{
    return [NSDictionary dictionaryWithObjectsAndKeys:value,@"value",kind,@"kind", nil];
}

+ (NSDictionary*)getDictionaryValueForVariable:(NSString*)variable inVariables:(NSDictionary*)variables{
    return [variables objectForKey:variable];
}

- (NSString*)getValue{
    return [self objectForKey:@"value"];
}

- (NSString*)getKind{
    return [self objectForKey:@"kind"];
}

- (int)getNumericValueForVariables:(NSDictionary*)variables{
    return [[[self getDictionaryValueForVariables:variables] objectForKey:@"value"] intValue];
}

- (NSString*)getStringValueForVariables:(NSDictionary*)variables{
    return [[self getDictionaryValueForVariables:variables] objectForKey:@"value"];
}

- (NSDictionary*)getDictionaryValueForVariables:(NSDictionary*)variables{
    NSString* kind=[self objectForKey:@"kind"];
    NSDictionary* value;
    if([kind isEqualToString:@"VAR"]){
        value=[variables objectForKey:[self objectForKey:@"value"]];
    }else{
        value=self;
    }
    return value;
}

@end
