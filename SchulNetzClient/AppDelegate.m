#import "AppDelegate.h"
#import <BackgroundTasks/BackgroundTasks.h>
#import "Util.h"
#import "Account.h"
#import "Variables.h"

@implementation AppDelegate
@synthesize window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    /*[[BGTaskScheduler sharedScheduler] registerForTaskWithIdentifier:@"com.runtimeoverflow.SchulNetzClient.refresh" usingQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) launchHandler:^(BGTask *task) {
        [self handleBackgroundRefresh:task];
    }];*/
    
    UNNotificationCategory* generalCategory = [UNNotificationCategory
         categoryWithIdentifier:@"GENERAL"
         actions:@[]
         intentIdentifiers:@[]
         options:UNNotificationCategoryOptionCustomDismissAction];
     
    UNUserNotificationCenter* center = [UNUserNotificationCenter currentNotificationCenter];
    [center setNotificationCategories:[NSSet setWithObjects:generalCategory, nil]];
    center.delegate = self;
    
    return YES;
}

- (void)userNotificationCenter:(UNUserNotificationCenter* )center willPresentNotification:(UNNotification* )notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler {

    completionHandler(UNNotificationPresentationOptionAlert);
}

- (void)applicationDidBecomeActive:(UIApplication *)application{
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    
    if([Variables get].account != NULL && ![Variables get].account.signedIn){
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [[Variables get].account signIn];
        });
    }
}

- (void)applicationWillResignActive:(UIApplication *)application{
    [self scheduleBackgroundRefresh];
    
    if([Variables get].account != NULL && [Variables get].account.signedIn){
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [[Variables get].account signOut];
        });
    }
}

-(void) scheduleBackgroundRefresh{
    /*BGAppRefreshTaskRequest *request = [[BGAppRefreshTaskRequest alloc] initWithIdentifier:@"com.runtimeoverflow.SchulNetzClient.refresh"];
    if(request.earliestBeginDate == NULL) request.earliestBeginDate = [NSDate dateWithTimeIntervalSinceNow:30];
    
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"loggedIn"]) [[BGTaskScheduler sharedScheduler] submitTaskRequest:request error:NULL];*/
}

/*-(void) handleBackgroundRefresh: (BGTask*) task{
    [self scheduleBackgroundRefresh];
    
    NSOperationQueue* queue = [[NSOperationQueue alloc] init];
    queue.maxConcurrentOperationCount = 1;
    
    NSBlockOperation* operation = [NSBlockOperation blockOperationWithBlock:^(void){
        [self backgroundRefresh];
    }];
    [queue addOperation: operation];
    
    queue.operations.lastObject.completionBlock = ^(void){
        [task setTaskCompletedWithSuccess:true];
    };
    
    task.expirationHandler = ^(void){
        [queue cancelAllOperations];
    };
}

//e -l objc -- (void)[[BGTaskScheduler sharedScheduler] _simulateLaunchForTaskWithIdentifier:@"com.runtimeoverflow.SchulNetzClient.refresh"]
-(void) backgroundRefresh{
    if(![[NSUserDefaults standardUserDefaults] boolForKey:@"loggedIn"]) return;
    Account* account = [[Account alloc] initFromCredentials];
    
    [self sendNotificationWithTitle:@"Synchronizing" withContent:@"Fetching new data"];
    
    [account refresh:NULL];
    [account.user save];
    
    [self sendNotificationWithTitle:@"Synchronized" withContent:@"Successfully fetched new data"];
}*/

-(void) sendNotificationWithTitle: (NSString*) title withContent: (NSString*) content{
    if([Util notifcationsAllowed]){
        UNMutableNotificationContent* notificationContent = [[UNMutableNotificationContent alloc] init];
        notificationContent.title = [NSString localizedUserNotificationStringForKey:title arguments:nil];
        notificationContent.body = [NSString localizedUserNotificationStringForKey:content arguments:nil];
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
