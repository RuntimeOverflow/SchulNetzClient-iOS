#import "Host.h"

@implementation Host
+(NSMutableArray*)getHosts{
    NSMutableArray* hosts = [[NSMutableArray alloc] init];
    
    /*[hosts addObject:@"bwzr.nesa-sg.ch"];
    [hosts addObject:@"bwzt.nesa-sg.ch"];
    [hosts addObject:@"bzb.nesa-sg.ch"];
    [hosts addObject:@"bzgs.nesa-sg.ch"];
    [hosts addObject:@"bzr.nesa-sg.ch"];
    [hosts addObject:@"bzsl.nesa-sg.ch"];
    [hosts addObject:@"bzwu.nesa-sg.ch"];
    [hosts addObject:@"bzwuwb.nesa-sg.ch"];
    [hosts addObject:@"gbs.nesa-sg.ch"];
    [hosts addObject:@"isme.nesa-sg.ch"];
    [hosts addObject:@"kbzs.nesa-sg.ch"];
    [hosts addObject:@"ksb.nesa-sg.ch"];
    [hosts addObject:@"ksbg.nesa-sg.ch"];
    [hosts addObject:@"ksh.nesa-sg.ch"];
    [hosts addObject:@"kss.nesa-sg.ch"];*/
    [hosts addObject:@"ksw.nesa-sg.ch"];
    //[hosts addObject:@"kswil.nesa-sg.ch"];
    
    return hosts;
}

+(UIColor*)colorForHost:(NSString*)host{
    UIColor* color = UIColor.labelColor;
    
    if([host isEqualToString:@"bwzr.nesa-sg.ch"]) color = [UIColor colorWithRed:69/255.0 green:170/255.0 blue:103/255.0 alpha:1];
    else if([host isEqualToString:@"bwzt.nesa-sg.ch"]) color = [UIColor colorWithRed:0/255.0 green:131/255.0 blue:52/255.0 alpha:1];
    else if([host isEqualToString:@"bzb.nesa-sg.ch"]) color = [UIColor colorWithRed:0/255.0 green:154/255.0 blue:62/255.0 alpha:1];
    else if([host isEqualToString:@"bzgs.nesa-sg.ch"]) color = [UIColor colorWithRed:59/255.0 green:183/255.0 blue:188/255.0 alpha:1];
    else if([host isEqualToString:@"bzr.nesa-sg.ch"]) color = [UIColor colorWithRed:0/255.0 green:156/255.0 blue:235/255.0 alpha:1];
    else if([host isEqualToString:@"bzsl.nesa-sg.ch"]) color = [UIColor colorWithRed:0/255.0 green:131/255.0 blue:52/255.0 alpha:1];
    else if([host isEqualToString:@"bzwu.nesa-sg.ch"]) color = [UIColor colorWithRed:3/255.0 green:93/255.0 blue:156/255.0 alpha:1];
    else if([host isEqualToString:@"bzwuwb.nesa-sg.ch"]) color = [UIColor colorWithRed:255/255.0 green:38/255.0 blue:0/255.0 alpha:1];
    else if([host isEqualToString:@"gbs.nesa-sg.ch"]) color = [UIColor colorWithRed:199/255.0 green:211/255.0 blue:0/255.0 alpha:1];
    else if([host isEqualToString:@"isme.nesa-sg.ch"]) color = [UIColor colorWithRed:128/255.0 green:203/255.0 blue:61/255.0 alpha:1];
    else if([host isEqualToString:@"kbzs.nesa-sg.ch"]) color = [UIColor colorWithRed:153/255.0 green:1/255.0 blue:51/255.0 alpha:1];
    else if([host isEqualToString:@"ksb.nesa-sg.ch"]) color = [UIColor colorWithRed:224/255.0 green:18/255.0 blue:114/255.0 alpha:1];
    else if([host isEqualToString:@"ksbg.nesa-sg.ch"]) color = [UIColor colorWithRed:0/255.0 green:107/255.0 blue:163/255.0 alpha:1];
    else if([host isEqualToString:@"ksh.nesa-sg.ch"]) color = [UIColor colorWithRed:62/255.0 green:167/255.0 blue:67/255.0 alpha:1];
    else if([host isEqualToString:@"kss.nesa-sg.ch"]) color = [UIColor colorWithRed:204/255.0 green:51/255.0 blue:51/255.0 alpha:1];
    else if([host isEqualToString:@"ksw.nesa-sg.ch"]) color = [UIColor colorWithRed:40/255.0 green:149/255.0 blue:72/255.0 alpha:1];
    else if([host isEqualToString:@"kswil.nesa-sg.ch"]) color = [UIColor colorWithRed:157/255.0 green:193/255.0 blue:11/255.0 alpha:1];
    
    return color;
}
@end
