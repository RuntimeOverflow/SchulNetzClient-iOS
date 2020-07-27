#import "Teacher.h"

@implementation Teacher
@synthesize subjects;
@synthesize lessons;

@synthesize firstName;
@synthesize lastName;
@synthesize shortName;
@synthesize mail;

-(instancetype)init{
    subjects = [[NSMutableArray alloc] init];
    lessons = [[NSMutableArray alloc] init];
    
    return self;
}

-(void)encodeWithCoder:(NSCoder*)coder{
    [coder encodeObject:firstName forKey:@"firstName"];
    [coder encodeObject:lastName forKey:@"lastName"];
    [coder encodeObject:shortName forKey:@"shortName"];
    [coder encodeObject:mail forKey:@"mail"];
}

-(instancetype)initWithCoder:(NSCoder*)coder{
    subjects = [[NSMutableArray alloc] init];
    lessons = [[NSMutableArray alloc] init];
    
    firstName = [coder decodeObjectForKey:@"firstName"];
    lastName = [coder decodeObjectForKey:@"lastName"];
    shortName = [coder decodeObjectForKey:@"shortName"];
    mail = [coder decodeObjectForKey:@"mail"];
    
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
        return [shortName isEqualToString:((Teacher*)other).shortName];
    }
}

-(NSUInteger)hash{
    return [shortName hash];
}
@end
