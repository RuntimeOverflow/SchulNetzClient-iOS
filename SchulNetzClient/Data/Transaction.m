#import "Transaction.h"

@implementation Transaction
@synthesize date;
@synthesize reason;
@synthesize amount;

-(void)encodeWithCoder:(NSCoder*)coder{
    [coder encodeObject:date forKey:@"date"];
    [coder encodeObject:reason forKey:@"reason"];
    [coder encodeDouble:amount forKey:@"amount"];
}

-(instancetype)initWithCoder:(NSCoder*)coder{
    date = [coder decodeObjectForKey:@"date"];
    reason = [coder decodeObjectForKey:@"reason"];
    amount = [coder decodeDoubleForKey:@"amount"];
    
    return self;
}


+(BOOL)supportsSecureCoding{
    return true;
}

-(BOOL)isEqual:(id)other{
    if(other == self){
        return YES;
    } else if([self class] != [other class]){
        return NO;
    } else {
        return [reason isEqualToString:((Transaction*)other).reason];
    }
}

-(NSUInteger)hash{
    return [reason hash];
}
@end
