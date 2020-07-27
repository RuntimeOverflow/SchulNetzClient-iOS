#import "Subject.h"
#import "../Account.h"
#import "Teacher.h"

@implementation Subject
@synthesize teacher;
@synthesize lessons;

@synthesize grades;
@synthesize identifier;
@synthesize name;
@synthesize shortName;
@synthesize confirmed;
@synthesize hiddenGrades;

-(instancetype)init{
    lessons = [[NSMutableArray alloc] init];
    grades = [[NSMutableArray alloc] init];
    
    return self;
}

-(double)getAverage{
    double total = 0;
    double count = 0;
    for(Grade* g in grades){
        if(g.grade > 0){
            count += g.weight;
            total += g.weight * g.grade;
        }
    }
    
    return total / count;
}

-(void)encodeWithCoder:(NSCoder*)coder{
    [coder encodeObject:grades forKey:@"grades"];
    [coder encodeObject:identifier forKey:@"identifier"];
    [coder encodeObject:name forKey:@"name"];
    [coder encodeObject:shortName forKey:@"shortName"];
    [coder encodeBool:confirmed forKey:@"confirmed"];
    [coder encodeBool:hiddenGrades forKey:@"hiddenGrades"];
}

-(instancetype)initWithCoder:(NSCoder*)coder{
    lessons = [[NSMutableArray alloc] init];
    
    grades = [coder decodeObjectForKey:@"grades"];
    identifier = [coder decodeObjectForKey:@"identifier"];
    name = [coder decodeObjectForKey:@"name"];
    shortName = [coder decodeObjectForKey:@"shortName"];
    confirmed = [coder decodeBoolForKey:@"confirmed"];
    hiddenGrades = [coder decodeBoolForKey:@"hiddenGrades"];
    
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
        return [shortName isEqualToString:((Subject*)other).shortName];
    }
}

-(NSUInteger)hash{
    return [shortName hash];
}
@end
