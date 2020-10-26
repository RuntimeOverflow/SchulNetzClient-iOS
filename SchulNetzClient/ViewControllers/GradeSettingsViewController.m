#import "GradeSettingsViewController.h"

@interface GradeSettingsViewController ()
@property (weak, nonatomic) IBOutlet UIView *doubleNegativePointsCell;
@property (weak, nonatomic) IBOutlet UISwitch *doubleNegativePointsSwitch;
@property (weak, nonatomic) IBOutlet UIView *unvaluedSubjectsCell;
@property (weak, nonatomic) IBOutlet UIView *subjectGroupsCell;
@end

@implementation GradeSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIColor* separatorColor = [UIColor colorWithRed:0.235 green:0.235 blue:0.263 alpha:1];
    
    CALayer* border = [CALayer layer];
    border.frame = CGRectMake(0.0f, 0.0f, _doubleNegativePointsCell.frame.size.width, 0.5f);
    border.backgroundColor = separatorColor.CGColor;
    [_doubleNegativePointsCell.layer addSublayer:border];
    
    border = [CALayer layer];
    border.frame = CGRectMake(0.0f, _doubleNegativePointsCell.frame.size.height - 1, _doubleNegativePointsCell.frame.size.width, 0.5f);
    border.backgroundColor = separatorColor.CGColor;
    [_doubleNegativePointsCell.layer addSublayer:border];
    
    _doubleNegativePointsSwitch.on = [NSUserDefaults.standardUserDefaults.dictionaryRepresentation objectForKey:@"doubleNegativePointsEnabled"] ? [NSUserDefaults.standardUserDefaults boolForKey:@"doubleNegativePointsEnabled"] : true;
    
    border = [CALayer layer];
    border.frame = CGRectMake(0.0f, 0.0f, _unvaluedSubjectsCell.frame.size.width, 0.5f);
    border.backgroundColor = separatorColor.CGColor;
    [_unvaluedSubjectsCell.layer addSublayer:border];
    
    border = [CALayer layer];
    border.frame = CGRectMake(0.0f, _unvaluedSubjectsCell.frame.size.height - 1, _unvaluedSubjectsCell.frame.size.width, 0.5f);
    border.backgroundColor = separatorColor.CGColor;
    [_unvaluedSubjectsCell.layer addSublayer:border];
    
    /*border = [CALayer layer];
    border.frame = CGRectMake(0.0f, 0.0f, _subjectGroupsCell.frame.size.width, 0.5f);
    border.backgroundColor = separatorColor.CGColor;
    [_subjectGroupsCell.layer addSublayer:border];*/
    
    border = [CALayer layer];
    border.frame = CGRectMake(0.0f, _subjectGroupsCell.frame.size.height - 1, _subjectGroupsCell.frame.size.width, 0.5f);
    border.backgroundColor = separatorColor.CGColor;
    [_subjectGroupsCell.layer addSublayer:border];
}

- (IBAction)doubleNegativePointsSwitched:(id)sender {
    [NSUserDefaults.standardUserDefaults setBool:_doubleNegativePointsSwitch.on forKey:@"doubleNegativePointsEnabled"];
    [NSUserDefaults.standardUserDefaults synchronize];
}
@end
