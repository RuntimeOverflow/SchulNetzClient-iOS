#import <UIKit/UIKit.h>
#import "../Data/Data.h"

@interface TeacherViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate>
@property Teacher* teacher;
@end
