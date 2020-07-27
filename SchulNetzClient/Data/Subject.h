#import <Foundation/Foundation.h>
#import "Grade.h"
@class Teacher;

@interface Subject : NSObject <NSSecureCoding>
@property NSString* identifier;
@property NSString* name;
@property NSString* shortName;
@property Teacher* teacher;
@property double average;
@property BOOL gradesConfirmed;
@property BOOL gradesHidden;
@property NSMutableArray* grades;

@property NSString* teacherKey;

-(void)afterInit;
@end
