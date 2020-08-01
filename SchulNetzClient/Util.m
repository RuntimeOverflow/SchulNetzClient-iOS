#import "Util.h"
#import "Account.h"
#import <UserNotifications/UserNotifications.h>

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
    if(!tint) tint = UIColor.blackColor;
    
    return tint;
}

+(UIColor*) getDisabledTintColor{
    if(!tint) tint = UIColor.blackColor;
    
    CGFloat red = 0;
    CGFloat green = 0;
    CGFloat blue = 0;
    [tint getRed:&red green:&green blue:&blue alpha:NULL];
    
    return [[UIColor alloc] initWithRed:red green:green blue:blue alpha:0.5];
}

+(void) setTintColor: (UIColor*) tintColor{
    tint = tintColor;
}

+(BOOL) checkConnection{
    __block BOOL errored = false;
    
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    NSURL *url = [NSURL URLWithString:@"https://google.com"];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];

    __block BOOL done = NO;
    NSURLSessionDataTask *dataTask = [defaultSession dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        done = YES;
        
        if(error != NULL) errored = true;
    }];
    [dataTask resume];

    while (!done) {
        NSDate *date = [[NSDate alloc] initWithTimeIntervalSinceNow:0.1];
        [[NSRunLoop currentRunLoop] runUntilDate:date];
    }
    
    return !errored;
}

+(NSURLProtectionSpace*) getProtectionSpace{
    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"https://%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"url"]]];
    
    return [[NSURLProtectionSpace alloc] initWithHost:url.host
    port:[url.port integerValue]
    protocol:url.scheme
    realm:nil
    authenticationMethod:NSURLAuthenticationMethodHTTPDigest];
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
@end
