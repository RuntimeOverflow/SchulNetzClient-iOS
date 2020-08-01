#import "MainViewController.h"
#import "RefreshViewController.h"
#import "../Util.h"
#import "../Account.h"
#import "../Data/Host.h"
#import "../Variables.h"

@interface MainViewController ()

@end

@implementation MainViewController
static MainViewController* main;

+(MainViewController*) get{
    return main;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    
    main = self;
    
    [[NSUserDefaults standardUserDefaults] setObject:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"] forKey:@"appVersion"];
    
    if(![[NSUserDefaults standardUserDefaults] boolForKey:@"loggedIn"]){
        [Util setViewControllerFromName:@"LoginScene" animated:false];
    } else if([Variables get].account == NULL){
        [Variables get].account = [[Account alloc] initFromCredentials];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [[Variables get].account signIn];
        });
        
        User* user = [User load];
        if(user != nil) [Variables get].user = user;
        [user processConnections];
        
        [Util setTintColor:[Host colorForHost:[Variables get].account.host]];
    }
}
@end
