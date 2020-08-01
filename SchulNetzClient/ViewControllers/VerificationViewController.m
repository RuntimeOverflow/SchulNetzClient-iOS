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

-(void)setAccount:(Account*)account{
    NSObject* result = [account signIn];
    
    if([[result class] isSubclassOfClass:[NSNumber class]] && ((NSNumber*)result).boolValue){
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
            if([result class] != [NSError class]) [controller setErrorMessage:@"Invalid username/password"];
            else if(((NSError*)result).code == NSURLErrorBadURL || ((NSError*)result).code == NSURLErrorCannotFindHost || ((NSError*)result).code == NSURLErrorFileDoesNotExist || ((NSError*)result).code == NSURLErrorUnsupportedURL) [controller setErrorMessage:((NSError*)result).localizedDescription withError: ((NSError*)result)];
            else if(((NSError*)result).code == NSURLErrorCannotConnectToHost) [controller setErrorMessage:@"Can't connect to host" withError: ((NSError*)result)];
            else if(((NSError*)result).code == NSURLErrorNetworkConnectionLost || ((NSError*)result).code == NSURLErrorNotConnectedToInternet) [controller setErrorMessage:((NSError*)result).localizedDescription withError: ((NSError*)result)];
            else if(((NSError*)result).code == NSURLErrorTimedOut) [controller setErrorMessage:((NSError*)result).localizedDescription withError: ((NSError*)result)];
            else [controller setErrorMessage:((NSError*)result).localizedDescription withError: ((NSError*)result)];
        }
    }
}

@end
