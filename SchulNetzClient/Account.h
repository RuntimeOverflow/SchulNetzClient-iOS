#import <Foundation/Foundation.h>
#import "Libraries/HTMLReader/include/HTMLReader.h"
#import "ViewControllers/RefreshViewController.h"
#import "Data/User.h"

@interface Account : NSObject
@property NSString* url;
@property NSString* username;
@property NSString* password;

@property User* user;

@property NSString* currentId;
@property NSString* currentTransId;
@property NSMutableArray* cookiesList;
@property NSString* currentCookies;

-(id) initWithUsername: (NSString*) username password: (NSString*) password url: (NSString*) url;
-(id) initFromCredentials;
+(Account*) getCurrent;
-(int) login;
-(void) logout;
-(BOOL) refresh: (RefreshViewController*) vc;
-(HTMLDocument*) loadPage: (int) pageId;
-(int) verify;
-(void) saveCredentials;
+(void) deleteCredentials;
-(NSString*) getTransId: (HTMLDocument*) src;
-(NSString*) getCookies: (NSDictionary*) headers;
@end
