//
//  HSPObject.m
//  HSPMac
//
//  Created by kenta on 2013/04/29.
//  Copyright (c) 2013年 kenta. All rights reserved.
//

#import "HSPObject.h"

NSPoint convertViewSize(NSPoint point,NSView* view){
    return NSMakePoint(point.x, [view bounds].size.height-point.y);
}

@implementation HSPObject

unsigned short charToShort(unsigned char* ch,int head){
    unsigned short res=0;
    res+=ch[head+1];
    res*=0x100;
    res+=ch[head+0];
    return res;
}

unsigned long charToLong(unsigned char* ch,int head){
    unsigned long res=0;
    res+=ch[head+3];
    res*=0x100;
    res+=ch[head+2];
    res*=0x100;
    res+=ch[head+1];
    res*=0x100;
    res+=ch[head+0];
    return res;
}

- (id)init{
    self=[super init];
    if(self){
        int i;
        docPrepared=NO;
        viewPrepared=NO;
        code=NULL;
        data=NULL;
        label=NULL;
        code_position=0;
        timer=[NSTimer scheduledTimerWithTimeInterval:0.001 target:self selector:@selector(idle:) userInfo:nil repeats:YES];
        sentence=[[NSMutableArray alloc] init];
        stack=[[NSMutableArray alloc] init];
        subviews=[[NSMutableArray alloc] init];
        variables=[[NSMutableDictionary alloc] init];
        buttons=[[NSMutableArray alloc] init];
        point=NSMakePoint(0, 0);
        codeViewerText=[[NSMutableString alloc] init];
        for(i=0;i<BUFMAX;i++){
            buffers[i]=nil;
        }
        waitTick=0;
    }
    return self;
}

- (void)dealloc{
    int i;
    if(code!=NULL) free(code);
    if(data!=NULL) free(data);
    if(label!=NULL) free(label);
    if(timer!=NULL) [timer invalidate];
//    [sentence release];
//    [stack release];
//    [variables release];
//    [buttons release];
    for(id subview in subviews){
        [subview removeFromSuperview];
    }
//    [subviews release];
//    for(i=0;i<BUFMAX;i++){
//        [buffers[i] release];
//    }
//    [super dealloc];
}

- (void)stopTimer{
    [timer invalidate];
    timer=NULL;
}

