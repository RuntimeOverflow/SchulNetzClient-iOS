#import "SessionManager.h"
#import "Account.h"

@implementation SessionManager
-(instancetype)initWithAccount:(Account*)account{
    self->account = account;
    
    return [super init];
}

-(void)start{
    dispatch_async(dispatch_get_main_queue(), ^{
        self->timer = [NSTimer scheduledTimerWithTimeInterval:1 * 60 repeats:true block:^(NSTimer * _Nonnull timer){
            [self->account loadPage:@"1" completion:^(NSObject *res) {}];
        }];
    });
}

-(void)stop{
    if(timer){
        [timer invalidate];
        timer = NULL;
    }
}
@end
