#import <Foundation/Foundation.h>
#import "Account.h"
#import "Data/User.h"

@interface Variables : NSObject
@property Account* account;
@property User* user;

+(Variables*)get;
@end
