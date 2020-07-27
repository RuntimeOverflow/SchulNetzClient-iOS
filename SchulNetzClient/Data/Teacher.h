#import <Foundation/Foundation.h>
#import "Subject.h"

@interface Teacher : NSObject <NSSecureCoding>
@property NSString* firstName;
@property NSString* lastName;
@property NSString* initials;
@property NSString* mail;
@property NSMutableArray* subjects;
@end
