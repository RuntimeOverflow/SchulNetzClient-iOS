#import "Change.h"

@implementation Change
@synthesize previous;
@synthesize current;

@synthesize varName;

@synthesize type;

-(void)initWithPrevious:(NSObject*)previousObject current:(NSObject*)currentObject varName:(NSString*)variableName chnageType:(ChangeType)changeType{
    previous = previousObject;
    current = currentObject;
    
    varName = variableName;
    
    type = changeType;
}

+(NSMutableArray*)getChanges:(User*)previous current:(User*)current{
    NSMutableArray* changes = [[NSMutableArray alloc] init];
    
    
    
    return changes;
}
@end
