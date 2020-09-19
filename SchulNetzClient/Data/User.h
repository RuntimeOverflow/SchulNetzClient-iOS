#import <Foundation/Foundation.h>
#import "Student.h"
#import "Teacher.h"
#import "Subject.h"
#import "Absence.h"
#import "Transaction.h"
#import "Lesson.h"

@interface User : NSObject <NSSecureCoding>
@property Student* me;

@property NSMutableDictionary* lessonTypeDict;
@property NSMutableDictionary* roomDict;

@property BOOL balanceConfirmed;
@property NSMutableArray<Teacher*>* teachers;
@property NSMutableArray<Student*>* students;
@property NSMutableArray<Subject*>* subjects;
@property NSMutableArray<Transaction*>* transactions;
@property NSMutableArray<Absence*>* absences;
@property NSMutableArray<Lesson*>* lessons;

+(User*)load;
-(void)save;
-(User*)copy;

-(void)processConnections;
-(Teacher*)teacherForShortName:(NSString*)shortName;
-(Subject*)subjectForShortName:(NSString*)shortName;
-(Subject*)subjectForIdentifier:(NSString*)identifier;
-(void)processLessons:(NSMutableArray*)lessons;
@end
