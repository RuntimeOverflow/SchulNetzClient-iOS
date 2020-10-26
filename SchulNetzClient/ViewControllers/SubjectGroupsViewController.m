#import "SubjectGroupsViewController.h"
#import "Variables.h"
#import "../Data/SubjectGroup.h"
#import "EditSubjectGroupViewController.h"

@interface SubjectGroupCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *subjectNameLabel;
@end

@implementation SubjectGroupCell
@end

@interface SubjectGroupsViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation SubjectGroupsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _tableView.delegate = self;
    _tableView.dataSource = self;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [_tableView reloadData];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"createSubjectGroup"]){
        SubjectGroup* g = [[SubjectGroup alloc] init];
        g.name = NSLocalizedString(@"newGroup", @"");
        g.roundOption = 1;
        [Variables.get.user.subjectGroups addObject:g];
        
        ((EditSubjectGroupViewController*)segue.destinationViewController).group = g;
    } else if([segue.identifier isEqualToString:@"editSubjectGroup"]){
        int index = (int)[_tableView indexPathForCell:sender].row;
        ((EditSubjectGroupViewController*)segue.destinationViewController).group = Variables.get.user.subjectGroups[index];
    }
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    SubjectGroupCell* cell = [tableView dequeueReusableCellWithIdentifier:@"subjectGroupCell"];
    
    cell.subjectNameLabel.text = Variables.get.user.subjectGroups[indexPath.row].name;
    
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return Variables.get.user.subjectGroups.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
@end
