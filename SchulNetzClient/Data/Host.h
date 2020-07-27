#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Host : NSObject
+(NSMutableArray*)getHosts;
+(UIColor*)colorForHost:(NSString*)host;
@end
