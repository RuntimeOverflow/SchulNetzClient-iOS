#import <Foundation/Foundation.h>
#import "Libraries/HTMLReader/include/HTMLReader.h"

@interface Parser : NSObject
+(void) parsePage: (HTMLDocument*) src pageId: (int) pageId;
+(NSArray*) allPages;
+(NSString*) getName: (int) pageId;
@end
