#import <Foundation/Foundation.h>

@interface User : NSObject <NSSecureCoding>
@property NSMutableArray* teachers;
@property NSMutableArray* students;
@property NSMutableArray* lessons;
@property NSMutableArray* subjects;
@property NSMutableArray* absences;

+(instancetype)initFromCache;
-(void)cacheData;
@end