- (void)idle:(NSTimer*)timer{
    HSPCODE current;
    static int orig=-1;
    int ex0,ex1,ex2,ex3,type;
    int content;
    NSString *str;
    NSDictionary *dic;
    
    NSDictionary* b;
    NSDictionary* a;
    
    @try{
        if(docPrepared&&viewPrepared){
            if(waitTick>TickCount()) return;
            if(code_position>=0&&code_position<code_length){
                    
                current.type=charToShort(code, code_position);
                code_position+=2;
                if((current.type&0x8000)!=0){
                    current.code=(int)charToLong(code, code_position);
                    NSLog(@"%4x : %04x %ld",code_position-2,current.type,current.code);
                    code_position+=4;
                }else{
                    current.code=charToShort(code, code_position);
                    NSLog(@"%4x :%04x %04x",code_position-2,current.type,(int)current.code);
                    code_position+=2;
                }
                
                ex0=(current.type&0x1000)!=0;
                ex1=(current.type&0x2000)!=0;
                ex2=(current.type&0x4000)!=0;
                ex3=(current.type&0x8000)!=0;
                type=(current.type&0x0fff);
                if(orig<0) orig=current.type;
                content=(int)current.code;
                
                if((ex2||ex1)&&[stack count]>0){
                    for(NSDictionary* d in stack){
                        // point.x=[[sent objectAtIndex:1] intValue];
                       [sentence addObject:[d objectForKey:@"value"]];
                    }
                    [stack removeAllObjects];
                }
                
                if((ex1)&&([sentence count]>0)){
                    [self execute:orig sentence:sentence];
                    orig=current.type;
                    [stack removeAllObjects];
                    [sentence removeAllObjects];
                }
                
                switch (type) {
                    case 0: // MARK
                        if(content==0x3f){
                            //dic=[NSDictionary dictionaryWithObjectsAndKeys:@"",@"value",@"STR",@"kind",nil];
                            dic=[NSDictionary dictionaryWithObjectsAndKeys:@"[blank]",@"value",@"STR",@"kind",nil];
                            [stack addObject:dic];
                            break;
                        }else if(content=='('||content==')'){
                            break;
                        }else if([stack count]>=2){
                            b=[stack lastObject];
                            [stack removeLastObject];
                            a=[stack lastObject];
                            [stack removeLastObject];
                            if([[a objectForKey:@"kind"] isEqualTo:@"STR"]||[[b objectForKey:@"kind"] isEqualTo:@"STR"]){
                                switch(content){
                                    case 0:
                                        str=[NSString stringWithFormat:@"%@%@",
                                             [a objectForKey:@"value"],[b objectForKey:@"value"]];
                                        dic=[NSDictionary dictionaryWithObjectsAndKeys:str,@"value",@"STR",@"kind",nil];
                                        [stack addObject:dic];
                                        break;
                                    default:
                                        @throw [NSString stringWithFormat:@"Unrecognizable Operation [%x]",content];
                                }
                            }else{
                                int ad=[[a objectForKey:@"value"] intValue];
                                int bd=[[b objectForKey:@"value"] intValue];
                                switch(content){
                                    case 0:
                                        str=[NSString stringWithFormat:@"%d",ad+bd];
                                        dic=[NSDictionary dictionaryWithObjectsAndKeys:str,@"value",@"NUM",@"kind",nil];
                                        [stack addObject:dic];
                                        break;
                                    case 1:
                                        str=[NSString stringWithFormat:@"%d",ad-bd];
                                        dic=[NSDictionary dictionaryWithObjectsAndKeys:str,@"value",@"NUM",@"kind",nil];
                                        [stack addObject:dic];
                                        break;
                                    case 2:
                                        str=[NSString stringWithFormat:@"%d",ad*bd];
                                        dic=[NSDictionary dictionaryWithObjectsAndKeys:str,@"value",@"NUM",@"kind",nil];
                                        [stack addObject:dic];
                                        break;
                                    case 3:
                                        str=[NSString stringWithFormat:@"%d",ad/bd];
                                        dic=[NSDictionary dictionaryWithObjectsAndKeys:str,@"value",@"NUM",@"kind",nil];
                                        [stack addObject:dic];
                                        break;
                                    case 4:
                                        str=[NSString stringWithFormat:@"%d",ad%bd];
                                        dic=[NSDictionary dictionaryWithObjectsAndKeys:str,@"value",@"NUM",@"kind",nil];
                                        [stack addObject:dic];
                                        break;
                                    case 5:
                                        str=[NSString stringWithFormat:@"%d",ad&bd];
                                        dic=[NSDictionary dictionaryWithObjectsAndKeys:str,@"value",@"NUM",@"kind",nil];
                                        [stack addObject:dic];
                                        break;
                                    case 6:
                                        str=[NSString stringWithFormat:@"%d",ad|bd];
                                        dic=[NSDictionary dictionaryWithObjectsAndKeys:str,@"value",@"NUM",@"kind",nil];
                                        [stack addObject:dic];
                                        break;
                                    case 7:
                                        str=[NSString stringWithFormat:@"%d",ad^bd];
                                        dic=[NSDictionary dictionaryWithObjectsAndKeys:str,@"value",@"NUM",@"kind",nil];
                                        [stack addObject:dic];
                                        break;
                                    case 8:
                                        str=[NSString stringWithFormat:@"%d",ad==bd];
                                        dic=[NSDictionary dictionaryWithObjectsAndKeys:str,@"value",@"NUM",@"kind",nil];
                                        [stack addObject:dic];
                                        break;
                                    case 9:
                                        str=[NSString stringWithFormat:@"%d",ad!=bd];
                                        dic=[NSDictionary dictionaryWithObjectsAndKeys:str,@"value",@"NUM",@"kind",nil];
                                        [stack addObject:dic];
                                        break;
                                    case 10:
                                        str=[NSString stringWithFormat:@"%d",ad<bd];
                                        dic=[NSDictionary dictionaryWithObjectsAndKeys:str,@"value",@"NUM",@"kind",nil];
                                        [stack addObject:dic];
                                        break;
                                    case 11:
                                        str=[NSString stringWithFormat:@"%d",ad>bd];
                                        dic=[NSDictionary dictionaryWithObjectsAndKeys:str,@"value",@"NUM",@"kind",nil];
                                        [stack addObject:dic];
                                        break;
                                    case 12:
                                        str=[NSString stringWithFormat:@"%d",ad<=bd];
                                        dic=[NSDictionary dictionaryWithObjectsAndKeys:str,@"value",@"NUM",@"kind",nil];
                                        [stack addObject:dic];
                                        break;
                                    case 13:
                                        str=[NSString stringWithFormat:@"%d",ad>=bd];
                                        dic=[NSDictionary dictionaryWithObjectsAndKeys:str,@"value",@"NUM",@"kind",nil];
                                        [stack addObject:dic];
                                        break;
                                    case 14:
                                        str=[NSString stringWithFormat:@"%d",ad<<bd];
                                        dic=[NSDictionary dictionaryWithObjectsAndKeys:str,@"value",@"NUM",@"kind",nil];
                                        [stack addObject:dic];
                                        break;
                                    case 15:
                                        str=[NSString stringWithFormat:@"%d",ad>>bd];
                                        dic=[NSDictionary dictionaryWithObjectsAndKeys:str,@"value",@"NUM",@"kind",nil];
                                        [stack addObject:dic];
                                        break;
                                    default:
                                        @throw [NSString stringWithFormat:@"Unrecognizable Operation [%x]",content];
                                }
                            }
//                            [b release];
//                            [a release];
                        }else{
                            if(content==8) break;
                            @throw [NSString stringWithFormat:@"Stack Overflow during Operation [%x]",content];
                        }
                        break;
                    case 1:
                        if(ex1>0){
                            str=[NSString stringWithFormat:@"%d",content];
                            dic=[NSDictionary dictionaryWithObjectsAndKeys:str,@"value",@"NUM",@"kind",nil];
                            [stack addObject:dic];
                        }else{
                            dic=[variables objectForKey:[NSString stringWithFormat:@"%d",content]];
                            [stack addObject:dic];
                        }
                        break;
                    case 2: // STRING
                        str=[NSString stringWithCString:&data[content]];
                        dic=[NSDictionary dictionaryWithObjectsAndKeys:str,@"value",@"STR",@"kind",nil];
                        [stack addObject:dic];
                        break;
                    default:
                        str=[NSString stringWithFormat:@"%d",content];
                        dic=[NSDictionary dictionaryWithObjectsAndKeys:str,@"value",@"NUM",@"kind",nil];
                        [stack addObject:dic];
                        break;
                }
            }
            if(code_position>=code_length){
                
                if([stack count]>0){
                    for(NSDictionary* d in stack){
                        [sentence addObject:[d objectForKey:@"value"]];
                    }
                    [stack removeAllObjects];
                }
                
                if([sentence count]>0){
                    [self execute:orig sentence:sentence];
                    orig=-1;
                    [stack removeAllObjects];
                    [sentence removeAllObjects];
                }
                
                [view setNeedsDisplay:YES];
                
                code_position=-1;
            }
            if(code_position<0&&([stack count]>0||[sentence count]>0)){
                orig=-1;
                [stack removeAllObjects];
                [sentence removeAllObjects];
            }
        }
    }@catch(NSString* s){
        NSLog(@"%@",[sentence description]);
        NSLog(@"%@",[stack description]);
        NSAlert* alert=[[NSAlert alloc] init];
        [alert setMessageText:[NSString stringWithFormat:@"%@ \"%@\" at code #%d",NSLocalizedString(@"msgErrorOccured", nil),s,code_position]];
        [alert setAlertStyle:NSCriticalAlertStyle];
        [alert addButtonWithTitle:NSLocalizedString(@"msgAbort", nil)];
        [alert addButtonWithTitle:NSLocalizedString(@"msgStop", nil)];
        [alert addButtonWithTitle:NSLocalizedString(@"msgContinue", nil)];
        NSInteger res=[alert runModal];
        switch (res) {
            case NSAlertFirstButtonReturn:
                [[view window] close];
                break;
            case NSAlertSecondButtonReturn:
                code_position=-1;
                break;
            case NSAlertThirdButtonReturn:
                break;
        }
    }@catch(NSException* e){
        NSLog(@"%@",[sentence description]);
        NSLog(@"%@",[stack description]);
        NSAlert* alert=[[NSAlert alloc] init];
        [alert setMessageText:[NSString stringWithFormat:@"%@ \"%@\" at code #%d",NSLocalizedString(@"msgErrorOccured", nil),[e name],code_position]];
        [alert setInformativeText:[e reason]];
        [alert setAlertStyle:NSCriticalAlertStyle];
        [alert addButtonWithTitle:NSLocalizedString(@"msgAbort", nil)];
        [alert addButtonWithTitle:NSLocalizedString(@"msgStop", nil)];
        [alert addButtonWithTitle:NSLocalizedString(@"msgContinue", nil)];
        NSInteger res=[alert runModal];
        switch (res) {
            case NSAlertFirstButtonReturn:
                [[view window] close];
                break;
            case NSAlertSecondButtonReturn:
                code_position=-1;
                break;
            case NSAlertThirdButtonReturn:
                break;
        }
    }
}

