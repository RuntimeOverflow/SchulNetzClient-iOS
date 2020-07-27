#import "User.h"
#import "Data.h"

@implementation User
@synthesize me;

@synthesize lessonTypeDict;
@synthesize roomDict;

@synthesize balanceConfirmed;
@synthesize teachers;
@synthesize students;
@synthesize subjects;
@synthesize transactions;
@synthesize absences;
@synthesize lessons;

-(instancetype)init{
    teachers = [[NSMutableArray alloc] init];
    students = [[NSMutableArray alloc] init];
    subjects = [[NSMutableArray alloc] init];
    transactions = [[NSMutableArray alloc] init];
    absences = [[NSMutableArray alloc] init];
    lessons = [[NSMutableArray alloc] init];
    
    return self;
}

+(User*)load{
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
    [classes addObject: [Transaction class]];
    
    User* user = [NSKeyedUnarchiver unarchivedObjectOfClasses:classes fromData:[[NSUserDefaults standardUserDefaults] objectForKey:@"cacheData"] error:nil];
    return user;
}

-(void)save{
    [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:self requiringSecureCoding:true error:nil] forKey:@"cacheData"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)processConnections{
    @try{
        for(Teacher* t in teachers) t.subjects = [[NSMutableArray alloc] init];
        
        for(Subject* s in subjects){
            if(s.identifier != NULL && [s.identifier componentsSeparatedByString:@"-"].count >= 3){
                Teacher* t = [self teacherForShortName:[s.identifier componentsSeparatedByString:@"-"][2]];
                
                if(t != NULL){
                    [t.subjects addObject:s];
                    s.teacher = t;
                }
            }
            
            for(Grade* g in s.grades){
                g.subject = s;
            }
        }
        
        for(Student* s in students){
            if(s.me) {
                me = s;
                break;
            }
        }
        
        for(Absence* a in absences){
            a.subjects = [[NSMutableArray alloc] init];
            
            for(NSString* subjectIdentifier in a.subjectIdentifiers){
                if(subjectIdentifier == NULL) continue;
                
                Subject* s = [self subjectForShortName:[subjectIdentifier componentsSeparatedByString:@"-"][0]];
                
                if(s != NULL) [a.subjects addObject:s];
            }
        }
        
        for(Lesson* l in lessons){
            if(l.lessonIdentifier != NULL && [l.lessonIdentifier componentsSeparatedByString:@"-"].count >= 3){
                Subject* s = [self subjectForShortName:[l.lessonIdentifier componentsSeparatedByString:@"-"][0]];
                if(s != NULL){
                    //[s.lessons addObject:l];
                    l.subject = s;
                }
                
                Teacher* t = [self teacherForShortName:[l.lessonIdentifier componentsSeparatedByString:@"-"][2]];
                if(t != NULL){
                    //[t.lessons addObject:l];
                    l.teacher = t;
                }
            }
            
            if(roomDict[[NSString stringWithFormat:@"%d", l.roomNumber]] != NULL) l.room = roomDict[[NSString stringWithFormat:@"%d", l.roomNumber]];
        }
    } @catch(NSException *exception){}
    @finally{}
}

-(Teacher*)teacherForShortName:(NSString*)shortName{
    for(Teacher* t in teachers) if([t.shortName.lowercaseString isEqualToString:shortName.lowercaseString]) return t;
    
    return NULL;
}

-(Subject*)subjectForShortName:(NSString*)shortName{
    for(Subject* s in subjects) if([s.shortName.lowercaseString isEqualToString:shortName.lowercaseString]) return s;
    
    return NULL;
}

-(Subject*)subjectForIdentifier:(NSString*)identifier{
    for(Subject *s in subjects) if([s.identifier.lowercaseString isEqualToString:identifier.lowercaseString]) return s;
    
    return NULL;
}

-(void)processLessons:(NSMutableArray*)lessons{
    for(Lesson* l in lessons){
        if(l.lessonIdentifier != NULL && [l.lessonIdentifier componentsSeparatedByString:@"-"].count >= 3){
            Subject* s = [self subjectForShortName:[l.lessonIdentifier componentsSeparatedByString:@"-"][0]];
            if(s != NULL){
                l.subject = s;
            }
            
            Teacher* t = [self teacherForShortName:[l.lessonIdentifier componentsSeparatedByString:@"-"][2]];
            if(t != NULL){
                l.teacher = t;
            }
        }
        
        if(roomDict[[NSString stringWithFormat:@"%d", l.roomNumber]] != NULL) l.room = roomDict[[NSString stringWithFormat:@"%d", l.roomNumber]];
    }
}

-(void)encodeWithCoder:(NSCoder*)coder{
    [coder encodeBool:balanceConfirmed forKey:@"balanceConfirmed"];
    
    [coder encodeObject:teachers forKey:@"teachers"];
    [coder encodeObject:students forKey:@"students"];
    [coder encodeObject:subjects forKey:@"subjects"];
    [coder encodeObject:transactions forKey:@"transactions"];
    [coder encodeObject:absences forKey:@"absences"];
    [coder encodeObject:lessons forKey:@"lessons"];
}

-(instancetype)initWithCoder:(NSCoder*)coder{
    balanceConfirmed = [coder decodeBoolForKey:@"balanceConfirmed"];
    
    teachers = [coder decodeObjectForKey:@"teachers"];
    students = [coder decodeObjectForKey:@"students"];
    subjects = [coder decodeObjectForKey:@"subjects"];
    transactions = [coder decodeObjectForKey:@"transactions"];
    absences = [coder decodeObjectForKey:@"absences"];
    lessons = [coder decodeObjectForKey:@"lessons"];
    
    return self;
}

+(BOOL)supportsSecureCoding{
    return true;
}
@end
