//
//  HSPDocument.m
//  HSPMac
//
//  Created by kenta on 2013/04/29.
//  Copyright (c) 2013年 kenta. All rights reserved.
//

#import "HSPDocument.h"

@implementation HSPDocument

- (id)init
{
    self = [super init];
    if (self) {
        object=[[HSPObject alloc] init];
    }
    return self;
}

- (NSString *)windowNibName
{
    // Override returning the nib file name of the document
    // If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this method and override -makeWindowControllers instead.
    return @"HSPDocument";
}

- (void)windowControllerDidLoadNib:(NSWindowController *)aController
{
    [super windowControllerDidLoadNib:aController];
    // Add any code here that needs to be executed once the windowController has loaded the document's window.
}

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError
{
    // Insert code here to write your document to data of the specified type. If outError != NULL, ensure that you create and set an appropriate error when returning nil.
    // You can also choose to override -fileWrapperOfType:error:, -writeToURL:ofType:error:, or -writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.
    NSException *exception = [NSException exceptionWithName:@"UnimplementedMethod" reason:[NSString stringWithFormat:@"%@ is unimplemented", NSStringFromSelector(_cmd)] userInfo:nil];
    @throw exception;
    return nil;
}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError
{
    BOOL res=[object loadFromData:data];
    if(res){
        object.docPrepared=self;
    }
    return res;
}

- (void)dealloc{
    [object stopTimer];
//    [super dealloc];
}

- (id)view{
    return view;
}

- (HSPObject*)object{
    return object;
}

- (IBAction)showCodeViewerPanel:(id)sender{
    [object pushTextToCodeView:codeViewerView];
    [codeViewerPanel orderFront:self];
}

- (void)showCodePosition:(int)cp{
    [codePositionField setAttributedStringValue:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"Code Position : %x",cp] attributes:nil]];
}

@end
