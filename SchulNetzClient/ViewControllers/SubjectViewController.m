#import "SubjectViewController.h"

@interface SubjectInfoCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UILabel *additionalLabel;
@end

@implementation SubjectInfoCell

@end

@interface SubjectViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *subjectLabel;
@property (weak, nonatomic) IBOutlet UILabel *averageLabel;
@end

@implementation SubjectViewController
@synthesize subject;

NSMutableArray* expanded;

-(void)viewDidLoad {
    expanded = [[NSMutableArray alloc] init];
    
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    _subjectLabel.text = subject.name;
    _averageLabel.text = [NSString stringWithFormat:@"%@%@", [subject getAverage] > 1 ? [NSNumber numberWithDouble:(round([subject getAverage] * 1000) / 1000)].stringValue : @"-", subject.hiddenGrades ? @"*" : @""];
    _averageLabel.textColor = [Grade colorForGrade:[subject getAverage]];
    
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
        cell.label.textColor = [UIColor blackColor];
        cell.label.text = [NSString stringWithFormat:@"%@", ((Grade*)subject.grades[indexPath.section]).content];
        
        if(((Grade*)subject.grades[indexPath.section]).grade > 1) cell.additionalLabel.text = [NSString stringWithFormat:@"%@%@", (((Grade*)subject.grades[indexPath.section]).weight != 1 ? [NSString stringWithFormat:@"(%dx) ", (int) ((Grade*)subject.grades[indexPath.section]).weight] : @""), [NSNumber numberWithDouble:((Grade*)subject.grades[indexPath.section]).grade].stringValue];
        else cell.additionalLabel.text = @"-";
        
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.row != 2) return 40;
    else {
        return [[((Grade*)subject.grades[indexPath.section]).details componentsSeparatedByCharactersInSet:
        [NSCharacterSet newlineCharacterSet]] count] * 20 + 20;
    }
}
@end
