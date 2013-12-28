//
//  NSDictionary+HSPValue.h
//  HSPMac
//
//  Created by kenta on 2013/12/27.
//  Copyright (c) 2013年 kenta. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (HSPValue)

+ (NSDictionary*)getDictionaryValue:(NSString*)value as:(NSString*)kind;
+ (NSDictionary*)getDictionaryValueForVariable:(NSString*)variable inVariables:(NSDictionary*)variables;

- (NSString*)getValue;
- (NSString*)getKind;

- (int)getNumericValueForVariables:(NSDictionary*)variables;
- (NSString*)getStringValueForVariables:(NSDictionary*)variables;
- (NSDictionary*)getDictionaryValueForVariables:(NSDictionary*)variables;

@end