- (BOOL)execute:(int)orig sentence:(NSArray*)sent{
    long cmd=-1;
    NSMutableAttributedString* atrStr;
    
    int type=(orig&0x0fff);
    NSLog(@"executing %x %@",type,[sent description]);
    
    cmd=[[sent objectAtIndex:0] intValue];
    if(type==0x1){
        NSLog(@"[let]");
        [variables setObject:[NSDictionary dictionaryWithObjectsAndKeys:[sent objectAtIndex:1],@"value",@"NUM",@"kind",nil]
                      forKey:[NSString stringWithFormat:@"%ld",cmd]];
    }else if(type==0x9){ // extcmd
        switch (cmd) {
            case 0x0:{
                NSLog(@"[button]");
                NSButton* button=[[NSButton alloc] initWithFrame:NSMakeRect(point.x, convertViewSize(point, view).y-24, 64, 24)];
                [button setTitle:[sent objectAtIndex:1]];
                [view addSubview:button];
                [subviews addObject:button];
                [buttons addObject:[NSDictionary dictionaryWithObjectsAndKeys:button, @"BUTTON",[sent objectAtIndex:2],@"FLAG",nil]];
                [button setAction:@selector(buttonPushed:)];
                [button setTarget:self];
 //               [button release];
                point.y+=24;
                NSLog(@"%@,%@",[sent objectAtIndex:1],[sent objectAtIndex:2]);
                break;
            }case 0xf:{
                NSLog(@"[mes]");
                [buffers[0] lockFocus];
                [[NSColor blackColor] set];
                atrStr=[[NSMutableAttributedString alloc] initWithString:[sent objectAtIndex:1]];
                [atrStr	addAttribute:NSForegroundColorAttributeName value:[NSColor blackColor]
                               range:NSMakeRange(0, [[sent objectAtIndex:1] length])];
                [atrStr addAttribute:NSFontAttributeName
                               value:[NSFont systemFontOfSize:12.0f]
                               range:NSMakeRange(0, [[sent objectAtIndex:1] length])];
                point.y+=15;
                [atrStr drawAtPoint:convertViewSize(point, view)];
//                [atrStr release];
                [buffers[0] unlockFocus];
                break;
            }case 0x11:{
                NSLog(@"[pos]");
                point.x=[[sent objectAtIndex:1] intValue];
                point.y=[[sent objectAtIndex:2] intValue];
                break;
            }case 0x13:{
                NSLog(@"[cls]");
                [buffers[0] lockFocus];
                [[NSColor whiteColor] set];
                NSRectFill(NSMakeRect(0, 0, [buffers[0] size].width, [buffers[0] size].height));
                [buffers[0] unlockFocus];
                point=NSMakePoint(0, 0);
                [view setNeedsDisplay:YES];
                break;
            }default:{
                NSLog(@"[unrecognizable command %x]",(int)cmd);
                break;
            }
        }
    }else if(type==0xa){ // cmpcmd
        switch(cmd){
            default:
                NSLog(@"[unrecognizable command %x]",(int)cmd);
                break;
        }
    }else if(type==0xf){ // progcmd
        switch(cmd){
            case 0x7:
                NSLog(@"[wait]");
                waitTick=TickCount()+[[sent objectAtIndex:1] intValue]*60/100;
                [view setNeedsDisplay:YES];
                break;
            case 0x11:
                NSLog(@"[stop]");
                code_position=-2;
                [view setNeedsDisplay:YES];
                break;
            default:
                NSLog(@"[unrecognizable command %x]",(int)cmd);
                break;
        }
    }
    
    NSLog(@"---");
    return YES;
}

