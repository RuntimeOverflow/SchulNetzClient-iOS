#import <Foundation/Foundation.h>
#import "Subject.h"

@interface Teacher : NSObject <NSSecureCoding>
@property NSMutableArray* subjects;
@property NSMutableArray* lessons;

@property NSString* firstName;
@property NSString* lastName;
@property NSString* shortName;
@property NSString* mail;
@end
