#import "NavigationViewController.h"
#import "../Util.h"

@interface NavigationViewController ()
@property (weak, nonatomic) IBOutlet UITabBar *tabBar;
@end

@implementation NavigationViewController
@synthesize tabBar;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    tabBar.tintColor = [Util getTintColor];
    
    self.selectedIndex = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"startPage"];
}
@end
