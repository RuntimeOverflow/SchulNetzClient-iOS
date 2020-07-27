#import "VerificationViewController.h"
#import "LoginViewController.h"
#import "../Account.h"
#import "../Util.h"
#import "../Data/Host.h"

@interface PickerTextField : UITextField

@end

@implementation PickerTextField
-(CGRect) caretRectForPosition:(UITextPosition*) position{
    return CGRectZero;
}

-(BOOL)canPerformAction:(SEL)action withSender:(id)sender{
    if(action == @selector(paste:) || action == @selector(cut:)) return false;
    else return [super canPerformAction:action withSender:sender];
}
@end

@interface LoginViewController() <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UILabel *errorLabel;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UITextField *urlField;
@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UITextField *urlPickerField;
@end

@implementation LoginViewController
BOOL otherHost = false;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _urlField.hidden = true;
    _urlField.enabled = false;
    
    _urlField.delegate = self;
    _usernameField.delegate = self;
    _passwordField.delegate = self;
    
    _loginButton.backgroundColor = [Util getDisabledTintColor];
    
    UIPickerView* picker = [[UIPickerView alloc] init];
    picker.delegate = self;
    picker.dataSource = self;
    _urlPickerField.inputView = picker;
}

- (IBAction)loginButtonPressed:(id)sender {
    VerificationViewController* vc = (VerificationViewController*)[Util setViewControllerFromName:@"VerificationScene"];
    
    Account* account = [[Account alloc]initWithUsername:_usernameField.text password: _passwordField.text host:otherHost ? _urlField.text : _urlPickerField.text];
    
    [vc setAccount:account];
}

-(void)setErrorMessage:(NSString *)message withError:(int)error{
    [self setErrorMessage:[NSString stringWithFormat:@"%@ (NSURLError %d)", message, error]];
}

-(void)setErrorMessage:(NSString *)message{
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
    if(row == [Host getHosts].count) return @"Other...";
    else return [[Host getHosts] objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    
    [_urlPickerField resignFirstResponder];
    if(row == [Host getHosts].count && !otherHost){
        _urlField.hidden = false;
        _urlField.enabled = true;
        
        CGRect selectBounds = _urlPickerField.frame;
        CGRect urlBounds = _urlField.frame;
        
        _urlPickerField.frame = urlBounds;
        _urlField.frame = selectBounds;
        
        _urlPickerField.text = @"Other...";
        otherHost = true;
    } else if(row != [Host getHosts].count){
        if(otherHost){
            _urlField.hidden = true;
            _urlField.enabled = false;
            
            CGRect selectBounds = _urlPickerField.frame;
            CGRect urlBounds = _urlField.frame;
            
            _urlPickerField.frame = urlBounds;
            _urlField.frame = selectBounds;
        }
        
        otherHost = false;
        _urlPickerField.text = [[Host getHosts] objectAtIndex:row];
        
        [_usernameField becomeFirstResponder];
    }
    
    [self inputChanged:_urlPickerField];
    
    if(otherHost) [_urlField becomeFirstResponder];
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
