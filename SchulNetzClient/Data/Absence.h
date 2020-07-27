#import <Foundation/Foundation.h>

@interface Absence : NSObject <NSSecureCoding>
@property NSMutableArray* subjects;

@property NSDate* startDate;
@property NSDate* endDate;
@property NSString* reason;
@property NSString* additionalInformation;
@property int lessonCount;
@property BOOL excused;
@property NSMutableArray* subjectIdentifiers;
@end
