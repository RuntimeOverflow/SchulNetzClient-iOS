#import "SettingsViewController.h"
#import "../Util.h"

@interface SettingsViewController ()
@property (weak, nonatomic) IBOutlet UIButton *logoutButton;
@property (weak, nonatomic) IBOutlet UIButton *refreshButton;
@property (weak, nonatomic) IBOutlet UILabel *refreshLabel;
@end

@implementation SettingsViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"hh:mm";
    formatter.locale = [NSLocale currentLocale];
    _refreshLabel.text = [formatter stringFromDate: [[NSUserDefaults standardUserDefaults] objectForKey:@"lastRefresh"]];
    _logoutButton.tintColor = [Util getTintColor];
    _refreshButton.tintColor = [Util getTintColor];
}

- (IBAction)logoutPressed:(id)sender {
    [[NSUserDefaults standardUserDefaults] setBool:false forKey:@"loggedIn"];
    exit(0);
}

-(IBAction)refreshPressed:(id)sender {
    [Util setViewControllerFromName:@"RefreshScene"];
}
@end
