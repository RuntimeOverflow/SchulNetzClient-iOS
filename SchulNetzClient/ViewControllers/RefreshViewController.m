#import "RefreshViewController.h"
#import "../Parser.h"
#import "../Account.h"
#import "../Util.h"

@interface RefreshViewController ()
@property (weak, nonatomic) IBOutlet UIProgressView *progressBar;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;
@property (weak, nonatomic) IBOutlet UIImageView *wifiError;
@end

@implementation RefreshViewController
- (void)viewWillAppear:(BOOL)animated{
    [self refresh];
    
    _progressBar.progressTintColor = [Util getTintColor];
    _loadingIndicator.color = [Util getTintColor];
    _wifiError.tintColor = [Util getTintColor];
}

-(void) refresh{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    __block BOOL wifi = [Util checkConnection];
    dispatch_async(queue, ^{
        if(!wifi){
            dispatch_async(dispatch_get_main_queue(), ^{
                self->_descriptionLabel.hidden = true;
                self->_loadingIndicator.hidden = true;
                self->_progressBar.hidden = true;
                self->_wifiError.hidden = false;
            });
        }
        
        while(!wifi){
            [NSThread sleepForTimeInterval:1];
            wifi = [Util checkConnection];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self->_descriptionLabel.hidden = false;
            self->_loadingIndicator.hidden = false;
            self->_progressBar.hidden = false;
            self->_wifiError.hidden = true;
            
            BOOL success = [[Account getCurrent] refresh:self];
            
            if(!success){
                if(![Util checkConnection]) [self refresh];
            } else {
                [[Account getCurrent].user cacheData];
                
                UIViewController* vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"MainScene"];
                vc.modalPresentationStyle = UIModalPresentationFullScreen;
                [[Util getMainController] presentViewController:vc animated:true completion:nil];
            }
        });
    });
}

-(void) setProgress:(int)progress withDescription:(NSString *)description{
    double totalProgress = [Parser allPages].count - 1;
    
    _descriptionLabel.text = description;
    
    if(progress >= 0){
        _progressBar.hidden = false;
        _progressBar.progress = progress / totalProgress;
    } else _progressBar.hidden = true;
}
@end
