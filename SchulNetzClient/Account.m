#import "Account.h"
#import "Parser.h"
#import "Util.h"
#import "Data/User.h"

@implementation Account
@synthesize url;
@synthesize username;
@synthesize password;

@synthesize user;

@synthesize currentId;
@synthesize currentTransId;
@synthesize cookiesList;
@synthesize currentCookies;

static Account* current;

-(id) initWithUsername: (NSString*) username password: (NSString*) password url: (NSString*) url{
	self.url = url;
    self.username = username;
    self.password = password;
	
	cookiesList = [[NSMutableArray alloc] init];
	
	user = [[User alloc] init];
	self = [super init];
	current = self;
    return self;
}

-(id) initFromCredentials{
	NSDictionary* credentials = [[NSURLCredentialStorage sharedCredentialStorage] credentialsForProtectionSpace:[Util getProtectionSpace]];
	NSURLCredential* credential = [credentials.objectEnumerator nextObject];
	
	return [self initWithUsername: credential.user password: credential.password url: [[NSUserDefaults standardUserDefaults] objectForKey:@"url"]];
}

+(Account*) getCurrent{
	return current;
}

-(int) login{
    NSURLSession* defaultSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];

    NSURL* loginUrl = [NSURL URLWithString:[NSString stringWithFormat:@"https://%@", url]];
    NSMutableURLRequest* urlRequest = [NSMutableURLRequest requestWithURL:loginUrl];

    [urlRequest setHTTPMethod:@"GET"];
	
	__block HTMLDocument* loginSrc;
	
    __block BOOL done = NO;
	__block int failed = false;
    NSURLSessionDataTask *dataTask = [defaultSession dataTaskWithRequest:urlRequest completionHandler:^(NSData* data, NSURLResponse* response, NSError* error) {
		if(error != NULL || data == NULL){
			failed = (int)error.code;
			done = YES;
			return;
		}
		
		NSDictionary* headers = [(NSHTTPURLResponse*) response allHeaderFields];
		loginSrc = [[HTMLDocument alloc] initWithData:data contentTypeHeader:headers[@"Content-Type"]];
		
		self->currentCookies = [self getCookies: headers];
		
		done = YES;
    }];
    [dataTask resume];

    while (!done) {
        NSDate *date = [[NSDate alloc] initWithTimeIntervalSinceNow:0.1];
        [[NSRunLoop currentRunLoop] runUntilDate:date];
    }
	
	if(failed != 0) return failed;
	
	NSString* loginHash = [[[loginSrc nodesMatchingSelector:@"*[name=\"loginhash\"]"][0] attributes] valueForKey:@"value"];

	loginUrl = [NSURL URLWithString:[NSString stringWithFormat:@"https://%@/index.php?pageid=1", url]];
	urlRequest = [NSMutableURLRequest requestWithURL:loginUrl];
	
	NSMutableString *postParams = [[NSMutableString alloc]initWithString:@"login="];
	[postParams appendString: self->username];
	[postParams appendString:@"&passwort="];
	[postParams appendString: self->password];
	[postParams appendString:@"&loginhash="];
	[postParams appendString: loginHash];
	
	NSData *postData = [postParams dataUsingEncoding:NSUTF8StringEncoding];
	
	[urlRequest setHTTPMethod:@"POST"];
	[urlRequest setHTTPBody:postData];
	[urlRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
	[urlRequest setValue:@"keep-alive" forHTTPHeaderField:@"Connection"];
	[urlRequest setValue:self->currentCookies forHTTPHeaderField:@"Cookie"];
	
	__block HTMLDocument* pageSrc;
	
	done = false;
	dataTask = [defaultSession dataTaskWithRequest:urlRequest completionHandler:^(NSData* data, NSURLResponse* response, NSError* error) {
		if(error != NULL || data == NULL){
			failed = (int)error.code;
			done = YES;
			return;
		}
		
		pageSrc = [[HTMLDocument alloc] initWithData:data contentTypeHeader:[(NSHTTPURLResponse*) response allHeaderFields][@"Content-Type"]];
		
		self->currentCookies = [self getCookies: [(NSHTTPURLResponse*) response allHeaderFields]];
		self->currentTransId = [self getTransId:pageSrc];
		
		HTMLElement* navBar = [pageSrc firstNodeMatchingSelector:@"*[id=\"nav-main-menu\"]"];
		NSString* href = [[[navBar childElementNodes][0] attributes] valueForKey:@"href"];
		
		NSRange idRange = NSMakeRange([href rangeOfString:@"&id="].location + [@"&id=" length], [href rangeOfString:@"&transid="].location - [href rangeOfString:@"&id="].location - [@"&id=" length]);
		self->currentId = [href substringWithRange: idRange];
		
		done = YES;
	}];
	[dataTask resume];
	
	while (!done) {
		NSDate *date = [[NSDate alloc] initWithTimeIntervalSinceNow:0.1];
		[[NSRunLoop currentRunLoop] runUntilDate:date];
	}
	
	if(failed != 0) return false;
	return currentTransId != NULL ? 0 : 1337;
}

-(void) logout{
	[self loadPage:9999];
	currentId = currentTransId = currentCookies = @"";
}

