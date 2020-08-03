#import "Lesson.h"
#import "../Account.h"

@implementation Lesson
@synthesize subject;
@synthesize teacher;
@synthesize room;

@synthesize startDate;
@synthesize endDate;
@synthesize lessonIdentifier;
@synthesize roomNumber;
@synthesize color;
@synthesize type;
@synthesize marking;
@synthesize replacementTeacher;

-(void)encodeWithCoder:(NSCoder*)coder{
    [coder encodeObject:startDate forKey:@"startDate"];
    [coder encodeObject:endDate forKey:@"endDate"];
    [coder encodeObject:lessonIdentifier forKey:@"lessonIdentifier"];
    [coder encodeInt:roomNumber forKey:@"roomNumber"];
    [coder encodeObject:color forKey:@"color"];
    [coder encodeObject:type forKey:@"type"];
    [coder encodeObject:marking forKey:@"marking"];
    [coder encodeObject:replacementTeacher forKey:@"replacementTeacher"];
}

-(instancetype)initWithCoder:(NSCoder*)coder{
    startDate = [coder decodeObjectForKey:@"startDate"];
    endDate = [coder decodeObjectForKey:@"endDate"];
    lessonIdentifier = [coder decodeObjectForKey:@"lessonIdentifier"];
    roomNumber = [coder decodeIntForKey:@"roomNumber"];
    color = [coder decodeObjectForKey:@"color"];
    type = [coder decodeObjectForKey:@"type"];
    marking = [coder decodeObjectForKey:@"marking"];
    replacementTeacher = [coder decodeObjectForKey:@"replacementTeacher"];
    
    return self;
}

+(BOOL)supportsSecureCoding{
    return true;
}

-(BOOL)longerThanOrEqualToOneDay{
    NSDate* c = [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitDay value:1 toDate:startDate options:0];
    
    return [endDate compare:c] != NSOrderedAscending;
}

+(NSMutableArray*)orderByStartTime:(NSMutableArray*)lessons{
    if(lessons == NULL) return [[NSMutableArray alloc] init];
    NSMutableArray* sorted = [[NSMutableArray alloc] init];
    
    for(Lesson* lesson in lessons){
        if(lesson.startDate == NULL) continue;
        
        int index = (int)sorted.count;
        for(int i = 0; i < sorted.count; i++){
            if([((Lesson*)sorted[i]).startDate compare:lesson.startDate] == NSOrderedDescending){
                index = i;
                break;
            }
        }
        
        [sorted insertObject:lesson atIndex:index];
    }
    
    return sorted;
}

+(NSMutableArray*)orderByEndTime:(NSMutableArray*)lessons{
    if(lessons == NULL) return [[NSMutableArray alloc] init];
    NSMutableArray* sorted = [[NSMutableArray alloc] init];
    
    for(Lesson* lesson in lessons){
        if(lesson.endDate == NULL) continue;
        
        int index = (int)sorted.count;
        for(int i = 0; i < sorted.count; i++){
            if([((Lesson*)sorted[i]).endDate compare:lesson.endDate] == NSOrderedDescending){
                index = i;
                break;
            }
        }
        
        [sorted insertObject:lesson atIndex:index];
    }
    
    return sorted;
}
@end

@implementation ScheduleLesson
@synthesize lesson;
@synthesize start;
@synthesize end;
@synthesize index;
@synthesize total;

+(NSMutableArray*)orderByStartTime:(NSMutableArray*)lessons{
    if(lessons == NULL) return [[NSMutableArray alloc] init];
    NSMutableArray* sorted = [[NSMutableArray alloc] init];
    
    for(ScheduleLesson* lesson in lessons){
        if(lesson.lesson.startDate == NULL) continue;
        
        int index = (int)sorted.count;
        for(int i = 0; i < sorted.count; i++){
            if([((ScheduleLesson*)sorted[i]).lesson.startDate compare:lesson.lesson.startDate] == NSOrderedDescending){
                index = i;
                break;
            }
        }
        
        [sorted insertObject:lesson atIndex:index];
    }
    
    return sorted;
}

+(NSMutableArray*)orderByEndTime:(NSMutableArray*)lessons{
    if(lessons == NULL) return [[NSMutableArray alloc] init];
    NSMutableArray* sorted = [[NSMutableArray alloc] init];
    
    for(ScheduleLesson* lesson in lessons){
        if(lesson.lesson.endDate == NULL) continue;
        
        int index = (int)sorted.count;
        for(int i = 0; i < sorted.count; i++){
            if([((ScheduleLesson*)sorted[i]).lesson.endDate compare:lesson.lesson.endDate] == NSOrderedDescending){
                index = i;
                break;
            }
        }
        
        [sorted insertObject:lesson atIndex:index];
    }
    
    return sorted;
}
@end
