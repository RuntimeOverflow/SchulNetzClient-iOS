#import <Foundation/Foundation.h>
#import "Subject.h"

@interface SubjectGroup : NSObject <NSSecureCoding>
@property NSMutableArray<Subject*>* subjects;

@property NSMutableArray<NSString*>* subjectIdentifiers;
@property int roundOption;
@property NSString* name;

-(double)getGrade;
@end
