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
    
    [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:15 * 60];
    
    return YES;
}

- (void)userNotificationCenter:(UNUserNotificationCenter* )center willPresentNotification:(UNNotification* )notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler {

    completionHandler(UNNotificationPresentationOptionAlert);
}

- (void)applicationDidBecomeActive:(UIApplication *)application{
    if([Variables get].account && ![Variables get].account.signedIn){
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
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
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"loggedIn"]){
        User* previous = [User load];
        User* user = [[User alloc] init];
        Account* account = [[Account alloc] initFromCredentials:false];
        
        NSObject* res = [account signIn];
        if(![[res class] isSubclassOfClass:[NSNumber class]] || !((NSNumber*)res).boolValue){
            completionHandler(UIBackgroundFetchResultNoData);
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
        
        if([[NSUserDefaults standardUserDefaults] boolForKey:@"notificationsEnabled"]) for(Change* change in changes){
            Class c = NULL;
            
            if(change.previous) c = [change.previous class];
            else if(change.current) c = [change.current class];
            else continue;
            
            if(c == [Grade class]){
                if((change.type == ADDED && ((Grade*)change.current).grade != 0) || (change.type == MODIFIED && [change.varName isEqualToString:@"grade"] && ((Grade*)change.previous).grade == 0)){
                    [self sendNotificationWithTitle:NSLocalizedString(@"newGrade", @"") withContent:[NSString stringWithFormat:@"[%@] %@: %@", ((Grade*)change.current).subject.name, ((Grade*)change.current).content, [NSNumber numberWithDouble:((Grade*)change.current).grade].stringValue]];
                } else if(change.type == MODIFIED && [change.varName isEqualToString:@"grade"] && ((Grade*)change.current).grade == 0){
                    [self sendNotificationWithTitle:NSLocalizedString(@"modifiedGrade", @"") withContent:[NSString stringWithFormat:@"[%@] %@: %@ -> %@", ((Grade*)change.current).subject.name, ((Grade*)change.current).content, [NSNumber numberWithDouble:((Grade*)change.previous).grade].stringValue, [NSNumber numberWithDouble:((Grade*)change.current).grade].stringValue]];
                }
            } else if(c == [Absence class]){
                if(change.type == ADDED){
                    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
                    NSString* body = [NSString stringWithFormat:@"%@%@ (%@)", [formatter stringFromDate:((Absence*)change.current).startDate], (((Absence*)change.current).startDate.timeIntervalSince1970 != ((Absence*)change.current).endDate.timeIntervalSince1970 ? [NSString stringWithFormat:@" - %@", [formatter stringFromDate:((Absence*)change.current).endDate]] : @""), [NSString stringWithFormat:@"%@ %@", [NSNumber numberWithInt:((Absence*)change.current).lessonCount].stringValue, (((Absence*)change.current).lessonCount != 1 ? NSLocalizedString(@"lessons", @"") : NSLocalizedString(@"lesson", @""))]];
                    [self sendNotificationWithTitle:(((Absence*)change.current).excused ? NSLocalizedString(@"newExcusedAbsence", @"") : NSLocalizedString(@"newAbsence", @"")) withContent:body];
                } else if(change.type == MODIFIED && [change.varName isEqualToString:@"excused"] && ((Absence*)change.current).excused){
                    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
                    NSString* body = [NSString stringWithFormat:@"%@%@ (%@)", [formatter stringFromDate:((Absence*)change.current).startDate], (((Absence*)change.current).startDate.timeIntervalSince1970 != ((Absence*)change.current).endDate.timeIntervalSince1970 ? [NSString stringWithFormat:@" - %@", [formatter stringFromDate:((Absence*)change.current).endDate]] : @""), [NSString stringWithFormat:@"%@ %@", [NSNumber numberWithInt:((Absence*)change.current).lessonCount].stringValue, (((Absence*)change.current).lessonCount != 1 ? NSLocalizedString(@"lessons", @"") : NSLocalizedString(@"lesson", @""))]];
                    [self sendNotificationWithTitle:NSLocalizedString(@"excusedAbsence", @"") withContent:body];
                }
            } else if(c == [Transaction class]){
                if(change.type == ADDED){
                    [self sendNotificationWithTitle:NSLocalizedString(@"newTransaction", @"") withContent:[NSString stringWithFormat:@"%@ -> %.2f", ((Transaction*)change.current).reason, ((Transaction*)change.current).amount]];
                }
            }
        }
    }
    
    completionHandler(UIBackgroundFetchResultNewData);
}

-(void) sendNotificationWithTitle: (NSString*) title withContent: (NSString*) content{
    if([Util notifcationsAllowed]){
        UNMutableNotificationContent* notificationContent = [[UNMutableNotificationContent alloc] init];
        notificationContent.title = title;
        notificationContent.body = content;
        notificationContent.categoryIdentifier = @"GENERAL";
        if([Util soundsAllowed]) notificationContent.sound = [UNNotificationSound defaultSound];

        UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:0.001 repeats:NO];
        
        UNNotificationRequest* request = [UNNotificationRequest
               requestWithIdentifier:[[NSProcessInfo processInfo] globallyUniqueString] content:notificationContent trigger:trigger];
        
        UNUserNotificationCenter* center = [UNUserNotificationCenter currentNotificationCenter];
        [center addNotificationRequest:request withCompletionHandler:^(NSError* error) {
           
        }];
    }
}

@end
