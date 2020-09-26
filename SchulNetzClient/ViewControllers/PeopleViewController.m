#import "PeopleViewController.h"
#import "../Account.h"
#import "../Data/Data.h"
#import "../Util.h"
#import "../Variables.h"
#import "../Parser.h"
#import "../Data/Change.h"
#import "StudentViewController.h"
#import "TeacherViewController.h"

@interface PeopleCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *mainLabel;
@end

@implementation PeopleCell

@end

@interface PeopleViewController ()
@property (weak, nonatomic) IBOutlet UITableView *peopleTableView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *sectionSelector;
@end

@implementation PeopleViewController
NSMutableDictionary* students;
NSMutableDictionary* teachers;
BOOL showTeachers = false;

-(void)viewDidLoad {
    [super viewDidLoad];
    
    _peopleTableView.tintColor = [Util getTintColor];
    
    _peopleTableView.delegate = self;
    _peopleTableView.dataSource = self;
    
    _sectionSelector.tintColor = [Util getTintColor];
    [_sectionSelector setSelectedSegmentIndex:0];
    
    [self reload];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    if([Util checkConnection]){
        __block User* copy = [Variables.get.user copy];
        
        [[Variables get].account loadPage:@"22352" completion:^(NSObject *doc) {
            copy = [Variables.get.user copy];
            
            if([doc class] == [HTMLDocument class]) [Parser parseTeachers:(HTMLDocument*)doc forUser:[Variables get].user];
        }];
        
        [[Variables get].account loadPage:@"22326" completion:^(NSObject *doc) {
            if([doc class] == [HTMLDocument class]) [Parser parseStudents:(HTMLDocument*)doc forUser:[Variables get].user];
            [[Variables get].user processConnections];
            [self reload];
            
            [Change publishNotifications:[Change getChanges:copy current:Variables.get.user]];
            [Variables.get.user save];
        }];
    }
}

-(void)reload{
    students = [[NSMutableDictionary alloc] init];
    teachers = [[NSMutableDictionary alloc] init];
    
    for(Student* s in [Variables get].user.students){
        NSString* letter = [s.lastName substringWithRange:NSMakeRange(0, 1)].capitalizedString;
        
        if([[students allKeys] containsObject:letter]){
            [((NSMutableArray*)[students objectForKey:letter]) addObject:s];
        } else {
            NSMutableArray* array = [[NSMutableArray alloc] init];
            [array addObject:s];
            [students setObject:array forKey:letter];
        }
    }
    
    for(Teacher* t in [Variables get].user.teachers){
        NSString* letter = [t.lastName substringWithRange:NSMakeRange(0, 1)].capitalizedString;
        
        if([[teachers allKeys] containsObject:letter]){
            [((NSMutableArray*)[teachers objectForKey:letter]) addObject:t];
        } else {
            NSMutableArray* array = [[NSMutableArray alloc] init];
            [array addObject:t];
            [teachers setObject:array forKey:letter];
        }
    }
    
    [_peopleTableView reloadData];
}

-(IBAction)sectionChanged:(id)sender {
    showTeachers = !showTeachers;
    
    [_peopleTableView setContentOffset:CGPointZero animated:true];
    [_peopleTableView reloadData];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"studentSegue"]){
        StudentViewController* vc = (StudentViewController*)segue.destinationViewController;
        NSArray* keys = [students.allKeys sortedArrayUsingComparator:^(id a, id b) {
            return [a compare:b options:NSNumericSearch];
        }];
        vc.student = [students objectForKey:keys[[_peopleTableView indexPathForCell:((UITableViewCell*) sender)].section]][[_peopleTableView indexPathForCell:((UITableViewCell*) sender)].row];
    } else if([segue.identifier isEqualToString:@"teacherSegue"]){
        TeacherViewController* vc = (TeacherViewController*)segue.destinationViewController;
        NSArray* keys = [teachers.allKeys sortedArrayUsingComparator:^(id a, id b) {
            return [a compare:b options:NSNumericSearch];
        }];
        vc.teacher = [teachers objectForKey:keys[[_peopleTableView indexPathForCell:((UITableViewCell*) sender)].section]][[_peopleTableView indexPathForCell:((UITableViewCell*) sender)].row];
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    PeopleCell* cell;
    
    if(!showTeachers){
        cell = [tableView dequeueReusableCellWithIdentifier:@"studentCell" forIndexPath:indexPath];
        cell.mainLabel.text = [NSString stringWithFormat:@"%@ %@", ((Student*)[[students objectForKey:[self tableView:tableView titleForHeaderInSection:indexPath.section]] objectAtIndex:indexPath.row]).firstName, ((Student*)[[students objectForKey:[self tableView:tableView titleForHeaderInSection:indexPath.section]] objectAtIndex:indexPath.row]).lastName];
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"teacherCell" forIndexPath:indexPath];
        cell.mainLabel.text = [NSString stringWithFormat:@"%@ %@", ((Teacher*)[[teachers objectForKey:[self tableView:tableView titleForHeaderInSection:indexPath.section]] objectAtIndex:indexPath.row]).firstName, ((Teacher*)[[teachers objectForKey:[self tableView:tableView titleForHeaderInSection:indexPath.section]] objectAtIndex:indexPath.row]).lastName];
    }
    
    cell.tintColor = [Util getTintColor];
    
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(!showTeachers){
        NSArray* keys = [students.allKeys sortedArrayUsingComparator:^(id a, id b) {
            return [a compare:b options:NSNumericSearch];
        }];
        
        return ((NSMutableArray*)[students objectForKey:keys[section]]).count;
    } else {
        NSArray* keys = [teachers.allKeys sortedArrayUsingComparator:^(id a, id b) {
            return [a compare:b options:NSNumericSearch];
        }];
        
        return ((NSMutableArray*)[teachers objectForKey:keys[section]]).count;
    }
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if(!showTeachers){
        return students.allKeys.count;
    } else {
        return teachers.allKeys.count;
    }
}

-(NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView{
    if(tableView.hidden) return nil;
    
    if(!showTeachers){
        return [students.allKeys sortedArrayUsingComparator:^(id a, id b) {
            return [a compare:b options:NSNumericSearch];
        }];
    } else {
        return [teachers.allKeys sortedArrayUsingComparator:^(id a, id b) {
            return [a compare:b options:NSNumericSearch];
        }];
    }
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index{
    
    return index;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if(!showTeachers){
        NSArray* keys = [students.allKeys sortedArrayUsingComparator:^(id a, id b) {
            return [a compare:b options:NSNumericSearch];
        }];
        
        return keys[section];
    } else {
        NSArray* keys = [teachers.allKeys sortedArrayUsingComparator:^(id a, id b) {
            return [a compare:b options:NSNumericSearch];
        }];
        
        return keys[section];
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:true];
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
