#import "SessionManager.h"
#import "Account.h"

@implementation SessionManager
-(instancetype)initWithAccount:(Account*)account{
    self->account = account;
    
    return [super init];
}

-(void)start{
    queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        [self run];
    });
}

-(void)stop{
    running = false;
}

-(void)run{
    if(running) return;
    
    running = true;
    
    while(running){
        [account resetTimeout];
        
        sleep(20 * 60 * 1000);
    }
}
@end
