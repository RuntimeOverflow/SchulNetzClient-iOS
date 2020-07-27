#import <Foundation/Foundation.h>

@class Account;
@interface SessionManager : NSObject{
    dispatch_queue_t queue;
    Account* account;
    
    BOOL running;
}

-(instancetype)initWithAccount:(Account*)account;

-(void)start;
-(void)stop;

-(void)run;
@end
