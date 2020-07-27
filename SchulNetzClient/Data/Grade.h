#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Grade : NSObject <NSSecureCoding>
@property NSDate* date;
@property NSString* content;
@property double grade;
@property NSString* details;
@property double weight;

+(UIColor*)colorForGrade:(double)grade;
@end
