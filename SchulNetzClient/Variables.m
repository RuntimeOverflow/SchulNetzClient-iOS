#import "Variables.h"

@implementation Variables
+(Variables*)get{
    static Variables* instance;
    static dispatch_once_t token;
    
    dispatch_once(&token, ^{
        instance = [[Variables alloc] init];
    });
    
    return instance;
}
@end
