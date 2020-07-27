#import "SubjectsViewController.h"
#import "../Account.h"
#import "../Data/Data.h"
#import "../Util.h"
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
    int cellPerRow;
}

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@end


@implementation SubjectsViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    cellPerRow = 2;
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell* cell;
    
    if(indexPath.row == 0){
        AverageCell* averageCell = ((AverageCell*)[collectionView dequeueReusableCellWithReuseIdentifier:@"averageCell" forIndexPath:indexPath]);
        
        double negative = 0;
        double positive = 0;
        
        for(Subject* s in [Account getCurrent].user.subjects){
            if(s.average < 1|| isnan(s.average)) continue;
            
            double rounded = round(2.0 * s.average) / 2.0 - 4;
            if(rounded > 0) positive += rounded;
            else negative += 2 * -rounded;
        }
        
        averageCell.averageLabel.text = [NSNumber numberWithDouble:positive - negative].stringValue;
        averageCell.negativeLabel.text = [NSString stringWithFormat:@"-%@", [NSNumber numberWithDouble:negative].stringValue];
        averageCell.positiveLabel.text = [NSString stringWithFormat:@"+%@", [NSNumber numberWithDouble:positive].stringValue];
        
        cell = averageCell;
    } else {
        SubjectCell* subjectCell = ((SubjectCell*)[collectionView dequeueReusableCellWithReuseIdentifier:@"subjectCell" forIndexPath:indexPath]);
        
        Subject* s = [[Account getCurrent].user.subjects objectAtIndex:indexPath.row - 1];
        subjectCell.subjectLabel.text = s.name;
        subjectCell.averageLabel.text = [NSString stringWithFormat:@"%@%@", [NSNumber numberWithDouble:s.average].stringValue, s.gradesHidden ? @"*" : @""];
        s.gradesConfirmed ? [subjectCell.subjectLabel setFont:[UIFont systemFontOfSize:subjectCell.subjectLabel.font.pointSize]] : [subjectCell.subjectLabel setFont:[UIFont systemFontOfSize:subjectCell.subjectLabel.font.pointSize weight:UIFontWeightHeavy]];
        if(s.average < 1 || isnan(s.average)) subjectCell.averageLabel.text = @"-";
        subjectCell.averageLabel.textColor = [Grade colorForGrade:s.average];
        
        cell = subjectCell;
    }
    
    cell.layer.borderColor = [Util getTintColor].CGColor;
    cell.layer.borderWidth = 2;
    cell.layer.cornerRadius = [self collectionView:collectionView layout:collectionView.collectionViewLayout sizeForItemAtIndexPath:indexPath].height / 6;
    
    return cell;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return [Account getCurrent].user.subjects.count + 1;
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    int width = collectionView.bounds.size.width / cellPerRow - cellPerRow * 5;
    int height = collectionView.bounds.size.width / 3 / 3 * 2;
    if(indexPath.row == 0) width = collectionView.bounds.size.width;
    return CGSizeMake(width, height);
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"subjectSegue"]){
        SubjectViewController* vc = segue.destinationViewController;
        vc.subject = [Account getCurrent].user.subjects[[_collectionView indexPathForCell:sender].item - 1];
    }
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return cellPerRow * cellPerRow * 5;
}
@end
