#import "Student.h"

@implementation Student
@synthesize firstName;
@synthesize lastName;
@synthesize gender;
@synthesize degree;
@synthesize bilingual;
@synthesize className;
@synthesize address;
@synthesize zipCode;
@synthesize city;
@synthesize phone;
@synthesize dateOfBirth;
@synthesize additionalClasses;
@synthesize status;
@synthesize placeOfWork;
@synthesize me;

-(void)encodeWithCoder:(NSCoder*)coder{
    [coder encodeObject:firstName forKey:@"firstName"];
    [coder encodeObject:lastName forKey:@"lastName"];
    [coder encodeBool:gender forKey:@"gender"];
    [coder encodeObject:degree forKey:@"degree"];
    [coder encodeBool:bilingual forKey:@"bilingual"];
    [coder encodeObject:className forKey:@"className"];
    [coder encodeObject:address forKey:@"address"];
    [coder encodeInt:zipCode forKey:@"zipCode"];
    [coder encodeObject:city forKey:@"city"];
    [coder encodeObject:phone forKey:@"phone"];
    [coder encodeObject:dateOfBirth forKey:@"dateOfBirth"];
    [coder encodeObject:additionalClasses forKey:@"additionalClasses"];
    [coder encodeObject:status forKey:@"status"];
    [coder encodeObject:placeOfWork forKey:@"placeOfWork"];
    [coder encodeBool:me forKey:@"me"];
}

-(instancetype)initWithCoder:(NSCoder*)coder{
    firstName = [coder decodeObjectForKey:@"firstName"];
    lastName = [coder decodeObjectForKey:@"lastName"];
    gender = [coder decodeBoolForKey:@"gender"];
    degree = [coder decodeObjectForKey:@"degree"];
    bilingual = [coder decodeBoolForKey:@"bilingual"];
    className = [coder decodeObjectForKey:@"className"];
    address = [coder decodeObjectForKey:@"address"];
    zipCode = [coder decodeIntForKey:@"zipCode"];
    city = [coder decodeObjectForKey:@"city"];
    phone = [coder decodeObjectForKey:@"phone"];
    dateOfBirth = [coder decodeObjectForKey:@"dateOfBirth"];
    additionalClasses = [coder decodeObjectForKey:@"additionalClasses"];
    status = [coder decodeObjectForKey:@"status"];
    placeOfWork = [coder decodeObjectForKey:@"placeOfWork"];
    me = [coder decodeBoolForKey:@"me"];
    
    return self;
}

+(BOOL)supportsSecureCoding{
    return true;
}
@end
