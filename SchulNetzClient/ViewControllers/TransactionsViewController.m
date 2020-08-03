#import "TransactionsViewController.h"
#import "../Variables.h"
#import "../Parser.h"

@interface TransactionCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *reasonLabel;
@property (weak, nonatomic) IBOutlet UILabel *amountLabel;
@end

@implementation TransactionCell
@end

@interface TransactionsViewController (){
    double balance;
    NSMutableArray<NSNumber*>* expanded;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation TransactionsViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    balance = 0;
    expanded = [[NSMutableArray alloc] init];
    
    for(int i = 0; i < [Variables get].user.transactions.count; i++){
        balance += [Variables get].user.transactions[i].amount;
        expanded[i] = [NSNumber numberWithBool:false];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    TransactionCell* cell = [tableView dequeueReusableCellWithIdentifier:@"transactionCell"];
    
    if(indexPath.row < [Variables get].user.transactions.count){
        NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"dd. MMMM yyyy";
        
        cell.reasonLabel.text = [NSString stringWithFormat:@"%@%@", [Variables get].user.transactions[indexPath.row].reason, (expanded[indexPath.row].boolValue ? [NSString stringWithFormat:@" (%@)", [formatter stringFromDate:[Variables get].user.transactions[indexPath.row].date]] : @"")];
        cell.reasonLabel.font = [UIFont systemFontOfSize:17.0f];
        if(!expanded[indexPath.row].boolValue){
            cell.reasonLabel.numberOfLines = 1;
            cell.reasonLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        } else{
            cell.reasonLabel.numberOfLines = 0;
            cell.reasonLabel.lineBreakMode = NSLineBreakByWordWrapping;
        }
        
        cell.amountLabel.text = [NSString stringWithFormat:@"%@%.2f", ([Variables get].user.transactions[indexPath.row].amount >= 0 ? @"+" : @"-"), fabs([Variables get].user.transactions[indexPath.row].amount)];
        cell.amountLabel.font = [UIFont systemFontOfSize:17.0f weight:UIFontWeightBold];
        cell.amountLabel.textColor = [Variables get].user.transactions[indexPath.row].amount >= 0 ? [UIColor colorWithRed:0 green:1 blue:0 alpha:1] : [UIColor colorWithRed:1 green:0 blue:0 alpha:1];
    } else{
        cell.reasonLabel.text = NSLocalizedString(@"balance", @"");
        cell.reasonLabel.font = [UIFont systemFontOfSize:25.0f];
        
        cell.amountLabel.text = [NSString stringWithFormat:@"%.2f", balance];
        cell.amountLabel.font = [UIFont systemFontOfSize:25.0f weight:UIFontWeightBold];
        cell.amountLabel.textColor = balance >= 0 ? [UIColor colorWithRed:0 green:1 blue:0 alpha:1] : [UIColor colorWithRed:1 green:0 blue:0 alpha:1];
    }
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [Variables get].user.transactions.count + 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:false];
    
    if(indexPath.row < expanded.count) expanded[indexPath.row] = [NSNumber numberWithBool:!expanded[indexPath.row].boolValue];
    
    [tableView reloadData];
}
@end
