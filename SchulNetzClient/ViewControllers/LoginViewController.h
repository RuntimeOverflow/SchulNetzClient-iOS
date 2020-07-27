#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource>
-(void)setErrorMessage:(NSString *)message withError:(int)error;
-(void)setErrorMessage: (NSString*) message;
@end
