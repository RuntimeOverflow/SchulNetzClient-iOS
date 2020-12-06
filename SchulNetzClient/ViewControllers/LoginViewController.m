#import "LoginViewController.h"
#import <UserNotifications/UserNotifications.h>
#import "../Account.h"
#import "../Util.h"
#import "../Data/Host.h"
#import "../Data/User.h"
#import "../Parser.h"
#import "../Variables.h"

@interface LoginViewController() <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UILabel *errorLabel;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UITextField *urlField;
@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UITextField *urlPickerField;
@property (weak, nonatomic) IBOutlet UIView *signinContainer;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *verifyingIcon;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingIcon;
@end

@implementation LoginViewController
BOOL otherHost = false;

NSLayoutConstraint* yUrlField;
NSLayoutConstraint* heightUrlField;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [Util setTintColor:[Host colorForHost:@""]];
    
    UIColor* separatorColor = [UIColor colorWithRed:0.235 green:0.235 blue:0.263 alpha:0.25];
    
    yUrlField = [_urlField.topAnchor constraintEqualToAnchor:_urlPickerField.bottomAnchor constant:0];
    yUrlField.active = true;
    heightUrlField = [_urlField.heightAnchor constraintEqualToConstant:0];
    heightUrlField.active = true;
    
    _urlField.hidden = true;
    _urlField.enabled = false;
    
    _urlField.delegate = self;
    _usernameField.delegate = self;
    _passwordField.delegate = self;
    
    _loginButton.backgroundColor = [Util getDisabledTintColor];
    
    _verifyingIcon.color = [Util getTintColor];
    _verifyingIcon.hidden = true;
    
    _loadingIcon.color = [Util getTintColor];
    _loadingIcon.hidden = true;
    
    UIPickerView* picker = [[UIPickerView alloc] init];
    picker.backgroundColor = UIColor.groupTableViewBackgroundColor;
    picker.delegate = self;
    picker.dataSource = self;
    
    UIButton* button = [[UIButton alloc] init];
    button.backgroundColor = UIColor.clearColor;
    [button setTitle:NSLocalizedString(@"done", @"") forState:UIControlStateNormal];
    [button setTitleColor:[UIColor colorWithRed:0.0/255.0 green:122.0/255.0 blue:255.0/255.0 alpha:1] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor colorWithRed:0.0/255.0 green:122.0/255.0 blue:255.0/255.0 alpha:0.5] forState:UIControlStateHighlighted];
    [button addTarget:self action:@selector(pickerClosed) forControlEvents:UIControlEventPrimaryActionTriggered];
    
    UIView* inputView = [[UIView alloc] init];
    inputView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    inputView.backgroundColor = UIColor.whiteColor;
    [inputView addSubview:button];
    [inputView addSubview:picker];
    
    UIView* border = [[UIView alloc] init];
    border.backgroundColor = separatorColor;
    [inputView addSubview:border];
    border.translatesAutoresizingMaskIntoConstraints = false;
    [border.topAnchor constraintEqualToAnchor:inputView.topAnchor].active = true;
    [border.rightAnchor constraintEqualToAnchor:inputView.rightAnchor].active = true;
    [border.leftAnchor constraintEqualToAnchor:inputView.leftAnchor].active = true;
    [border.heightAnchor constraintEqualToConstant:0.5].active = true;
    
    border = [[UIView alloc] init];
    border.backgroundColor = separatorColor;
    [inputView addSubview:border];
    border.translatesAutoresizingMaskIntoConstraints = false;
    [border.topAnchor constraintEqualToAnchor:picker.topAnchor].active = true;
    [border.rightAnchor constraintEqualToAnchor:inputView.rightAnchor].active = true;
    [border.leftAnchor constraintEqualToAnchor:inputView.leftAnchor].active = true;
    [border.heightAnchor constraintEqualToConstant:0.5].active = true;
    
    button.translatesAutoresizingMaskIntoConstraints = false;
    [button.topAnchor constraintEqualToAnchor:inputView.topAnchor].active = true;
    [button.rightAnchor constraintEqualToAnchor:inputView.rightAnchor].active = true;
    [button.heightAnchor constraintEqualToConstant:button.intrinsicContentSize.height + 16].active = true;
    [button.widthAnchor constraintEqualToConstant:button.intrinsicContentSize.width + 16].active = true;
    
    picker.translatesAutoresizingMaskIntoConstraints = false;
    [picker.topAnchor constraintEqualToAnchor:button.bottomAnchor].active = true;
    [picker.rightAnchor constraintEqualToAnchor:inputView.rightAnchor].active = true;
    [picker.bottomAnchor constraintEqualToAnchor:inputView.bottomAnchor].active = true;
    [picker.leftAnchor constraintEqualToAnchor:inputView.leftAnchor].active = true;
    
    _urlPickerField.inputView = inputView;
}

