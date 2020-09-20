#import "AppDelegate.h"
#import "Util.h"
#import "Account.h"
#import "Variables.h"
#import "Parser.h"
#import "Data/Change.h"

@implementation AppDelegate
@synthesize window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    UNNotificationCategory* generalCategory = [UNNotificationCategory
         categoryWithIdentifier:@"GENERAL"
         actions:@[]
         intentIdentifiers:@[]
         options:UNNotificationCategoryOptionCustomDismissAction];
     
    UNUserNotificationCenter* center = [UNUserNotificationCenter currentNotificationCenter];
    [center setNotificationCategories:[NSSet setWithObjects:generalCategory, nil]];
    center.delegate = self;
    
    [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
    
    return YES;
}

- (void)userNotificationCenter:(UNUserNotificationCenter* )center willPresentNotification:(UNNotification* )notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler {

    completionHandler(UNNotificationPresentationOptionAlert);
}

- (void)applicationDidBecomeActive:(UIApplication *)application{
    if([Variables get].account){
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            [[Variables get].account signOut:true];
            [[Variables get].account signIn];
        });
    }
}

- (void)applicationWillResignActive:(UIApplication *)application{
    if([Variables get].account && [Variables get].account.signedIn){
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            [[Variables get].account signOut:true];
        });
    }
}

- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler{
    __block UIBackgroundTaskIdentifier backgroundTask = [application beginBackgroundTaskWithExpirationHandler:^{
        [application endBackgroundTask:backgroundTask];
        backgroundTask = UIBackgroundTaskInvalid;
    }];
    
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"loggedIn"]){
        User* previous = [User load];
        User* user = [[User alloc] init];
        Account* account = [[Account alloc] initFromCredentials:false];
        
        NSObject* res = [account signIn];
        if(![[res class] isSubclassOfClass:[NSNumber class]] || !((NSNumber*)res).boolValue){
            completionHandler(UIBackgroundFetchResultNoData);
            [application endBackgroundTask:backgroundTask];
            backgroundTask = UIBackgroundTaskInvalid;
            return;
        }
        
        [account loadPage:@"22352" completion:^(NSObject *doc) {
            if([doc class] == [HTMLDocument class]) [Parser parseTeachers:(HTMLDocument*)doc forUser:user];
            else user.teachers = previous.teachers;
        }];
        [account loadPage:@"22326" completion:^(NSObject *doc) {
            if([doc class] == [HTMLDocument class]) [Parser parseSubjects:(HTMLDocument*)doc forUser:user];
            else user.subjects = previous.subjects;
            if([doc class] == [HTMLDocument class]) [Parser parseStudents:(HTMLDocument*)doc forUser:user];
            else user.students = previous.students;
        }];
        [account loadPage:@"21311" completion:^(NSObject *doc) {
            if([doc class] == [HTMLDocument class]) [Parser parseGrades:(HTMLDocument*)doc forUser:user];
            else user.subjects = previous.subjects;
        }];
        [account loadPage:@"21411" completion:^(NSObject *doc) {
            if([doc class] == [HTMLDocument class]) [Parser parseSelf:(HTMLDocument*)doc forUser:user];
            else{
                for(Student* s in user.students){
                    if([s.firstName.lowercaseString isEqualToString:previous.me.firstName.lowercaseString] && [s.lastName.lowercaseString isEqualToString:previous.me.lastName.lowercaseString]){
                        s.me = true;
                        break;
                    }
                }
            }
            if([doc class] == [HTMLDocument class]) [Parser parseTransactions:(HTMLDocument*)doc forUser:user];
            else user.transactions = previous.transactions;
        }];
        [account loadPage:@"21111" completion:^(NSObject *doc) {
            if([doc class] == [HTMLDocument class]) [Parser parseAbsences:(HTMLDocument*)doc forUser:user];
            else user.absences = previous.absences;
        }];
        [account loadPage:@"22202" completion:^(NSObject *doc) {
            if([doc class] == [HTMLDocument class]) [Parser parseSchedulePage:(HTMLDocument*)doc forUser:user];
            else{
                user.lessonTypeDict = previous.lessonTypeDict;
                user.roomDict = previous.roomDict;
            }
        }];
        
        [account loadScheduleFrom:[NSDate date] to:[NSDate date] completion:^(NSObject *doc) {
            if([doc class] == [HTMLDocument class]) user.lessons = [Parser parseSchedule:(HTMLDocument*)doc];
        }];
        
        [account signOut];
        [user processConnections];
        
        NSMutableArray<Change*>* changes = [Change getChanges:previous current:user];
        [user save];
        
        [Change publishNotifications:changes];
    }
    
    completionHandler(UIBackgroundFetchResultNewData);
    [application endBackgroundTask:backgroundTask];
    backgroundTask = UIBackgroundTaskInvalid;
}

@end
