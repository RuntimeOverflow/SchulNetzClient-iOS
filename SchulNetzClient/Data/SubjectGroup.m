#import "SubjectGroup.h"

@implementation SubjectGroup
@synthesize subjects;

@synthesize subjectIdentifiers;
@synthesize roundOption;
@synthesize name;

-(instancetype)init{
    self = [super init];
    
    subjects = [[NSMutableArray alloc] init];
    
    subjectIdentifiers = [[NSMutableArray alloc] init];
    roundOption = 1;
    
    return self;
}

-(double)getGrade{
    if(roundOption == 0){
        return NAN;
    } else if(roundOption == 1){
        double total = 0;
        int count = 0;
        for(Subject* s in subjects){
            double average = [s getAverage];
            if(!isnan(average) && average >= 1){
                total += average;
                count++;
            }
        }
        
        return total / count;
    } else if(roundOption == 2){
        double total = 0;
        int count = 0;
        for(Subject* s in subjects){
            double average = [s getAverage];
            if(!isnan(average) && average >= 1){
                total += round(average * 2.0) / 2.0;
                count++;
            }
        }
        
        return total / count;
    }
    
    return NAN;
}

-(void)encodeWithCoder:(NSCoder*)coder{
    [coder encodeObject:subjectIdentifiers forKey:@"subjectIdentifiers"];
    [coder encodeInt:roundOption forKey:@"roundOption"];
    [coder encodeObject:name forKey:@"name"];
}

-(instancetype)initWithCoder:(NSCoder*)coder{
    subjectIdentifiers = [coder decodeObjectForKey:@"subjectIdentifiers"];
    roundOption = [coder decodeIntForKey:@"roundOption"];
    name = [coder decodeObjectForKey:@"name"];
    
    subjects = [[NSMutableArray alloc] init];
    
    return self;
}


+(BOOL)supportsSecureCoding{
    return true;
}
@end
