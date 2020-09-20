#import "SubjectsViewController.h"
#import "../Account.h"
#import "../Data/Data.h"
#import "../Util.h"
#import "../Variables.h"
#import "../Parser.h"
#import "../Data/Change.h"
#import "SubjectViewController.h"

@interface SubjectCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UILabel *subjectLabel;
@property (weak, nonatomic) IBOutlet UILabel *averageLabel;
@end

@implementation SubjectCell

@end

@interface AverageCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UILabel *averageLabel;
@property (weak, nonatomic) IBOutlet UILabel *negativeLabel;
@property (weak, nonatomic) IBOutlet UILabel *positiveLabel;
@end

@implementation AverageCell

@end

@interface SubjectsViewController (){
    NSMutableArray<Subject*> *current;
    int cellPerRow;
}

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@end


@implementation SubjectsViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    current = [Variables get].user.subjects;
    
    cellPerRow = 2;
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    
    [self reload];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    if([Util checkConnection]){
        User* copy = [Variables.get.user copy];
        
        [[Variables get].account loadPage:@"22326" completion:^(NSObject *doc) {
            if([doc class] == [HTMLDocument class]) {
                NSMutableArray* previous = Variables.get.user.subjects;
                
                __block BOOL result = [Parser parseSubjects:(HTMLDocument*)doc forUser:[Variables get].user];
                if(!result) Variables.get.user.subjects = previous;
                
                [Variables.get.user processConnections];
                
                if(result) [[Variables get].account loadPage:@"21311" completion:^(NSObject *doc) {
                    if([doc class] == [HTMLDocument class]) result = [Parser parseGrades:(HTMLDocument*)doc forUser:[Variables get].user];
                    if(!result) Variables.get.user.subjects = previous;
                    
                    [[Variables get].user processConnections];
                    [self reload];
                    
                    [Change publishNotifications:[Change getChanges:copy current:Variables.get.user]];
                    [Variables.get.user save];
                }];
            }
        }];
    }
}

-(void)reload{
    current = [Variables get].user.subjects;
    [_collectionView reloadData];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell* cell;
    
    if(indexPath.row == 0){
        AverageCell* averageCell = ((AverageCell*)[collectionView dequeueReusableCellWithReuseIdentifier:@"averageCell" forIndexPath:indexPath]);
        
        double negative = 0;
        double positive = 0;
        
        for(Subject* s in current){
            if([s getAverage] < 1|| isnan([s getAverage])) continue;
            
            double rounded = round(2.0 * [s getAverage]) / 2.0 - 4;
            if(rounded > 0) positive += rounded;
            else negative += 2 * -rounded;
        }
        
        averageCell.averageLabel.text = [NSNumber numberWithDouble:positive - negative].stringValue;
        averageCell.negativeLabel.text = [NSString stringWithFormat:@"-%@", [NSNumber numberWithDouble:negative].stringValue];
        averageCell.positiveLabel.text = [NSString stringWithFormat:@"+%@", [NSNumber numberWithDouble:positive].stringValue];
        
        cell = averageCell;
    } else {
        SubjectCell* subjectCell = ((SubjectCell*)[collectionView dequeueReusableCellWithReuseIdentifier:@"subjectCell" forIndexPath:indexPath]);
        
        Subject* s = NULL;
        int index = -1;
        for(Subject* subject in current) {
            if(subject.name) index++;
            
            if(indexPath.row - 1 == index){
                s = subject;
                break;
            }
        }
        
        subjectCell.subjectLabel.text = s.name;
        subjectCell.averageLabel.text = [NSString stringWithFormat:@"%@%@", [NSNumber numberWithDouble:(round(1000.0 * [s getAverage]) / 1000.0)].stringValue, s.hiddenGrades ? @"*" : @""];
        s.confirmed ? [subjectCell.subjectLabel setFont:[UIFont systemFontOfSize:subjectCell.subjectLabel.font.pointSize]] : [subjectCell.subjectLabel setFont:[UIFont systemFontOfSize:subjectCell.subjectLabel.font.pointSize weight:UIFontWeightBold]];
        if([s getAverage] < 1 || isnan([s getAverage])) subjectCell.averageLabel.text = @"-";
        subjectCell.averageLabel.textColor = [Grade colorForGrade:[s getAverage]];
        
        cell = subjectCell;
    }
    
    cell.layer.borderColor = [Util getTintColor].CGColor;
    cell.layer.borderWidth = 2;
    cell.layer.cornerRadius = [self collectionView:collectionView layout:collectionView.collectionViewLayout sizeForItemAtIndexPath:indexPath].height / 6;
    
    return cell;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    int count = 0;
    
    for(Subject* s in current) if(s.name) count++;
    
    return count + 1;
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    int width = (collectionView.bounds.size.width - 20) / cellPerRow - cellPerRow * 5;
    int height = (collectionView.bounds.size.width - 20) / 9 * 2;
    if(indexPath.row == 0) width = collectionView.bounds.size.width - 20;
    return CGSizeMake(width, height);
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"subjectSegue"]){
        Subject* s = NULL;
        int index = -1;
        for(Subject* subject in current) {
            if(subject.name) index++;
            
            if([_collectionView indexPathForCell:sender].item - 1 == index){
                s = subject;
                break;
            }
        }
        
        SubjectViewController* vc = segue.destinationViewController;
        vc.subject = s;
    }
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return cellPerRow * cellPerRow * 5;
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
