#import "StartViewController.h"
#import "../Util.h"
#import "../Account.h"
#import "../Data/Data.h"

@interface StartViewController ()
@property (weak, nonatomic) IBOutlet UIButton *refreshButton;
@property (weak, nonatomic) IBOutlet UIButton *logoutButton;
@property (weak, nonatomic) IBOutlet UIButton *saveCacheButton;
@property (weak, nonatomic) IBOutlet UIButton *loadCacheButton;
@property (weak, nonatomic) IBOutlet UIButton *subjectsButton;
@end

@implementation StartViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    _refreshButton.backgroundColor = [Util getTintColor];
    _logoutButton.backgroundColor = [Util getTintColor];
    _saveCacheButton.backgroundColor = [Util getTintColor];
    _loadCacheButton.backgroundColor = [Util getTintColor];
    _subjectsButton.backgroundColor = [Util getTintColor];
}

- (IBAction)refreshPressed:(id)sender {
    [Util setViewControllerFromName:@"RefreshScene"];
}

- (IBAction)logoutPressed:(id)sender {
    [[NSUserDefaults standardUserDefaults] setBool:false forKey:@"loggedIn"];
    
    NSDictionary* credentials = [[NSURLCredentialStorage sharedCredentialStorage] credentialsForProtectionSpace:[Util getProtectionSpace]];
    NSURLCredential* credential = [credentials.objectEnumerator nextObject];
    [[NSURLCredentialStorage sharedCredentialStorage] removeCredential:credential forProtectionSpace:[Util getProtectionSpace]];
    
    [Util setViewControllerFromName:@"LaunchScene"];
}

- (IBAction)saveCachePressed:(id)sender {
    [[Account getCurrent].user cacheData];
}

- (IBAction)loadCachePressed:(id)sender {
    [Account getCurrent].user = [User initFromCache];
}

- (IBAction)subjectsPressed:(id)sender {
    [Util setViewControllerFromName:@"MainScene"];
}
@end
