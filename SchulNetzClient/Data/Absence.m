#import "Absence.h"

@implementation Absence
@synthesize subjects;

@synthesize startDate;
@synthesize endDate;
@synthesize reason;
@synthesize additionalInformation;
@synthesize lessonCount;
@synthesize excused;
@synthesize subjectIdentifiers;

-(void)encodeWithCoder:(NSCoder*)coder{
    [coder encodeObject:startDate forKey:@"startDate"];
    [coder encodeObject:endDate forKey:@"endDate"];
    [coder encodeObject:reason forKey:@"reason"];
    [coder encodeObject:additionalInformation forKey:@"additionalInformation"];
    [coder encodeInt:lessonCount forKey:@"lessonCount"];
    [coder encodeBool:excused forKey:@"excused"];
    [coder encodeObject:subjectIdentifiers forKey:@"subjectIdentifiers"];
}

-(instancetype)initWithCoder:(NSCoder*)coder{
    startDate = [coder decodeObjectForKey:@"startDate"];
    endDate = [coder decodeObjectForKey:@"endDate"];
    reason = [coder decodeObjectForKey:@"reason"];
    additionalInformation = [coder decodeObjectForKey:@"additionalInformation"];
    lessonCount = [coder decodeIntForKey:@"lessonCount"];
    excused = [coder decodeBoolForKey:@"excused"];
    subjectIdentifiers = [coder decodeObjectForKey:@"subjectIdentifiers"];
    
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
        return [reason isEqualToString:((Absence*)other).reason];
    }
}

-(NSUInteger)hash{
    return [reason hash];
}
@end
