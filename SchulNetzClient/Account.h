#import <Foundation/Foundation.h>
#import "Libraries/HTMLReader/include/HTMLReader.h"
#import "Data/User.h"
#import "SessionManager.h"

@interface Account : NSObject {
    NSString* currentId;
    NSString* currentTransId;
    NSMutableArray* cookiesList;
    NSString* currentCookies;
    
    BOOL signingIn;
    BOOL signingOut;
    
    SessionManager* manager;
}

@property NSString* host;
@property NSString* username;
@property NSString* password;

@property BOOL signedIn;

-(instancetype)initWithUsername:(NSString*)username password:(NSString*)password host:(NSString*)host;
-(instancetype)initWithUsername:(NSString*)username password:(NSString*)password host:(NSString*)host session:(BOOL)session;

-(instancetype)initFromCredentials;
-(instancetype)initFromCredentials:(BOOL)session;


-(void)saveCredentials;
+(void)deleteCredentials;

-(NSObject*)signIn;
-(NSObject*)signOut;
-(NSObject*)signOut:(BOOL)instant;
-(NSObject*)resetTimeout;

-(void)loadPage:(NSString*)pageId completion:(void (^)(NSObject*))completion;
-(void)loadScheduleFrom:(NSDate*)from to:(NSDate*)to completion:(void (^)(NSObject*))completion;
-(void)loadScheduleFrom:(NSDate*)from to:(NSDate*)to view:(NSString*)view completion:(void (^)(NSObject*))completion;

-(NSString*)getTransId:(HTMLDocument*)src;
-(NSString*)getCookies:(NSDictionary*)headers;

-(void)close;
@end
