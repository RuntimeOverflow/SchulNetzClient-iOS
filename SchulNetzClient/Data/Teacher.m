#import "Teacher.h"

@implementation Teacher
@synthesize firstName;
@synthesize lastName;
@synthesize initials;
@synthesize mail;
@synthesize subjects;

-(instancetype)init{
    subjects = [[NSMutableArray alloc] init];
    
    return self;
}

-(void)encodeWithCoder:(NSCoder*)coder{
    [coder encodeObject:firstName forKey:@"firstName"];
    [coder encodeObject:lastName forKey:@"lastName"];
    [coder encodeObject:initials forKey:@"initials"];
    [coder encodeObject:mail forKey:@"mail"];
}

-(instancetype)initWithCoder:(NSCoder*)coder{
    subjects = [[NSMutableArray alloc] init];
    
    firstName = [coder decodeObjectForKey:@"firstName"];
    lastName = [coder decodeObjectForKey:@"lastName"];
    initials = [coder decodeObjectForKey:@"initials"];
    mail = [coder decodeObjectForKey:@"mail"];
    
    return self;
}

+(BOOL)supportsSecureCoding{
    return true;
}
@end
