#import <Foundation/Foundation.h>
#import "Grade.h"
@class Teacher;

@interface Subject : NSObject <NSSecureCoding>
@property Teacher* teacher;
@property NSMutableArray* lessons;

@property NSMutableArray* grades;
@property NSString* identifier;
@property NSString* name;
@property NSString* shortName;
@property BOOL confirmed;
@property BOOL hiddenGrades;

-(double)getAverage;
@end
