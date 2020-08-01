#import <Foundation/Foundation.h>
#import "Subject.h"

@interface Absence : NSObject <NSSecureCoding>
@property NSMutableArray<Subject*>* subjects;

@property NSDate* startDate;
@property NSDate* endDate;
@property NSString* reason;
@property NSString* additionalInformation;
@property int lessonCount;
@property BOOL excused;
@property NSMutableArray* subjectIdentifiers;
@end
