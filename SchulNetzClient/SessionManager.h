#import <Foundation/Foundation.h>

@class Account;
@interface SessionManager : NSObject{
    Account* account;
    NSTimer* timer;
}

-(instancetype)initWithAccount:(Account*)account;

-(void)start;
-(void)stop;
@end
