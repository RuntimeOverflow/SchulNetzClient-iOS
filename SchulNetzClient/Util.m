#import "Util.h"
#import "Account.h"
#import <UserNotifications/UserNotifications.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import "sys/types.h"
#import <netinet/in.h>

@interface Util()
@end

@implementation Util
static UIColor* tint;

+(UIViewController*) setViewControllerFromName: (NSString*) name{
    return [self setViewControllerFromName:name animated:true];
}

+(UIViewController*) setViewControllerFromName: (NSString*) name animated: (BOOL) animated{
    UIViewController* vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:name];
    
    [[self getMainController] pushViewController:vc animated:animated];
    
    return vc;
}

+(MainViewController*) getMainController{
    return [MainViewController get];
}

+(UIColor*) getTintColor{
    if(!tint) tint = UIColor.lightGrayColor;
    
    return tint;
}

+(UIColor*) getDisabledTintColor{
    if(!tint) tint = UIColor.lightGrayColor;
    
    CGFloat red = 0;
    CGFloat green = 0;
    CGFloat blue = 0;
    [tint getRed:&red green:&green blue:&blue alpha:NULL];
    
    return [[UIColor alloc] initWithRed:red green:green blue:blue alpha:0.5];
}

+(void) setTintColor: (UIColor*) tintColor{
    tint = tintColor;
}

+(BOOL)checkConnection{
    struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;
    
    SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr*)&zeroAddress);
    SCNetworkReachabilityFlags flags;
    
    BOOL ok = SCNetworkReachabilityGetFlags(reachability, &flags);
    
    if(!ok) return false;
    else return ((BOOL)(flags & kSCNetworkReachabilityFlagsReachable) && !(BOOL)(flags & kSCNetworkFlagsConnectionRequired));
}

+(BOOL) notifcationsAllowed{
    __block BOOL allowed = false;
    __block BOOL loaded = false;
    
    UNUserNotificationCenter* center = [UNUserNotificationCenter currentNotificationCenter];
    [center getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings* settings){
        allowed = settings.alertSetting == UNNotificationSettingEnabled;
        loaded = true;
    }];
    
    while(!loaded);
    return allowed;
}

+(BOOL) soundsAllowed{
    __block BOOL allowed = false;
    __block BOOL loaded = false;
    
    UNUserNotificationCenter* center = [UNUserNotificationCenter currentNotificationCenter];
    [center getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings* settings){
        allowed = settings.soundSetting == UNNotificationSettingEnabled;
        loaded = true;
    }];
    
    while(!loaded);
    return allowed;
}

+(BOOL) badgesAllowed{
    __block BOOL allowed = false;
    __block BOOL loaded = false;
    
    UNUserNotificationCenter* center = [UNUserNotificationCenter currentNotificationCenter];
    [center getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings* settings){
        allowed = settings.badgeSetting == UNNotificationSettingEnabled;
        loaded = true;
    }];
    
    while(!loaded);
    return allowed;
}

+(UICKeyChainStore*)getKeyChain{
    UICKeyChainStore* keyChain = [UICKeyChainStore keyChainStore];
    keyChain.accessibility = UICKeyChainStoreAccessibilityAfterFirstUnlock;
    keyChain.synchronizable = true;
    
    return keyChain;
}

+(UIColor*)darkenColor:(UIColor*)color{
    CGFloat h, s, b, a;
    if ([color getHue:&h saturation:&s brightness:&b alpha:&a]) return [UIColor colorWithHue:h saturation:s brightness:b * 0.8 alpha:a];
    else return NULL;
}

+(NSDate*)trimDate:(NSDate*)date{
    NSDateComponents* comps = [[NSCalendar currentCalendar] components:NSCalendarUnitYear | NSCalendarUnitDay fromDate:date];
    return [[NSCalendar currentCalendar] dateFromComponents:comps];
}
@end
