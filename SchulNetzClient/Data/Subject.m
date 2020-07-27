#import "Subject.h"
#import "../Account.h"
#import "Teacher.h"

@implementation Subject
@synthesize identifier;
@synthesize name;
@synthesize shortName;
@synthesize teacher;
@synthesize average;
@synthesize gradesConfirmed;
@synthesize gradesHidden;
@synthesize grades;

@synthesize teacherKey;

-(instancetype)init{
    grades = [[NSMutableArray alloc] init];
    
    return self;
}

-(void)afterInit{
    if(teacherKey != nil){
        for(Teacher* t in [Account getCurrent].user.teachers){
            if([t.initials isEqualToString:teacherKey]) {
                teacher = t;
                [t.subjects addObject:self];
                break;
            }
        }
    } else teacher = nil;
}

-(void)encodeWithCoder:(NSCoder*)coder{
    [coder encodeObject:identifier forKey:@"identifier"];
    [coder encodeObject:name forKey:@"name"];
    [coder encodeObject:shortName forKey:@"shortName"];
    [coder encodeDouble:average forKey:@"average"];
    [coder encodeBool:gradesConfirmed forKey:@"gradesConfirmed"];
    [coder encodeBool:gradesHidden forKey:@"gradesHidden"];
    [coder encodeObject:grades forKey:@"grades"];
    
    if(teacher != nil) [coder encodeObject:teacher.initials forKey:@"teacher"];
    else [coder encodeObject:nil forKey:@"teacher"];
}

-(instancetype)initWithCoder:(NSCoder*)coder{
    identifier = [coder decodeObjectForKey:@"identifier"];
    name = [coder decodeObjectForKey:@"name"];
    shortName = [coder decodeObjectForKey:@"shortName"];
    average = [coder decodeDoubleForKey:@"average"];
    gradesConfirmed = [coder decodeBoolForKey:@"gradesConfirmed"];
    gradesHidden = [coder decodeBoolForKey:@"gradesHidden"];
    grades = [coder decodeObjectForKey:@"grades"];
    
    teacherKey = [coder decodeObjectForKey:@"teacher"];
    
    return self;
}

+(BOOL)supportsSecureCoding{
    return true;
}
@end
