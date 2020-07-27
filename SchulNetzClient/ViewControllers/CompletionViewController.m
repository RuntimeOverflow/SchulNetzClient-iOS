#import "CompletionViewController.h"
#import "RefreshViewController.h"
#import "../Util.h"
#import "../Account.h"
#import <UserNotifications/UserNotifications.h>

@interface CompletionViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *checkmarkImage;
@property (weak, nonatomic) IBOutlet UIButton *exitButton;
@property (weak, nonatomic) IBOutlet UIPageControl *pageIndicator;
@end

@implementation CompletionViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    
    _checkmarkImage.tintColor = [Util getTintColor];
    _exitButton.backgroundColor = [Util getTintColor];
    _pageIndicator.currentPageIndicatorTintColor = [Util getTintColor];
    
    UNUserNotificationCenter* center = [UNUserNotificationCenter currentNotificationCenter];
    [center requestAuthorizationWithOptions:(UNAuthorizationOptionAlert + UNAuthorizationOptionSound + UNAuthorizationOptionBadge)
       completionHandler:^(BOOL granted, NSError * _Nullable error) {
          
    }];
}

-(IBAction)exitButtonPressed:(id)sender {
    [Util setViewControllerFromName:@"RefreshScene"];
}
@end
