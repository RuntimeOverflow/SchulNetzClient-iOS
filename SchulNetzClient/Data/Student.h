#import <Foundation/Foundation.h>

@interface Student : NSObject <NSSecureCoding>
@property NSString* firstName;
@property NSString* lastName;
@property BOOL gender;
@property NSString* degree;
@property BOOL bilingual;
@property NSString* className;
@property NSString* address;
@property int zipCode;
@property NSString* city;
@property NSString* phone;
@property NSDate* dateOfBirth;
@property NSString* additionalClasses;
@property NSString* status;
@property NSString* placeOfWork;
@property BOOL me;
@end
