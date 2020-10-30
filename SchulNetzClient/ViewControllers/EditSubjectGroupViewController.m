#import "EditSubjectGroupViewController.h"
#import "../Variables.h"

@interface SubjectGroupSubjectCell : UITableViewCell{
    id target;
    SEL selector;
}

@property (weak, nonatomic) IBOutlet UILabel *subjectNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *addRemoveButton;

-(void)setButtonListener:(id)target selector:(SEL)selector;
@end

@implementation SubjectGroupSubjectCell
-(void)setButtonListener:(id)target selector:(SEL)selector{
    self->target = target;
    self->selector = selector;
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
- (IBAction)buttonPressed:(id)sender {
    [target performSelector:selector withObject:self];
}
#pragma clang diagnostic pop
@end

@interface EditSubjectGroupViewController ()
@property (weak, nonatomic) IBOutlet UIView *nameCell;
@property (weak, nonatomic) IBOutlet UITextField *groupNameField;
@property (weak, nonatomic) IBOutlet UIView *roundOptionCell;
@property (weak, nonatomic) IBOutlet UISegmentedControl *roundOptionSelector;
@property (weak, nonatomic) IBOutlet UIView *deleteCell;
@property (weak, nonatomic) IBOutlet UITableView *addedSubjectsTableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *addedSubjectsHeight;
@property (weak, nonatomic) IBOutlet UITableView *freeSubjectsTableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *freeSubjectsHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *freeSubjectsTop;
@end

@implementation EditSubjectGroupViewController
@synthesize group;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIColor* separatorColor = [UIColor colorWithRed:0.235 green:0.235 blue:0.263 alpha:1];
    
    CALayer* border = [CALayer layer];
    border.frame = CGRectMake(0.0f, 0.0f, _nameCell.frame.size.width, 0.5f);
    border.backgroundColor = separatorColor.CGColor;
    [_nameCell.layer addSublayer:border];
    
    border = [CALayer layer];
    border.frame = CGRectMake(0.0f, _nameCell.frame.size.height - 1, _nameCell.frame.size.width, 0.5f);
    border.backgroundColor = separatorColor.CGColor;
    [_nameCell.layer addSublayer:border];
    
    border = [CALayer layer];
    border.frame = CGRectMake(0.0f, 0.0f, _roundOptionCell.frame.size.width, 0.5f);
    border.backgroundColor = separatorColor.CGColor;
    [_roundOptionCell.layer addSublayer:border];
    
    border = [CALayer layer];
    border.frame = CGRectMake(0.0f, _roundOptionCell.frame.size.height - 1, _roundOptionCell.frame.size.width, 0.5f);
    border.backgroundColor = separatorColor.CGColor;
    [_roundOptionCell.layer addSublayer:border];
    
    border = [CALayer layer];
    border.frame = CGRectMake(0.0f, 0.0f, _deleteCell.frame.size.width, 0.5f);
    border.backgroundColor = separatorColor.CGColor;
    [_deleteCell.layer addSublayer:border];
    
    border = [CALayer layer];
    border.frame = CGRectMake(0.0f, _deleteCell.frame.size.height - 1, _deleteCell.frame.size.width, 0.5f);
    border.backgroundColor = separatorColor.CGColor;
    [_deleteCell.layer addSublayer:border];
    
    _addedSubjectsTableView.delegate = self;
    _addedSubjectsTableView.dataSource = self;
    
    _freeSubjectsTableView.delegate = self;
    _freeSubjectsTableView.dataSource = self;
}

- (void)viewWillAppear:(BOOL)animated{
    [_groupNameField setText:group.name];
    
    _roundOptionSelector.selectedSegmentIndex = group.roundOption;
    
    [self reloadSubjects];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [Variables.get.user save];
}

-(void)reloadSubjects{
    [_addedSubjectsTableView reloadData];
    [_freeSubjectsTableView reloadData];
    
    [_addedSubjectsTableView layoutIfNeeded];
    _addedSubjectsHeight.constant = _addedSubjectsTableView.contentSize.height;
    [_freeSubjectsTableView layoutIfNeeded];
    _freeSubjectsHeight.constant = _freeSubjectsTableView.contentSize.height;
    
    if(group.subjects.count <= 0) _freeSubjectsTop.constant = 0;
    else _freeSubjectsTop.constant = 48;
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    SubjectGroupSubjectCell* cell = [tableView dequeueReusableCellWithIdentifier:@"subjectGroupSubjectCell"];
    
    if(tableView == _addedSubjectsTableView){
        cell.subjectNameLabel.text = group.subjects[indexPath.row].name ? group.subjects[indexPath.row].name : group.subjects[indexPath.row].shortName;
        [cell setButtonListener:self selector:@selector(removeSubject:)];
    } else if(tableView == _freeSubjectsTableView){
        int index = -1;
        for(Subject* s in Variables.get.user.subjects){
            if(!s.group) index++;
            
            if(index == indexPath.row){
                cell.subjectNameLabel.text = s.name ? s.name : s.shortName;
                
                break;
            }
        }
        
        [cell setButtonListener:self selector:@selector(addSubject:)];
    }
    
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(tableView == _addedSubjectsTableView){
        return group.subjects.count;
    } else if(tableView == _freeSubjectsTableView){
        int count = 0;
        for(Subject* s in Variables.get.user.subjects){
            if(!s.group) count++;
        }
        
        return count;
    }
    
    return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (IBAction)groupNameChanged:(id)sender {
    group.name = _groupNameField.text;
}

- (IBAction)roundOptionChanged:(id)sender {
    group.roundOption = (int)_roundOptionSelector.selectedSegmentIndex;
}

-(void)addSubject:(SubjectGroupSubjectCell*) cell{
    NSIndexPath* indexPath = [_freeSubjectsTableView indexPathForCell:cell];
    int index = -1;
    for(Subject* s in Variables.get.user.subjects){
        if(!s.group) index++;
        
        if(index == indexPath.row){
            s.group = group;
            
            [group.subjects addObject:s];
            [group.subjectIdentifiers addObject:s.identifier];
            
            break;
        }
    }
    
    [self reloadSubjects];
}

-(void)removeSubject:(SubjectGroupSubjectCell*) cell{
    NSIndexPath* indexPath = [_addedSubjectsTableView indexPathForCell:cell];
    
    Subject* s = group.subjects[indexPath.row];
    s.group = NULL;
    
    [group.subjects removeObject:s];
    [group.subjectIdentifiers removeObject:s.identifier];
    
    [self reloadSubjects];
}

- (IBAction)deleteGroup:(id)sender {
    for(Subject* s in group.subjects) s.group = NULL;
    
    [Variables.get.user.subjectGroups removeObject:group];
    [Variables.get.user processConnections];
    
    [self.navigationController popViewControllerAnimated:true];
}
@end
