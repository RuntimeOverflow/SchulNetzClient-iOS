#import <Foundation/Foundation.h>
#import "Teacher.h"

@interface Lesson : NSObject <NSSecureCoding>
@property Subject* subject;
@property Teacher* teacher;
@property NSString* room;

@property NSDate* startDate;
@property NSDate* endDate;
@property NSString* lessonIdentifier;
@property int roomNumber;
@property UIColor* color;
@property NSString* type;
@property NSString* marking;
@property NSString* replacementTeacher;

-(BOOL)longerThanOrEqualToOneDay;

+(NSMutableArray*)orderByStartTime:(NSMutableArray*)lessons;
+(NSMutableArray*)orderByEndTime:(NSMutableArray*)lessons;
@end

@interface ScheduleLesson : NSObject
@property Lesson* lesson;
@property NSDate* start;
@property NSDate* end;
@property int index;
@property int total;

+(NSMutableArray*)orderByStartTime:(NSMutableArray*)lessons;
+(NSMutableArray*)orderByEndTime:(NSMutableArray*)lessons;
@end
