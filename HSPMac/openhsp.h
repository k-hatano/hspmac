//
//  openhsp.c
//  HSPMac
//
//  Created by kenta on 2013/04/29.
//  Copyright (c) 2013年 kenta. All rights reserved.
//

typedef struct HSPHED{
	char	h1;					// magic code1
	char	h2;					// magic code2
	char	h3;					// magic code3
	char	h4;					// magic code4
	int		version;			// version number info
	int		max_val;			// max count of VAL Object
	int		allsize;			// total file size
    
	int		pt_cs;				// ptr to Code Segment
	int		max_cs;				// size of CS
	int		pt_ds;				// ptr to Data Segment
	int		max_ds;				// size of DS
    
	int		pt_ot;				// ptr to Object Temp
	int		max_ot;				// size of OT
	int		pt_dinfo;			// ptr to Debug Info
	int		max_dinfo;			// size of DI
    
	int		pt_linfo;			// ptr to LibInfo(2.3)
	int		max_linfo;			// size of LibInfo(2.3)
	int		pt_finfo;			// ptr to FuncInfo(2.3)
	int		max_finfo;			// size of FuncInfo(2.3)
    
	int		pt_minfo;			// ptr to ModInfo(2.5)
	int		max_minfo;			// size of ModInfo(2.5)
	int		pt_finfo2;			// ptr to FuncInfo2(2.5)
	int		max_finfo2;			// size of FuncInfo2(2.5)
    
	int		pt_hpidat;			// ptr to HPIDAT(3.0)
	short	max_hpi;			// size of HPIDAT(3.0)
	short	max_varhpi;			// Num of Vartype Plugins(3.0)
	int		bootoption;			// bootup options
	int		runtime;			// ptr to runtime name
} HSPHED;

typedef struct HSPCODE{
    short type;
    long code;
} HSPCODE;

