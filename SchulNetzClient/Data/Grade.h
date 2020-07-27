#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class Subject;
@interface Grade : NSObject <NSSecureCoding>
@property Subject* subject;

@property NSDate* date;
@property NSString* content;
@property double grade;
@property NSString* details;
@property double weight;

+(UIColor*)colorForGrade:(double)grade;
@end
