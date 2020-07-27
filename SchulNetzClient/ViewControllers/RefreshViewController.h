#import <UIKit/UIKit.h>

@interface RefreshViewController : UIViewController
-(void) refresh;
-(void) setProgress: (int) progress withDescription: (NSString*) description;
@end
