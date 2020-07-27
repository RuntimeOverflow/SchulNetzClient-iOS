#import <UIKit/UIKit.h>
#import "../Data/Data.h"

@interface StudentViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate>
@property (nonatomic) Student* student;
@end