- (IBAction)loginButtonPressed:(id)sender {
    _urlPickerField.enabled = false;
    _urlField.enabled = false;
    _usernameField.enabled = false;
    _passwordField.enabled = false;
    _loginButton.hidden = true;
    _errorLabel.hidden = true;
    
    _verifyingIcon.hidden = false;
    [_verifyingIcon startAnimating];
    
    Account* account = [[Account alloc]initWithUsername:self->_usernameField.text password: self->_passwordField.text host:(otherHost ? self->_urlField.text : self->_urlPickerField.text) session:false];
   
    NSObject* result = [account signIn];
    if([[result class] isSubclassOfClass:[NSNumber class]] && ((NSNumber*)result).boolValue){
        dispatch_async(dispatch_get_main_queue(), ^{
            self->_signinContainer.hidden = true;
            self->_loadingIcon.hidden = false;
            [self->_loadingIcon startAnimating];
        });
        
        [account saveCredentials];
        
        User* user = [[User alloc] init];
        
        [account loadPage:@"22352" completion:^(NSObject *doc) {
            if([doc class] == [HTMLDocument class]) [Parser parseTeachers:(HTMLDocument*)doc forUser:user];
        }];
        [account loadPage:@"22348" completion:^(NSObject *doc) {
            if([doc class] == [HTMLDocument class]) [Parser parseSubjects:(HTMLDocument*)doc forUser:user];
            if([doc class] == [HTMLDocument class]) [Parser parseStudents:(HTMLDocument*)doc forUser:user];
        }];
        [account loadPage:@"21311" completion:^(NSObject *doc) {
            if([doc class] == [HTMLDocument class]) [Parser parseGrades:(HTMLDocument*)doc forUser:user];
        }];
        [account loadPage:@"21411" completion:^(NSObject *doc) {
            if([doc class] == [HTMLDocument class]) [Parser parseSelf:(HTMLDocument*)doc forUser:user];
            if([doc class] == [HTMLDocument class]) [Parser parseTransactions:(HTMLDocument*)doc forUser:user];
        }];
        [account loadPage:@"21111" completion:^(NSObject *doc) {
            if([doc class] == [HTMLDocument class]) [Parser parseAbsences:(HTMLDocument*)doc forUser:user];
        }];
        [account loadPage:@"22202" completion:^(NSObject *doc) {
            if([doc class] == [HTMLDocument class]) [Parser parseSchedulePage:(HTMLDocument*)doc forUser:user];
        }];
        
        [account loadScheduleFrom:[NSDate date] to:[NSDate date] completion:^(NSObject *doc) {
            if([doc class] == [HTMLDocument class]) user.lessons = [Parser parseSchedule:(HTMLDocument*)doc];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                [account signOut];
                [account close];
            });
            
            [user processConnections];
            [Variables get].user = user;
            [user save];
            
            [UNUserNotificationCenter.currentNotificationCenter requestAuthorizationWithOptions:UNAuthorizationOptionAlert | UNAuthorizationOptionSound | UNAuthorizationOptionBadge completionHandler:^(BOOL granted, NSError * _Nullable error){}];
            
            UIViewController* vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"MainScene"];
            vc.modalPresentationStyle = UIModalPresentationFullScreen;
            [[Util getMainController] presentViewController:vc animated:true completion:nil];
        }];
        
    } else{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            [account close];
        });
        
        if([result class] != [NSError class] && [result class] != [NSException class]) self->_errorLabel.text = NSLocalizedString(@"invalidCreds", @"");
        else if([result class] == [NSError class]) self->_errorLabel.text = ((NSError*)result).localizedDescription;
        else if([result class] == [NSException class]) self->_errorLabel.text = ((NSException*)result).reason;
        
        self->_errorLabel.hidden = false;
        
        self->_urlPickerField.enabled = true;
        self->_urlField.enabled = true;
        self->_usernameField.enabled = true;
        self->_passwordField.enabled = true;
        self->_loginButton.hidden = false;
        
        self->_verifyingIcon.hidden = true;
        [self->_verifyingIcon stopAnimating];
    }
}

