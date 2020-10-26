#import <Foundation/Foundation.h>
#import "Grade.h"
@class SubjectGroup;
@class Teacher;

@interface Subject : NSObject <NSSecureCoding>
@property Teacher* teacher;
@property NSMutableArray* lessons;
@property SubjectGroup* group;

@property NSMutableArray* grades;
@property NSString* identifier;
@property NSString* name;
@property NSString* shortName;
@property BOOL confirmed;
@property BOOL hiddenGrades;
@property BOOL unvalued;

-(double)getAverage;
@end
