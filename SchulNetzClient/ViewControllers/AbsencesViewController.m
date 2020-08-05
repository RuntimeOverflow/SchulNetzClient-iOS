#import "AbsencesViewController.h"
#import "../Variables.h"
#import "../Data/Absence.h"
#import "../Util.h"
#import "../Parser.h"

@interface AbsenceCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UILabel *additionalLabel;
@end

@implementation AbsenceCell
@end

@interface AbsencesViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIView *headerBackground;
@property (weak, nonatomic) IBOutlet UILabel *noAbsencesLabel;
@end

@implementation AbsencesViewController
NSMutableArray<NSNumber*>* primaryExpanded;
NSMutableArray<NSNumber*>* secondaryExpanded;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    _noAbsencesLabel.hidden = true;
    
    [self reload];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        if([Util checkConnection]){
            [[Variables get].account loadPage:@"21111" completion:^(NSObject *doc) {
                if([doc class] == [HTMLDocument class]) [Parser parseAbsences:(HTMLDocument*)doc forUser:[Variables get].user];
                [[Variables get].user processConnections];
                [self reload];
            }];
        }
    //});
}

-(void)reload{
    primaryExpanded = [[NSMutableArray alloc] init];
    secondaryExpanded = [[NSMutableArray alloc] init];
    
    int totalLessons = 0;
    for(int i = 0; i < [Variables get].user.absences.count; i++){
        primaryExpanded[i] = [NSNumber numberWithBool:false];
        secondaryExpanded[i] = [NSNumber numberWithBool:false];
        
        totalLessons += [Variables get].user.absences[i].lessonCount;
    }
    
    _titleLabel.text = [NSString stringWithFormat:@"%@: %d", NSLocalizedString(@"missedLessons", @""), totalLessons];
    _headerBackground.backgroundColor = [Util getTintColor];
    
    [_tableView reloadData];
    
    if([Variables get].user.absences.count <= 0){
        _tableView.hidden = true;
        _noAbsencesLabel.hidden = false;
    } else{
        _tableView.hidden = false;
        _noAbsencesLabel.hidden = true;
    }
}

- (UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    AbsenceCell* cell = [tableView dequeueReusableCellWithIdentifier:@"absenceCell"];
    
    if(indexPath.row == 0){
        cell.label.text = [Variables get].user.absences[indexPath.section].reason.length > 0 ? [Variables get].user.absences[indexPath.section].reason : [NSString stringWithFormat:@"[%@]", NSLocalizedString(@"noDesc", @"")];
        
        if(@available(iOS 13.0, *)) cell.label.textColor = UIColor.labelColor;
        else cell.label.textColor = [UIColor blackColor];
        
        cell.additionalLabel.text = [NSString stringWithFormat:@"%d %@", [Variables get].user.absences[indexPath.section].lessonCount, ([Variables get].user.absences[indexPath.section].lessonCount != 1 ? NSLocalizedString(@"lessons", @"") : NSLocalizedString(@"lesson", @""))];
        
        if(@available(iOS 13.0, *)) cell.label.textColor = UIColor.labelColor;
        else cell.label.textColor = [UIColor blackColor];
        
        UIColor* labelColor = [UIColor blackColor];
        if(@available(iOS 13.0, *)) labelColor = UIColor.labelColor;
        
        cell.additionalLabel.textColor = [Variables get].user.absences[indexPath.section].excused ? labelColor : [UIColor redColor];
    } else if(indexPath.row == 1 && [Variables get].user.absences[indexPath.section].startDate){
        NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"dd. MMMM yyyy";
        
        cell.label.text = [NSString stringWithFormat:@"%@%@", [formatter stringFromDate:[Variables get].user.absences[indexPath.section].startDate], ([[Variables get].user.absences[indexPath.section].startDate compare:[Variables get].user.absences[indexPath.section].endDate] != 0 ? [NSString stringWithFormat:@" - %@", [formatter stringFromDate:[Variables get].user.absences[indexPath.section].endDate]] : @"")];
        cell.label.textColor = [UIColor systemGrayColor];
        
        cell.additionalLabel.text = @"";
    } else if(indexPath.row == ([Variables get].user.absences[indexPath.section].startDate ? 2 : 1)){
        cell.label.text = !secondaryExpanded[indexPath.section].boolValue ? NSLocalizedString(@"showReports", @"") : NSLocalizedString(@"hideReports", @"");
        cell.label.textColor = [UIColor colorWithRed:0/255.0 green:122/255.0 blue:255/255.0 alpha:255/255.0];
        
        cell.additionalLabel.text = @"";
    } else{
        int index = (int)indexPath.row - ([Variables get].user.absences[indexPath.section].startDate ? 3 : 2);
        
        if([Variables get].user.absences[indexPath.section].subjects.count > index && [Variables get].user.absences[indexPath.section].subjects[index]){
            cell.label.text = [NSString stringWithFormat:@"%d. %@", index + 1, ([Variables get].user.absences[indexPath.section].subjects[index].name ? [Variables get].user.absences[indexPath.section].subjects[index].name : [Variables get].user.absences[indexPath.section].subjects[index].shortName)];
            cell.label.textColor = [UIColor systemGrayColor];
        }
        
        cell.additionalLabel.text = @"";
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.row == 0){
        primaryExpanded[indexPath.section] = [NSNumber numberWithBool:!primaryExpanded[indexPath.section].boolValue];
        secondaryExpanded[indexPath.section] = [NSNumber numberWithBool:false];
    } else if(indexPath.row == ([Variables get].user.absences[indexPath.section].startDate ? 2 : 1)){
        secondaryExpanded[indexPath.section] = [NSNumber numberWithBool:!secondaryExpanded[indexPath.section].boolValue];
    }
    
    [tableView reloadData];
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    int count = 1;
    
    if(primaryExpanded[section].boolValue){
        if([Variables get].user.absences[section].startDate) count++;
        count++;
        
        if(secondaryExpanded[section].boolValue){
            count += [Variables get].user.absences[section].subjects.count;
        }
    }
    
    return count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return [Variables get].user.absences.count;
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [super viewWillDisappear:animated];
}
@end
