#import "User.h"
#import "Data.h"

@implementation User
@synthesize teachers;
@synthesize students;
@synthesize lessons;
@synthesize subjects;
@synthesize absences;

-(instancetype)init{
    teachers = [[NSMutableArray alloc] init];
    students = [[NSMutableArray alloc] init];
    lessons = [[NSMutableArray alloc] init];
    subjects = [[NSMutableArray alloc] init];
    absences = [[NSMutableArray alloc] init];
    
    return self;
}

+(instancetype)initFromCache{
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSMutableSet* classes = [[NSMutableSet alloc] init];
    [classes addObject: [NSString class]];
    [classes addObject: [NSMutableArray class]];
    [classes addObject: [NSDate class]];
    [classes addObject: [User class]];
    [classes addObject: [Teacher class]];
    [classes addObject: [Student class]];
    [classes addObject: [Lesson class]];
    [classes addObject: [Subject class]];
    [classes addObject: [Grade class]];
    [classes addObject: [Absence class]];
    
    User* user = [NSKeyedUnarchiver unarchivedObjectOfClasses:classes fromData:[[NSUserDefaults standardUserDefaults] objectForKey:@"cacheData"] error:nil];
    return user;
}

-(void)cacheData{
    [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:self requiringSecureCoding:true error:nil] forKey:@"cacheData"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)encodeWithCoder:(NSCoder*)coder{
    [coder encodeObject:teachers forKey:@"teachers"];
    [coder encodeObject:students forKey:@"students"];
    [coder encodeObject:lessons forKey:@"lessons"];
    [coder encodeObject:subjects forKey:@"subjects"];
    [coder encodeObject:absences forKey:@"absences"];
}

-(instancetype)initWithCoder:(NSCoder*)coder{
    teachers = [coder decodeObjectForKey:@"teachers"];
    students = [coder decodeObjectForKey:@"students"];
    lessons = [coder decodeObjectForKey:@"lessons"];
    subjects = [coder decodeObjectForKey:@"subjects"];
    absences = [coder decodeObjectForKey:@"absences"];
    
    return self;
}

+(BOOL)supportsSecureCoding{
    return true;
}
@end
