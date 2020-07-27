#import <Foundation/Foundation.h>
#import "Student.h"
#import "Teacher.h"
#import "Subject.h"

@interface User : NSObject <NSSecureCoding>
@property Student* me;

@property NSMutableDictionary* lessonTypeDict;
@property NSMutableDictionary* roomDict;

@property BOOL balanceConfirmed;
@property NSMutableArray* teachers;
@property NSMutableArray* students;
@property NSMutableArray* subjects;
@property NSMutableArray* transactions;
@property NSMutableArray* absences;
@property NSMutableArray* lessons;

+(User*)load;
-(void)save;

-(void)processConnections;
-(Teacher*)teacherForShortName:(NSString*)shortName;
-(Subject*)subjectForShortName:(NSString*)shortName;
-(Subject*)subjectForIdentifier:(NSString*)identifier;
-(void)processLessons:(NSMutableArray*)lessons;
@end
