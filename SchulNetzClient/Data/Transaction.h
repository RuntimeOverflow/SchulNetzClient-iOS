#import <Foundation/Foundation.h>

@interface Transaction : NSObject <NSSecureCoding>
@property NSDate* date;
@property NSString* reason;
@property double amount;
@end
