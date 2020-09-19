#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ViewControllers/MainViewController.h"
#import "Libraries/UICKeyChainStore/UICKeyChainStore.h"

@interface Util : NSObject
+(UIViewController*) setViewControllerFromName: (NSString*) name;
+(UIViewController*) setViewControllerFromName: (NSString*) name animated: (BOOL)animated;

+(MainViewController*) getMainController;
+(UIColor*) getTintColor;
+(UIColor*) getDisabledTintColor;
+(void) setTintColor: (UIColor*) tintColor;
+(BOOL) checkConnection;
+(BOOL) notificationsAllowed;
+(BOOL) soundsAllowed;
+(BOOL) badgesAllowed;
+(UICKeyChainStore*)getKeyChain;
+(UIColor*)darkenColor:(UIColor*)color;
+(NSDate*)trimDate:(NSDate*)date;
@end