-(void)setErrorMessage:(NSString*)message withError:(NSError*)error{
    [self setErrorMessage:[NSString stringWithFormat:@"%@ (NSURLError %ld)", message, (long)error.code]];
}

-(void)setErrorMessage:(NSString*)message{
    _errorLabel.hidden = false;
    _errorLabel.text = message;
}

- (IBAction)inputChanged:(id)sender {
    if(!otherHost) [Util setTintColor:[Host colorForHost:_urlPickerField.text]];
    else [Util setTintColor:[Host colorForHost:_urlField.text]];
    
    if([_usernameField.text length] > 0 && [_passwordField.text length] > 0 && [_urlPickerField.text length] > 0 && (!otherHost || [_urlField.text length] > 0)){
        _loginButton.backgroundColor = [Util getTintColor];
        _loginButton.enabled = true;
    } else {
        _loginButton.backgroundColor = [Util getDisabledTintColor];
        _loginButton.enabled = false;
    }
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    if([_urlPickerField.text isEqualToString:@""]) {
        _urlPickerField.text = [[Host getHosts] objectAtIndex:0];
        [self inputChanged:_urlPickerField];
    }
    
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return [Host getHosts].count + 1;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    if(row == [Host getHosts].count) return NSLocalizedString(@"other", @"");
    else return [[Host getHosts] objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    
    if(row == [Host getHosts].count && !otherHost){
        _urlField.hidden = false;
        _urlField.enabled = true;
        
        yUrlField.active = false;
        yUrlField = [_urlField.topAnchor constraintEqualToAnchor:_urlPickerField.bottomAnchor constant:8];
        yUrlField.active = true;
        heightUrlField.active = false;
        heightUrlField = [_urlField.heightAnchor constraintGreaterThanOrEqualToConstant:0];
        heightUrlField.active = true;
        
        _urlPickerField.text = @"Other...";
        otherHost = true;
    } else if(row != [Host getHosts].count){
        if(otherHost){
            _urlField.hidden = true;
            _urlField.enabled = false;
            
            yUrlField.active = false;
            yUrlField = [_urlField.topAnchor constraintEqualToAnchor:_urlPickerField.bottomAnchor constant:0];
            yUrlField.active = true;
            heightUrlField.active = false;
            heightUrlField = [_urlField.heightAnchor constraintEqualToConstant:0];
            heightUrlField.active = true;
        }
        
        otherHost = false;
        _urlPickerField.text = [[Host getHosts] objectAtIndex:row];
    }
    
    [self inputChanged:_urlPickerField];
}

-(void)pickerClosed{
    [_urlPickerField resignFirstResponder];
    if(otherHost) [_urlField becomeFirstResponder];
    else [_usernameField becomeFirstResponder];
}

-(BOOL)textFieldShouldReturn:(UITextField*)textField
{
    [textField resignFirstResponder];
    if(textField == _urlField){
        [_usernameField becomeFirstResponder];
    } else if(textField == _usernameField){
        [_passwordField becomeFirstResponder];
    }
    
    return YES;
}
@end
