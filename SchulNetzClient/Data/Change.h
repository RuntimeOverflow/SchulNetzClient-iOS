#import <Foundation/Foundation.h>
#import "User.h"

typedef enum {
    ADDED, MODIFIED, REMOVED
} ChangeType;

@interface Change : NSObject
@property NSObject* previous;
@property NSObject* current;

@property NSString* varName;

@property ChangeType type;

-(void)initWithPrevious:(NSObject*)previousObject current:(NSObject*)currentObject varName:(NSString*)variableName chnageType:(ChangeType)changeType;

+(NSMutableArray*)getChanges:(User*)previous current:(User*)current;
@end
