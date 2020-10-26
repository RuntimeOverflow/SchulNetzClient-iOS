#import "UnvaluedGradesViewController.h"
#import "../Data/Subject.h"
#import "../Variables.h"

@interface UnvaluedGradeCell : UITableViewCell{
    id target;
    SEL selector;
}

@property (weak, nonatomic) IBOutlet UILabel *unvaluedSubjectLabel;
@property (weak, nonatomic) IBOutlet UISwitch *unvaluedSubjectSwitch;

-(void)setSwitchListener:(id)target selector:(SEL)selector;
@end

@implementation UnvaluedGradeCell
-(void)setSwitchListener:(id)target selector:(SEL)selector{
    self->target = target;
    self->selector = selector;
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
- (IBAction)switchToggled:(id)sender {
    [target performSelector:selector withObject:self];
}
#pragma clang diagnostic pop
@end

@interface UnvaluedGradesViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation UnvaluedGradesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _tableView.delegate = self;
    _tableView.dataSource = self;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UnvaluedGradeCell* cell = [tableView dequeueReusableCellWithIdentifier:@"unvaluedGradeCell"];
    
    int index = -1;
    for(Subject* s in Variables.get.user.subjects){
        if(!s.group) index++;
        
        if(index == indexPath.row){
            cell.unvaluedSubjectLabel.text = s.name ? s.name : s.shortName;
            cell.unvaluedSubjectSwitch.on = s.unvalued;
            
            [cell setSwitchListener:self selector:@selector(onCellChanges:)];
            
            break;
        }
    }
    
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    int count = 0;
    for(Subject* s in Variables.get.user.subjects){
        if(!s.group) count++;
    }
    return count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(void)onCellChanges:(UnvaluedGradeCell*)cell{
    int row = (int)[_tableView indexPathForCell:cell].row;
    int index = -1;
    for(Subject* s in Variables.get.user.subjects){
        if(!s.group) index++;
        
        if(index == row){
            s.unvalued = cell.unvaluedSubjectSwitch.on;
            
            break;
        }
    }
    
    [Variables.get.user save];
}
@end