- (BOOL)loadFromData:(NSData*)content{
    unsigned char* bytes;
    int i;
    
    [codeViewerText appendString:@"ABC"];
    
    if(code!=NULL){
        free(code);
        code=NULL;
    }
    bytes=(unsigned char*)[content bytes];
    
    hed.h1=bytes[0];
    hed.h2=bytes[1];
    hed.h3=bytes[2];
    hed.h4=bytes[3];
    
    if(hed.h1!='H'||hed.h2!='S'||hed.h3!='P'||hed.h4!='3'){
        return NO;
    }
    
    hed.version=(int)charToLong(bytes, 4);
    hed.max_val=(int)charToLong(bytes, 8);
    hed.allsize=(int)charToLong(bytes, 12);
    
    hed.pt_cs=(int)charToLong(bytes, 16);
    hed.max_cs=(int)charToLong(bytes, 20);
    hed.pt_ds=(int)charToLong(bytes, 24);
    hed.max_ds=(int)charToLong(bytes, 28);
    
    hed.pt_ot=(int)charToLong(bytes, 32);
    hed.max_ot=(int)charToLong(bytes, 36);
    hed.pt_dinfo=(int)charToLong(bytes, 40);
    hed.max_dinfo=(int)charToLong(bytes, 44);
    
    hed.pt_linfo=(int)charToLong(bytes, 48);
    hed.max_linfo=(int)charToLong(bytes, 52);
    hed.pt_finfo=(int)charToLong(bytes, 56);
    hed.max_finfo=(int)charToLong(bytes, 60);
    
    hed.pt_minfo=(int)charToLong(bytes, 64);
    hed.max_minfo=(int)charToLong(bytes, 68);
    hed.pt_finfo2=(int)charToLong(bytes, 72);
    hed.max_finfo2=(int)charToLong(bytes, 76);
    
    hed.pt_hpidat=(int)charToLong(bytes, 80);
    hed.max_hpi=(short)charToShort(bytes, 84);
    hed.max_varhpi=(short)charToShort(bytes, 86);
    hed.bootoption=(int)charToLong(bytes, 88);
    hed.runtime=(int)charToLong(bytes, 92);
    
    code=(unsigned char*)malloc(sizeof(char)*hed.max_cs);
    for(i=0;i<hed.max_cs;i++){
        code[i]=bytes[hed.pt_cs+i];
    }
    code_length=hed.max_cs;
    
    if(data!=NULL){
        free(data);
        data=NULL;
    }
    data=(unsigned char*)malloc(sizeof(char)*hed.max_ds);
    for(i=0;i<hed.max_ds;i++){
        data[i]=bytes[hed.pt_ds+i];
    }
    data_length=hed.max_ds;
    
    if(label!=NULL){
        free(label);
        label=NULL;
    }
    label=(long*)malloc(sizeof(long)*hed.max_ot);
    for(i=0;i<hed.max_ot/4;i++){
        label[i]=charToLong(bytes, hed.pt_ot+i*4)+hed.pt_cs;
    }
    label_length=hed.max_ot/4;
    
    return YES;
}

