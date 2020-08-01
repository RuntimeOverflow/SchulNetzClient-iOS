#import <Foundation/Foundation.h>
#import "Libraries/HTMLReader/include/HTMLReader.h"
#import "Data/User.h"

@interface Parser : NSObject
+(BOOL)parseGrades:(HTMLDocument*)doc forUser:(User*)user;
+(BOOL)parseSubjects:(HTMLDocument*)doc forUser:(User*)user;
+(BOOL)parseStudents:(HTMLDocument*)doc forUser:(User*)user;
+(BOOL)parseTeachers:(HTMLDocument*)doc forUser:(User*)user;
+(BOOL)parseSelf:(HTMLDocument*)doc forUser:(User*)user;
+(BOOL)parseTransactions:(HTMLDocument*)doc forUser:(User*)user;
+(BOOL)parseAbsences:(HTMLDocument*)doc forUser:(User*)user;
+(BOOL)parseSchedulePage:(HTMLDocument*)doc forUser:(User*)user;

+(NSMutableArray*)parseSchedule:(HTMLDocument*)doc;
@end
