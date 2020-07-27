#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ViewControllers/MainViewController.h"

@interface Util : NSObject
+(UIViewController*) setViewControllerFromName: (NSString*) name;
+(UIViewController*) setViewControllerFromName: (NSString*) name animated: (BOOL)animated;

+(MainViewController*) getMainController;
+(UIColor*) getTintColor;
+(UIColor*) getDisabledTintColor;
+(void) setTintColor: (UIColor*) tintColor;
+(BOOL) checkConnection;
+(NSURLProtectionSpace*) getProtectionSpace;
+(BOOL) notifcationsAllowed;
+(BOOL) soundsAllowed;
+(BOOL) badgesAllowed;
@end
