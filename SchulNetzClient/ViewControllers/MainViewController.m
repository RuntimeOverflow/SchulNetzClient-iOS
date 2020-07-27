#import "MainViewController.h"
#import "RefreshViewController.h"
#import "../Util.h"
#import "../Account.h"
#import "../Data/Host.h"

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
    } else if([Account getCurrent] == NULL){
        Account* account __attribute__((unused)) = [[Account alloc] initFromCredentials];
        User* user = [User initFromCache];
        if(user != nil) account.user = user;
        [user afterInit];
        [Util setTintColor: [Host colorForHost:account.url]];
    }
}
@end
