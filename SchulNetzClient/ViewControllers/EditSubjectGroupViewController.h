#import <UIKit/UIKit.h>
#import "../Data/SubjectGroup.h"

@interface EditSubjectGroupViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic) SubjectGroup* group;
@end
