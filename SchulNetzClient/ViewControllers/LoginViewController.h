#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource>
-(void)setErrorMessage:(NSString*)message withError:(NSError*)error;
-(void)setErrorMessage: (NSString*) message;
@end