-(BOOL) refresh: (RefreshViewController*) vc{
	if(vc != NULL) [vc setProgress:-1 withDescription:@"Logging in..."];
	user = [[User alloc] init];
	int success = [self login];
	
	if(success != 0) return false;
	
	NSArray* allPages = [Parser allPages];
	for(NSNumber* pageNumber in allPages){
		int pageId = [pageNumber intValue];
		
		if(vc != NULL) [vc setProgress:(int)[allPages indexOfObject:pageNumber] withDescription:[@"Fetching " stringByAppendingString:[Parser getName:pageId]]];
		
		HTMLDocument* src = [self loadPage: pageId];
		
		if(src == NULL){
			return false;
		}
		
		[Parser parsePage:src pageId:pageId];
	}
	
	if(vc != NULL) [vc setProgress:-1 withDescription:@"Logging out..."];
	[self logout];
	
	if(vc != NULL) [vc setProgress:-2 withDescription:@"Logging out..."];
	
	[[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"lastRefresh"];
	
	return true;
}

-(HTMLDocument*) loadPage: (int) pageId{
	__block HTMLDocument* src;
	
	NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
	
	NSMutableString *urlString = [[NSMutableString alloc]initWithFormat:@"https://%@/index.php?pageid=", url];
	[urlString appendString: [[[NSNumber alloc] initWithInt:pageId] stringValue]];
	[urlString appendString:@"&id="];
	[urlString appendString: currentId];
	[urlString appendString:@"&transid="];
	[urlString appendString: currentTransId];
	
	NSURL *url = [NSURL URLWithString:urlString];
	NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];

	[urlRequest setHTTPMethod:@"GET"];
	[urlRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
	[urlRequest setValue:@"keep-alive" forHTTPHeaderField:@"Connection"];
	[urlRequest setValue:self->currentCookies forHTTPHeaderField:@"Cookie"];
	
	__block BOOL done = NO;
	__block BOOL failed = false;
	NSURLSessionDataTask *dataTask = [defaultSession dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
		if(error != NULL || data == NULL) {
			failed = true;
			done = YES;
			return;
		}
		
		src = [[HTMLDocument alloc] initWithData:data contentTypeHeader:[(NSHTTPURLResponse*) response allHeaderFields][@"Content-Type"]];
		
		if(pageId == 9999){
			self->currentCookies = [self getCookies: [(NSHTTPURLResponse*) response allHeaderFields]];
			self->currentTransId = [self getTransId:src];
		}
		
		done = YES;
	}];
	[dataTask resume];
	
	while (!done) {
		NSDate *date = [[NSDate alloc] initWithTimeIntervalSinceNow:0.5];
		[[NSRunLoop currentRunLoop] runUntilDate:date];
	}
	
	if(failed) return NULL;
	
	return src;
}

-(int) verify{
    BOOL canConnect = [Util checkConnection];
    int loginCode = 0;
    
    if(canConnect){
        loginCode = [self login];
        if(loginCode == 0){
            [self logout];
        }
    }
	
	return loginCode;
}

-(void) saveCredentials{
	[[NSUserDefaults standardUserDefaults] setObject:url forKey:@"url"];
	
	NSURLCredential* credential = [NSURLCredential credentialWithUser:username password:password persistence:NSURLCredentialPersistencePermanent];
	[[NSURLCredentialStorage sharedCredentialStorage] setCredential:credential forProtectionSpace:[Util getProtectionSpace]];
	
    [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"loggedIn"];
}

+(void) deleteCredentials{
    [[NSUserDefaults standardUserDefaults] setBool:false forKey:@"loggedIn"];
}

-(NSString *) getTransId: (HTMLDocument*) src{
	NSString* transId = @"";
	
	HTMLElement* navBar = [src firstNodeMatchingSelector:@"*[id=\"nav-main-menu\"]"];
	NSString* href = [[[navBar childElementNodes][0] attributes] valueForKey:@"href"];
	transId = [href substringFromIndex: [href rangeOfString:@"transid="].location + [@"transid=" length]];
	
	return transId;
}

-(NSString *) getCookies: (NSDictionary *)headers{
	NSMutableString* cookies = [[NSMutableString alloc]initWithString:@""];
	
	NSMutableString* setCookie = [[NSMutableString alloc] initWithString:[(NSString*) headers valueForKey:@"Set-Cookie"]];
	if([setCookie rangeOfString:@", \\d" options:NSRegularExpressionSearch].location != NSNotFound) [setCookie replaceCharactersInRange:NSMakeRange([setCookie rangeOfString:@", \\d" options:NSRegularExpressionSearch].location, 1) withString:@""];
	
	for(NSString* value in [setCookie componentsSeparatedByString:@","]){
		BOOL existing = false;
		
		for(NSString* old in cookiesList){
			if([[value substringToIndex:[value rangeOfString:@"="].location] isEqualToString:[old substringToIndex:[value rangeOfString:@"="].location]]) {
				[cookiesList setObject:value atIndexedSubscript:[cookiesList indexOfObject:old]];
				existing = true;
				break;
			}
		}
		
		if(!existing) [cookiesList addObject:value];
	}
	
	for(NSString* value in cookiesList){
		if([cookies length] > 0) [cookies appendString:@";"];
		
		[cookies appendString:([value rangeOfString:@";"].location) >= 0 ? [value substringToIndex:[value rangeOfString:@";"].location] : value];
	}
	
	return cookies;
}
@end
