#import "SubjectViewController.h"

@interface SubjectInfoCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UILabel *additionalLabel;
@end

@implementation SubjectInfoCell

@end

@interface SubjectViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UINavigationItem *titleBar;
@property (weak, nonatomic) IBOutlet UILabel *noGradesLabel;
@end

@implementation SubjectViewController
@synthesize subject;

NSMutableArray* expanded;

-(void)viewDidLoad {
    expanded = [[NSMutableArray alloc] init];
    
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    _titleBar.title = [NSString stringWithFormat:@"%@%@", subject.name, ([subject getAverage] > 1 ? [NSString stringWithFormat:@" (%@%@)", [NSNumber numberWithDouble:(round([subject getAverage] * 1000) / 1000)].stringValue, (subject.hiddenGrades ? @"*" : @"")] : @"")];
    
    if(subject.grades.count <= 0){
        _tableView.hidden = true;
        _noGradesLabel.hidden = false;
    } else{
        _tableView.hidden = false;
        _noGradesLabel.hidden = true;
    }
    
    [super viewDidLoad];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.row == 0){
        if(![expanded containsObject:[NSNumber numberWithLong:indexPath.section]]) [expanded addObject:[NSNumber numberWithLong:indexPath.section]];
        else [expanded removeObject:[NSNumber numberWithLong:indexPath.section]];
        [tableView reloadData];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:true];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SubjectInfoCell* cell;
    if(indexPath.row == 0) cell = [tableView dequeueReusableCellWithIdentifier:@"SubjectInfoCell"];
    else cell = [tableView dequeueReusableCellWithIdentifier:@"SubjectDetailCell"];
    
    if(indexPath.row == 0) {
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        
        if(@available(iOS 13.0, *)) cell.label.textColor = UIColor.labelColor;
        else cell.label.textColor = [UIColor blackColor];
        
        cell.label.text = [NSString stringWithFormat:@"%@", ((Grade*)subject.grades[indexPath.section]).content];
        
        if(((Grade*)subject.grades[indexPath.section]).grade > 1) cell.additionalLabel.text = [NSString stringWithFormat:@"%@%@", (((Grade*)subject.grades[indexPath.section]).weight != 1 ? [NSString stringWithFormat:@"(%@x) ", [NSNumber numberWithDouble:((Grade*)subject.grades[indexPath.section]).weight].stringValue] : @""), [NSNumber numberWithDouble:((Grade*)subject.grades[indexPath.section]).grade].stringValue];
        else cell.additionalLabel.text = [NSString stringWithFormat:@"%@-", (((Grade*)subject.grades[indexPath.section]).weight != 1 ? [NSString stringWithFormat:@"(%@x) ", [NSNumber numberWithDouble:((Grade*)subject.grades[indexPath.section]).weight].stringValue] : @"")];
        
        cell.additionalLabel.textColor = [Grade colorForGrade:((Grade*)subject.grades[indexPath.section]).grade];
    } else if(indexPath.row == 1 && ((Grade*)subject.grades[indexPath.section]).date) {
        NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"d. MMMM yyyy";
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.label.textColor = [UIColor systemGrayColor];
        cell.label.text = [formatter stringFromDate:((Grade*)subject.grades[indexPath.section]).date];
    } else if(![((Grade*)subject.grades[indexPath.section]).details isEqualToString:@""]) {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.label.textColor = [UIColor systemGrayColor];
        cell.label.text = ((Grade*)subject.grades[indexPath.section]).details;
    }
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return subject.grades.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    int rows = 1;
    
    if([expanded containsObject:[NSNumber numberWithLong:section]]){
        if(((Grade*)subject.grades[section]).date){
            rows += 1;
        }
        
        if(![((Grade*)subject.grades[section]).details isEqualToString:@""]){
            rows += 1;
        }
    }
    return rows;
}
@end
