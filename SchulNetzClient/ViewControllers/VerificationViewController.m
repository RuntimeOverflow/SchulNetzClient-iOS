#import "VerificationViewController.h"
#import "LoginViewController.h"
#import "../Util.h"
#import "../Account.h"

@interface VerificationViewController()
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;
@property (weak, nonatomic) IBOutlet UIPageControl *pageIndicator;
@end

@implementation VerificationViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    _loadingIndicator.color = [Util getTintColor];
    _pageIndicator.currentPageIndicatorTintColor = [Util getTintColor];
}

-(void) setAccount: (Account*) account{
    //int result = [account verify];
    int result = 1;
    
    if(result == 0){
        [account saveCredentials];
        [Util setViewControllerFromName:@"CompletionScene"];
    } else {
        [[Util getMainController] popViewControllerAnimated:true];
        
        LoginViewController* controller;
        for(UIViewController* vc in [Util getMainController].viewControllers){
            if([vc class] == [LoginViewController class]){
                controller = (LoginViewController*) vc;
                break;
            }
        }
        
        if(controller != NULL){
            if(result == 1337) [controller setErrorMessage:@"Invalid username/password"];
            else if(result == NSURLErrorBadURL || result == NSURLErrorCannotFindHost || result == NSURLErrorFileDoesNotExist || result == NSURLErrorUnsupportedURL) [controller setErrorMessage:@"Invalid host" withError: result];
            else if(result == NSURLErrorCannotConnectToHost) [controller setErrorMessage:@"Can't connect to host" withError: result];
            else if(result == NSURLErrorNetworkConnectionLost || result == NSURLErrorNotConnectedToInternet) [controller setErrorMessage:@"No internet connection" withError: result];
            else if(result == NSURLErrorTimedOut) [controller setErrorMessage:@"Connection timed out" withError: result];
            else [controller setErrorMessage:@"An unexpected error occurred" withError: result];
        }
    }
}

@end
