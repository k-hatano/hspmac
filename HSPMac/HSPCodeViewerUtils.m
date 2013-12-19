//
//  HSPCodeViewerUtils.m
//  HSPMac
//
//  Created by kenta on 2013/12/18.
//  Copyright (c) 2013年 kenta. All rights reserved.
//

#import "HSPCodeViewerUtils.h"

NSString*types[]={@"MARK",@"VAR",@"STR",@"FLOAT",@"INT",@"STRUCT",@"XLABEL",@"LABEL",@"CMD",@"XCMD",@"XVAR",@"CMPCMD",@"MODCMD",@"FUNC",@"SYSVAR",@"PRGCMD",@"DLLFNC",@"DLLCTR",@"USRDEF"};

NSString*xcmds[]={@"button",@"chgdisp",@"exec",@"dialog",@"",@"",@"",@"palfade",@"mmload",@"mmplay",@"mmstop",@"mci",@"pset",@"pget",@"syscolor",@"mes",@"title",@"pos",@"circle",@"cls",@"font",@"sysfont",@"objsize",@"picload",@"color",@"palcolor",@"palette",@"redraw",@"width",@"gsel",@"gcopy",@"gzoom",@"gmode",@"bmpsave",@"text",@"hsvcolor",@"getkey",@"listbox",@"chkbox",@"combox",@"inpot",@"mesbox",@"buffer",@"screen",@"bgscr",@"mouse",@"objsel",@"groll",@"line",@"clrobj",@"boxf"};

NSString*progcmds[]={@"goto",@"gosub",@"return",@"break",@"repeat",@"loop",@"continue",@"wait",@"await",@"dim",@"sdim",@"skiperr",@"eachchk",@"dimtype",@"dup",@"dupptr",@"end",@"stop",@"newmod",@"setmod",@"delmod",@"alloc",@"mref",@"run", @"exgoto",@"on",@"mcall",@"assert",@"logmes",@"newlab",@"resume",@"yield"};

NSString*marks[]={@"+",@"-",@"*",@"/",@"%",@"&",@"|",@"^",@"=",@"!",@">",@"<",@">=",@"<=",@">>",@"<<"};

NSString*cmpcmds[]={@"if",@"else"};

NSString* disasmString(unsigned short type,unsigned long code,unsigned char* data,unsigned long* label){
    switch(type){
        case TYPE_VAR:
            return [NSString stringWithFormat:@"$%ld",code];
            break;
        case TYPE_LABEL:
            return [NSString stringWithFormat:@"#%ld(=%x)",code,label[(unsigned short)code]];
            break;
        case TYPE_INT:
            return [NSString stringWithFormat:@"%ld",code];
            break;
        case TYPE_STR:{
            NSString* str=[NSString stringWithCString:&data[code]];
            if([str length]>6){
                return [NSString stringWithFormat:@"'%@...'",[str substringToIndex:6]];
            }else{
                return [NSString stringWithFormat:@"'%@'",str];
            }
            break;
        }
        case TYPE_XCMD:
            return [NSString stringWithFormat:@"%@",xcmds[code]];
            break;
        case TYPE_PRGCMD:
            return [NSString stringWithFormat:@"%@",progcmds[(unsigned short)code]];
            break;
        case TYPE_MARK:
            if(code==0x3f) return [NSString stringWithFormat:@"dum"];
            else if(code=='(') return [NSString stringWithFormat:@"("];
            else if(code==')') return [NSString stringWithFormat:@")"];
            else return [NSString stringWithFormat:@"%@",marks[(unsigned short)code]];
            break;
        case TYPE_CMPCMD:
            return [NSString stringWithFormat:@"%@",cmpcmds[code/0x10000]];
            break;
        default:
            return @"";
            break;
    }
}

NSString* disasm(HSPCODE current,unsigned char* data,unsigned long* label){
    NSString* flg=@" ";
    NSMutableString* res;
    unsigned int ex0,ex1,ex2,ex3,type;
    ex0=(current.type&0x1000)!=0;
    ex1=(current.type&0x2000)!=0;
    ex2=(current.type&0x4000)!=0;
    ex3=(current.type&0x8000)!=0;
    type=(current.type&0x0fff);
    if(ex1) flg=@"*";
    if(ex2) flg=@",";
    res=[NSMutableString stringWithFormat:@"%@ %@\t",flg,types[type]];
    [res appendString:disasmString(type, current.code, data,label)];
    
    return res;
}

@implementation HSPCodeViewerUtils

+ (NSString*)disasmStringWithType:(int)type code:(int)code data:(unsigned char*)data label:(unsigned long*)label{
    return disasmString(type,code,data,label);
}

+ (NSString*)sentenceToString:(NSArray*)sentence{
    NSMutableString* res=[[NSMutableString alloc] init];
    for(NSString* item in sentence){
        [res appendString:item];
        [res appendString:@" "];
    }
    return res;
}

+ (NSString*)stackToString:(NSArray*)stack{
    NSMutableString* res=[[NSMutableString alloc] init];
    for(NSDictionary* item in stack){
        [res appendString:[item valueForKey:@"value"]];
        [res appendString:@" "];
    }
    return res;
}

@end
