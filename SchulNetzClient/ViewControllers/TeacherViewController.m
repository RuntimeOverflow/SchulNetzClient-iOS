#import "TeacherViewController.h"

@interface TeacherInfoCell : UITableViewCell
@end

@implementation TeacherInfoCell
- (UILabel *)textLabel{
    return self.subviews.firstObject.subviews.firstObject;
}
@end

@interface TeacherViewController ()
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UINavigationItem *titleBar;
@end

@implementation TeacherViewController
@synthesize teacher;
@synthesize tableView;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _titleBar.title = [NSString stringWithFormat:@"%@ %@ (%@)", teacher.firstName, teacher.lastName, teacher.shortName];
    
    UILongPressGestureRecognizer* recognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    recognizer.minimumPressDuration = 1.0;
    recognizer.delegate = self;
    [tableView addGestureRecognizer:recognizer];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 0 && indexPath.row == 0){
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"mailto:%@", teacher.mail]] options:@{} completionHandler:nil];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:true];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    TeacherInfoCell* cell = [tableView dequeueReusableCellWithIdentifier:@"TeacherInfoCell"];
    
    cell.textLabel.text = [self contentForIndexPath:indexPath];
    
    if (indexPath.section == 0){
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        cell.textLabel.textColor = [UIColor colorWithRed:0/255.0 green:122/255.0 blue:255/255.0 alpha:255/255.0];
    }
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(section == 0) return 1;
    else return teacher.subjects.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (section == 0){
        return NSLocalizedString(@"mail", @"");
    } else {
        return NSLocalizedString(@"subjects", @"");
    }
}

-(NSString*)contentForIndexPath:(NSIndexPath*)indexPath{
    if (indexPath.section == 0){
        return teacher.mail;
    } else {
        return ((Subject*)teacher.subjects[indexPath.row]).name ? ((Subject*)teacher.subjects[indexPath.row]).name : ((Subject*)teacher.subjects[indexPath.row]).shortName;
    }
}

-(void)longPress:(UILongPressGestureRecognizer*)recognizer{
    CGPoint p = [recognizer locationInView:tableView];

    NSIndexPath *indexPath = [tableView indexPathForRowAtPoint:p];
    if (indexPath != nil && recognizer.state == UIGestureRecognizerStateBegan && indexPath.section >= 0 && indexPath.section <= 4) {
        
        [UIPasteboard generalPasteboard].string = [self contentForIndexPath:indexPath];
        
        UIAlertController* controller = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"copied", @"") message:@"" preferredStyle:UIAlertControllerStyleAlert];
        [self presentViewController:controller animated:true completion:^{
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [NSThread sleepForTimeInterval:1];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [controller dismissViewControllerAnimated:true completion:NULL];
                });
            });
        }];
    }
}
@end
