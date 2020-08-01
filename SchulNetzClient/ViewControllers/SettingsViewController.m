#import "SettingsViewController.h"
#import "../Util.h"
#import "../Account.h"
#import "../Parser.h"
#import "../Variables.h"
#import "../Data/User.h"
#import "../Data/Host.h"

@interface SettingsViewController ()
@property (weak, nonatomic) IBOutlet UIButton *logoutButton;
@property (weak, nonatomic) IBOutlet UIButton *refreshButton;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *classLabel;
@property (weak, nonatomic) IBOutlet UIView *transactionsCell;
@end

@implementation SettingsViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    _refreshButton.backgroundColor = [Util getTintColor];
    _logoutButton.backgroundColor = [Util getTintColor];
    
    if([Variables get].user && [Variables get].user.me){
        _nameLabel.text = [NSString stringWithFormat:@"%@ %@", [Variables get].user.me.firstName, [Variables get].user.me.lastName];
        _classLabel.text = [Variables get].user.me.className;
    } else{
        _nameLabel.text = [[Variables get].account.username stringByReplacingOccurrencesOfString:@"." withString:@" "].uppercaseString;
        _classLabel.hidden = true;
    }
    
    CALayer* transactionsTopBorder = [CALayer layer];
    transactionsTopBorder.frame = CGRectMake(0.0f, 0.0f, _transactionsCell.frame.size.width, 1.0f);
    transactionsTopBorder.backgroundColor = [UIColor colorWithWhite:0.8f alpha:1.0f].CGColor;
    [_transactionsCell.layer addSublayer:transactionsTopBorder];
    
    CALayer* transactionsBottomBorder = [CALayer layer];
    transactionsBottomBorder.frame = CGRectMake(0.0f, _transactionsCell.frame.size.height - 1, _transactionsCell.frame.size.width, 1.0f);
    transactionsBottomBorder.backgroundColor = [UIColor colorWithWhite:0.8f alpha:1.0f].CGColor;
    [_transactionsCell.layer addSublayer:transactionsBottomBorder];
    
    UITapGestureRecognizer* transactionsRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(transactionsPressed:)];
    [transactionsRecognizer setDelegate:self];
    [_transactionsCell addGestureRecognizer:transactionsRecognizer];
}

- (IBAction)logoutPressed:(id)sender {
    UIAlertController* controller = [UIAlertController alertControllerWithTitle:@"Sign out" message:@"Are you sure?" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* positive = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[NSUserDefaults standardUserDefaults] setBool:false forKey:@"loggedIn"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"cacheData"];
        [Util setTintColor:[Host colorForHost:@""]];
        [Util setViewControllerFromName:@"LoginScene"];
    }];
    [controller addAction:positive];
    UIAlertAction* negative = [UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleCancel handler:NULL];
    [controller addAction:negative];
    
    [self presentViewController:controller animated:true completion:NULL];
}

-(IBAction)refreshPressed:(id)sender{
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"loggedIn"]){
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            Account* account = [[Account alloc] initFromCredentials:false];
            User* user = [[User alloc] init];
            
            BOOL res = false;
            
            [account signIn];
            NSObject* doc = [account loadPage:@"22352"];
            if([doc class] == [HTMLDocument class]) res = [Parser parseTeachers:(HTMLDocument*)doc forUser:user];
            NSLog(@"%d", (int)res);
            doc = [account loadPage:@"22326"];
            if([doc class] == [HTMLDocument class]) res = [Parser parseSubjects:(HTMLDocument*)doc forUser:user];
            NSLog(@"%d", (int)res);
            if([doc class] == [HTMLDocument class]) res = [Parser parseStudents:(HTMLDocument*)doc forUser:user];
            NSLog(@"%d", (int)res);
            doc = [account loadPage:@"21311"];
            if([doc class] == [HTMLDocument class]) res = [Parser parseGrades:(HTMLDocument*)doc forUser:user];
            NSLog(@"%d", (int)res);
            doc = [account loadPage:@"21411"];
            if([doc class] == [HTMLDocument class]) res = [Parser parseSelf:(HTMLDocument*)doc forUser:user];
            NSLog(@"%d", (int)res);
            if([doc class] == [HTMLDocument class]) res = [Parser parseTransactions:(HTMLDocument*)doc forUser:user];
            NSLog(@"%d", (int)res);
            doc = [account loadPage:@"21111"];
            if([doc class] == [HTMLDocument class]) res = [Parser parseAbsences:(HTMLDocument*)doc forUser:user];
            NSLog(@"%d", (int)res);
            doc = [account loadPage:@"22202"];
            if([doc class] == [HTMLDocument class]) res = [Parser parseSchedulePage:(HTMLDocument*)doc forUser:user];
            NSLog(@"%d", (int)res);
            
            [user processConnections];
            [account signOut];
            
            [Variables get].user = user;
            [user save];
            
            NSLog(@"Done");
        });
    }
}

-(void)transactionsPressed:(UITapGestureRecognizer*)recognizer{
    
}
@end
