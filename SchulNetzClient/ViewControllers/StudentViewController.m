#import "StudentViewController.h"

@interface StudentInfoCell : UITableViewCell
@end

@implementation StudentInfoCell
- (UILabel *)textLabel{
    return self.subviews.firstObject.subviews.firstObject;
}
@end

@interface StudentViewController ()
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation StudentViewController
@synthesize student;
@synthesize tableView;

-(void)viewDidLoad {
    [super viewDidLoad];
    
    UILongPressGestureRecognizer* recognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    recognizer.minimumPressDuration = 1.0;
    recognizer.delegate = self;
    [tableView addGestureRecognizer:recognizer];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 2){
        NSString* url = [[NSString stringWithFormat:@"https://maps.apple.com/?address=%@, %@ %@", student.address, student.zip, student.city] stringByAddingPercentEncodingWithAllowedCharacters: [NSCharacterSet URLQueryAllowedCharacterSet]];
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url] options:@{} completionHandler:nil];
    } else if(indexPath.section == 3 && indexPath.row == 0 && ![student.phone isEqualToString:@""]){
        
        NSMutableString* number = [self->student.phone mutableCopy];
        [number replaceOccurrencesOfString:@" " withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, number.length)];
        [number replaceOccurrencesOfString:@"+" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, number.length)];
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@", number]] options:@{} completionHandler:nil];
    } else if(indexPath.section == 4 && indexPath.row == 0){
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"calshow:%f", [student.birth timeIntervalSinceReferenceDate]]] options:@{} completionHandler:nil];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:true];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell* cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    if(![[self contentForIndexPath:indexPath] isEqualToString:@""]) cell.textLabel.text = [self contentForIndexPath:indexPath];
    
    return cell;
}

-(NSString*)contentForIndexPath: (NSIndexPath*)indexPath{
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"d. MMMM yyyy";
    
    NSDateComponents* c = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[NSDate dateWithTimeInterval:0 sinceDate:student.birth]];
    long age = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[NSDate date]].year - c.year;
    c.year = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[NSDate date]].year;
    BOOL birthdayThisYear = [[NSDate date] timeIntervalSinceDate:[[NSCalendar currentCalendar] dateFromComponents:c]] > 0;
    
    switch (indexPath.section) {
        case 0:
            return [NSString stringWithFormat:@"%@ %@", student.firstName, student.lastName];
            break;
        case 1:
            return [student.className stringByAppendingString: student.bilingual ? @" (Bilingual)" : @""];
            break;
        case 2:
            if(indexPath.row == 0) return student.address;
            else return [NSString stringWithFormat:@"%@ %@", student.zip, student.city];
            break;
        case 3:
            return student.phone;
            break;
        case 4:
            return [NSString stringWithFormat:@"%@ (%ld years)", [formatter stringFromDate: student.birth], birthdayThisYear ? age : age - 1];
            break;
        default:
            return @"";
            break;
    }
}

-(void)longPress:(UILongPressGestureRecognizer*)recognizer{
    CGPoint p = [recognizer locationInView:tableView];

    NSIndexPath *indexPath = [tableView indexPathForRowAtPoint:p];
    if (indexPath != nil && recognizer.state == UIGestureRecognizerStateBegan && indexPath.section >= 0 && indexPath.section <= 4) {
        
        [UIPasteboard generalPasteboard].string = [self contentForIndexPath:indexPath];
        
        UIAlertController* controller = [UIAlertController alertControllerWithTitle:@"Copied!" message:@"" preferredStyle:UIAlertControllerStyleAlert];
        [self presentViewController:controller animated:true completion:^{
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            
            dispatch_async(queue, ^{
                [NSThread sleepForTimeInterval:1];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [controller dismissViewControllerAnimated:true completion:NULL];
                });
            });
        }];
    }
}
@end