- (void)setDocPrepared:(NSDocument*)value{
    docPrepared=(value!=NULL);
    document=value;
}

- (void)setViewPrepared:(NSView*)value{
    viewPrepared=(value!=NULL);
    view=value;
//    [buffers[0] release];
    buffers[0]=[[NSImage alloc] initWithSize:[view bounds].size];
}

- (NSImage*)drawableBuffer{
    return buffers[0];
}

- (void)buttonPushed:(id)sender{
    NSDictionary* dict;
    NSLog(@"BUTTON PUSHED");
    for(dict in buttons){
        if([dict objectForKey:@"BUTTON"] == sender){
            int jumpto=(int)label[[[dict objectForKey:@"FLAG"] intValue]];
            NSLog(@"jump to %x",jumpto);
            code_position=jumpto;
            return;
        }
    }
}

- (void)pushTextToCodeView:(NSTextView*)codeViewerView{
    [self buildCodeViewText];
    
    [codeViewerView selectAll:self];
    [codeViewerView insertText:codeViewerText];
    [codeViewerView.textStorage setAttributedString:[[NSAttributedString alloc] initWithString:codeViewerText attributes:[NSDictionary dictionaryWithObjectsAndKeys:[NSFont fontWithName:@"Menlo" size:11.0f], NSFontAttributeName, nil]]];
    [codeViewerView scrollPoint:NSMakePoint(0, 0)];
}

- (void)buildCodeViewText{
    HSPCODE current;
    int position=0;
    
    codeViewerText=[[NSMutableString alloc] init];
    while(position<=code_length){
        current.type=charToShort(code, position);
        position+=2;
        if((current.type&0x8000)!=0){
            current.code=(int)charToLong(code, position);
            [codeViewerText appendFormat:@"%4x : %04x %ld\n",position-2,current.type,current.code];
            position+=4;
        }else{
            current.code=charToShort(code, position);
            [codeViewerText appendFormat:@"%4x :%04x %04x\n",position-2,current.type,(int)current.code];
            position+=2;
        }
        
    }
    
}

@end
