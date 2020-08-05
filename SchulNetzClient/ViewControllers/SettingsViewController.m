#import "SettingsViewController.h"
#import "../Util.h"
#import "../Account.h"
#import "../Parser.h"
#import "../Variables.h"
#import "../Data/User.h"
#import "../Data/Host.h"

@interface SettingsViewController ()
@property (weak, nonatomic) IBOutlet UIButton *logoutButton;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *classLabel;
@property (weak, nonatomic) IBOutlet UIView *transactionsCell;
@property (weak, nonatomic) IBOutlet UIView *startPageCell;
@property (weak, nonatomic) IBOutlet UITextField *startPagePickerField;
@property (weak, nonatomic) IBOutlet UIView *notificationsCell;
@property (weak, nonatomic) IBOutlet UISwitch *notificationsSwitch;
@property (weak, nonatomic) IBOutlet UIView *sourceCodeCell;
@end

@implementation SettingsViewController
NSArray<NSString*>* startPages = NULL;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _logoutButton.backgroundColor = [Util getTintColor];
    
    CALayer* transactionsTopBorder = [CALayer layer];
    transactionsTopBorder.frame = CGRectMake(0.0f, 0.0f, _transactionsCell.frame.size.width, 1.0f);
    transactionsTopBorder.backgroundColor = [UIColor systemGrayColor].CGColor;
    [_transactionsCell.layer addSublayer:transactionsTopBorder];
    
    CALayer* transactionsBottomBorder = [CALayer layer];
    transactionsBottomBorder.frame = CGRectMake(0.0f, _transactionsCell.frame.size.height - 1, _transactionsCell.frame.size.width, 1.0f);
    transactionsBottomBorder.backgroundColor = [UIColor systemGrayColor].CGColor;
    [_transactionsCell.layer addSublayer:transactionsBottomBorder];
    
    CALayer* startPageTopBorder = [CALayer layer];
    startPageTopBorder.frame = CGRectMake(0.0f, 0.0f, _startPageCell.frame.size.width, 1.0f);
    startPageTopBorder.backgroundColor = [UIColor systemGrayColor].CGColor;
    [_startPageCell.layer addSublayer:startPageTopBorder];
    
    CALayer* startPageBottomBorder = [CALayer layer];
    startPageBottomBorder.frame = CGRectMake(0.0f, _startPageCell.frame.size.height - 1, _startPageCell.frame.size.width, 1.0f);
    startPageBottomBorder.backgroundColor = [UIColor systemGrayColor].CGColor;
    [_startPageCell.layer addSublayer:startPageBottomBorder];
    
    startPages = @[NSLocalizedString(@"grades", @""), NSLocalizedString(@"absences", @""), NSLocalizedString(@"timetable", @""), NSLocalizedString(@"people", @""), NSLocalizedString(@"settings", @"")];
    int index = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"startPage"];
    
    UIPickerView* picker = [[UIPickerView alloc] init];
    picker.delegate = self;
    picker.dataSource = self;
    _startPagePickerField.inputView = picker;
    
    [picker reloadAllComponents];
    [picker selectRow:index inComponent:0 animated:true];
    _startPagePickerField.text = startPages[index];
    
    CALayer* notificationsTopBorder = [CALayer layer];
    notificationsTopBorder.frame = CGRectMake(0.0f, 0.0f, _notificationsCell.frame.size.width, 1.0f);
    notificationsTopBorder.backgroundColor = [UIColor systemGrayColor].CGColor;
    [_notificationsCell.layer addSublayer:notificationsTopBorder];
    
    CALayer* notificationsBottomBorder = [CALayer layer];
    notificationsBottomBorder.frame = CGRectMake(0.0f, _notificationsCell.frame.size.height - 1, _notificationsCell.frame.size.width, 1.0f);
    notificationsBottomBorder.backgroundColor = [UIColor systemGrayColor].CGColor;
    [_notificationsCell.layer addSublayer:notificationsBottomBorder];
    
    if([NSUserDefaults standardUserDefaults].dictionaryRepresentation[@"notificationsEnabled"]) {
        _notificationsSwitch.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"notificationsEnabled"];
    } else{
        _notificationsSwitch.on = true;
    }
    
    CALayer* sourceCodeTopBorder = [CALayer layer];
    sourceCodeTopBorder.frame = CGRectMake(0.0f, 0.0f, _sourceCodeCell.frame.size.width, 1.0f);
    sourceCodeTopBorder.backgroundColor = [UIColor systemGrayColor].CGColor;
    [_sourceCodeCell.layer addSublayer:sourceCodeTopBorder];
    
    CALayer* sourceCodeBottomBorder = [CALayer layer];
    sourceCodeBottomBorder.frame = CGRectMake(0.0f, _sourceCodeCell.frame.size.height - 1, _sourceCodeCell.frame.size.width, 1.0f);
    sourceCodeBottomBorder.backgroundColor = [UIColor systemGrayColor].CGColor;
    [_sourceCodeCell.layer addSublayer:sourceCodeBottomBorder];
    
    [self reload];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        if([Util checkConnection]){
            [[Variables get].account loadPage:@"21411" completion:^(NSObject *doc) {
                if([doc class] == [HTMLDocument class]) [Parser parseSelf:(HTMLDocument*)doc forUser:[Variables get].user];
                if([doc class] == [HTMLDocument class]) [Parser parseTransactions:(HTMLDocument*)doc forUser:[Variables get].user];
                [[Variables get].user processConnections];
                [self reload];
            }];
        }
    //});
}

-(void)reload{
    if([Variables get].user && [Variables get].user.me){
        _nameLabel.text = [NSString stringWithFormat:@"%@ %@", [Variables get].user.me.firstName, [Variables get].user.me.lastName];
        _classLabel.text = [Variables get].user.me.className;
        _classLabel.hidden = false;
    } else{
        _nameLabel.text = [[Variables get].account.username stringByReplacingOccurrencesOfString:@"." withString:@" "].uppercaseString;
        _classLabel.hidden = true;
    }
}

- (IBAction)logoutPressed:(id)sender {
    UIAlertController* controller = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"signout", @"") message:NSLocalizedString(@"signoutConfirmation", @"") preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* positive = [UIAlertAction actionWithTitle:NSLocalizedString(@"yes", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[NSUserDefaults standardUserDefaults] setBool:false forKey:@"loggedIn"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"cacheData"];
        [[Variables get].account close];
        [Variables get].account = NULL;
        [Util setTintColor:[Host colorForHost:@""]];
        [Util setViewControllerFromName:@"LoginScene"];
    }];
    [controller addAction:positive];
    UIAlertAction* negative = [UIAlertAction actionWithTitle:NSLocalizedString(@"no", @"") style:UIAlertActionStyleCancel handler:NULL];
    [controller addAction:negative];
    
    [self presentViewController:controller animated:true completion:NULL];
}

- (IBAction)notificationsChanged:(id)sender{
    [[NSUserDefaults standardUserDefaults] setBool:_notificationsSwitch.on forKey:@"notificationsEnabled"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (IBAction)sourceCodePressed:(id)sender{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://github.com/RuntimeOverflow/SchulNetz-Client-iOS"] options:[[NSDictionary alloc] init] completionHandler:NULL];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return 5;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    
    return startPages[row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    
    [_startPagePickerField resignFirstResponder];
    
    _startPagePickerField.text = startPages[row];
    [[NSUserDefaults standardUserDefaults] setInteger:row forKey:@"startPage"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [super viewWillDisappear:animated];
}
@end
