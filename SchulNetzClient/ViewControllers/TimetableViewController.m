#import "TimetableViewController.h"
#import "../Data/Lesson.h"
#import "../Views/TimetableView.h"
#import "../Variables.h"
#import "../Parser.h"
#import "../Util.h"

@interface TimetableViewController (){
    NSDate* timetableDate;
    NSMutableArray<Lesson*>* lessons;
}

@property (weak, nonatomic) IBOutlet TimetableView *timetableView;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (weak, nonatomic) IBOutlet UIButton *previousButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;
@property (weak, nonatomic) IBOutlet UILabel *noLessonsLabel;
@end

@implementation TimetableViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    timetableDate = [NSDate date];
    lessons = [[NSMutableArray alloc] init];
    
    _loadingIndicator.hidden = true;
    _loadingIndicator.color = [Util getTintColor];
    
    UITapGestureRecognizer* recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(datePressed:)];
    [_dateLabel setUserInteractionEnabled:true];
    [_dateLabel addGestureRecognizer:recognizer];
    
    _noLessonsLabel.hidden = true;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(viewDidAppear:) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    [self reload];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if(!self.view.window) return;
    
    [[Variables get].account loadPage:@"22202" completion:^(NSObject *doc) {
        if(doc && [doc class] == [HTMLDocument class]) [Parser parseSchedulePage:(HTMLDocument*)doc forUser:[Variables get].user];
    }];
    
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"d.M.yyyy";
    _dateLabel.text = [formatter stringFromDate:timetableDate];
    
    if(![Util checkConnection]){
        _previousButton.hidden = true;
        _nextButton.hidden = true;
        
        [self resetToTodayAndReload];
    } else{
        _previousButton.hidden = false;
        _nextButton.hidden = false;
        
        [self fetchAndReloadSchedule];
    }
}

-(void)resetToTodayAndReload{
    if(![Util checkConnection]){
        _previousButton.hidden = true;
        _nextButton.hidden = true;
    } else{
        _previousButton.hidden = false;
        _nextButton.hidden = false;
    }
    
    timetableDate = [NSDate date];
    lessons = [Variables get].user.lessons;
    
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"d.M.yyyy";
    _dateLabel.text = [formatter stringFromDate:timetableDate];
    
    if([Util checkConnection]) [self fetchAndReloadSchedule];
    else [self reload];
}

-(void)fetchAndReloadSchedule{
    NSDate* original = timetableDate;
    
    if([Util checkConnection]){
        _timetableView.hidden = true;
        _noLessonsLabel.hidden = true;
        _loadingIndicator.hidden = false;
        [self->_loadingIndicator startAnimating];
        
        [[Variables get].account loadScheduleFrom:original to:original view:@"day" completion:^(NSObject *doc) {
            if(doc && [doc class] == [HTMLDocument class] && [original compare:self->timetableDate] == NSOrderedSame){
                self->lessons = [Parser parseSchedule:(HTMLDocument*)doc];
                
                if(!self->lessons){
                    self->_loadingIndicator.hidden = true;
                    [self->_loadingIndicator stopAnimating];
                    self->_timetableView.hidden = false;
                    [self resetToTodayAndReload];
                    
                    return;
                } else{
                    [[Variables get].user processLessons:self->lessons];
                    self->_loadingIndicator.hidden = true;
                    [self->_loadingIndicator stopAnimating];
                    [self reload];
                }
            } else if([original compare:self->timetableDate] == NSOrderedSame){
                self->_loadingIndicator.hidden = true;
                [self->_loadingIndicator stopAnimating];
                self->_timetableView.hidden = false;
                [self resetToTodayAndReload];
                
                return;
            }
        }];
    } else{
        [self resetToTodayAndReload];
    }
}

-(void)reload{
    NSMutableArray* layoutedLessons = [self calculateLayout:lessons];
    
    if(layoutedLessons.count <= 0){
        _timetableView.hidden = true;
        _noLessonsLabel.hidden = false;
    } else{
        _timetableView.hidden = false;
        _noLessonsLabel.hidden = true;
    }
    
    _timetableView.lessons = layoutedLessons;
}

-(NSMutableArray<ScheduleLesson*>*)calculateLayout:(NSMutableArray<Lesson*>*)lessons{
    NSMutableArray<ScheduleLesson*>* result = [[NSMutableArray alloc] init];
    NSMutableArray<Lesson*>* sorted = [Lesson orderByStartTime:lessons];
    
    for(int i = 0; i < sorted.count; i++){
        if([sorted[i] longerThanOrEqualToOneDay]){
            [sorted removeObjectAtIndex:i];
            i--;
        }
    }
    
    NSMutableArray<ScheduleLesson*>* active = [[NSMutableArray alloc] init];
    int currentSplits = 0;
    for(int i = 0; i < sorted.count; i++){
        Lesson* l = sorted[i];
        active = [ScheduleLesson orderByEndTime:active];
        
        for(int i2 = 0; i2 < active.count; i2++){
            ScheduleLesson* al = active[i2];
            if([al.lesson.endDate compare:l.startDate] == NSOrderedDescending) break;
            
            al.end = al.lesson.endDate;
            [result addObject:al];
            
            NSMutableArray<ScheduleLesson*>* newActive = [[NSMutableArray alloc] init];
            int index = 0;
            for(int i3 = i2 + 1; i3 < active.count; i3++){
                ScheduleLesson* al2 = active[i3];
                if(al == al2) continue;
                
                if(al.lesson.endDate.timeIntervalSince1970 == al2.lesson.endDate.timeIntervalSince1970){
                    al2.end = al.lesson.endDate;
                    [result addObject:al2];
                } else{
                    ScheduleLesson* newSplitLesson = [[ScheduleLesson alloc] init];
                    al2.end = al.lesson.endDate;
                    [result addObject:al2];
                    
                    newSplitLesson.lesson = al2.lesson;
                    newSplitLesson.start = al.lesson.endDate;
                    newSplitLesson.index = index;
                    [newActive addObject:newSplitLesson];
                    index++;
                }
            }
            
            for(ScheduleLesson* al2 in newActive) al2.total = index;
            currentSplits = index;
            
            active = [ScheduleLesson orderByEndTime:newActive];
            i2 = -1;
        }
        
        ScheduleLesson* scheduleLesson = [[ScheduleLesson alloc] init];
        scheduleLesson.lesson = l;
        scheduleLesson.start = l.startDate;
        
        NSMutableArray<ScheduleLesson*>* newActive = [[NSMutableArray alloc] init];
        int index = 0;
        for(int i2 = 0; i2 < active.count; i2++){
            ScheduleLesson* al = active[i2];
            
            ScheduleLesson* newSplitLesson = [[ScheduleLesson alloc] init];
            al.end = l.startDate;
            if(al.start.timeIntervalSince1970 != al.end.timeIntervalSince1970) [result addObject:al];
            
            newSplitLesson.lesson = al.lesson;
            newSplitLesson.start = l.startDate;
            
            newSplitLesson.index = index;
            [newActive addObject:newSplitLesson];
            index++;
        }
        
        for(ScheduleLesson* al in newActive) al.total = index + 1;
        currentSplits = index;
        
        active = [ScheduleLesson orderByEndTime:newActive];
        
        scheduleLesson.index = currentSplits;
        currentSplits++;
        scheduleLesson.total = currentSplits;
        [active addObject:scheduleLesson];
        
        NSDateComponents* c1 = [[NSCalendar currentCalendar] components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute fromDate:[[NSDate alloc] initWithTimeIntervalSince1970:l.startDate.timeIntervalSince1970]];
        c1.minute = 0;
        c1.hour = 0;
        
        NSDateComponents* c2 = [[NSCalendar currentCalendar] components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute fromDate:[[NSDate alloc] initWithTimeIntervalSince1970:(i + 1 < sorted.count ? sorted[i + 1].startDate.timeIntervalSince1970 : 0)]];
        c2.minute = 0;
        c2.hour = 0;
        
        if(i + 1 < sorted.count && [[[NSCalendar currentCalendar] dateFromComponents:c2] compare:[[NSCalendar currentCalendar] dateFromComponents:c1]] == NSOrderedDescending){
            NSMutableArray<ScheduleLesson*>* newActive2 = [[NSMutableArray alloc] init];
            int index2 = 0;
            for(int i2 = 0; i2 < active.count; i2++){
                ScheduleLesson* al = active[i2];
                
                NSDateComponents* c = [[NSCalendar currentCalendar] components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute fromDate:[[NSDate alloc] initWithTimeIntervalSince1970:l.startDate.timeIntervalSince1970]];
                c.minute = 0;
                c.hour = 0;
                
                NSDate* d = [[NSCalendar currentCalendar] dateFromComponents:c];
                
                NSDateComponents* comp = [[NSDateComponents alloc] init];
                comp.day = 1;
                
                d = [[NSCalendar currentCalendar] dateByAddingComponents:comp toDate:d options:0];
                
                ScheduleLesson* newSplitLesson = [[ScheduleLesson alloc] init];
                al.end = d;
                if(al.start.timeIntervalSince1970 == al.end.timeIntervalSince1970) [result addObject:al];
                
                newSplitLesson.lesson = al.lesson;
                newSplitLesson.start = d;
                newSplitLesson.index = index2;
                [newActive2 addObject:newSplitLesson];
                index2++;
            }
            
            for(ScheduleLesson* al in newActive2) al.total = index2;
            currentSplits = index2;
            
            active = [ScheduleLesson orderByEndTime:newActive2];
        }
    }
    
    active = [ScheduleLesson orderByEndTime:active];
    
    for(int i2 = 0; i2 < active.count; i2++){
        ScheduleLesson* al = active[i2];
        
        al.end = al.lesson.endDate;
        [result addObject:al];
        
        NSMutableArray<ScheduleLesson*>* newActive = [[NSMutableArray alloc] init];
        int index = 0;
        for(int i3 = i2 + 1; i3 < active.count; i3++){
            ScheduleLesson* al2 = active[i3];
            if(al == al2) continue;
            
            if(al.lesson.endDate.timeIntervalSince1970 == al2.lesson.endDate.timeIntervalSince1970){
                al2.end = al.lesson.endDate;
                [result addObject:al2];
            } else{
                ScheduleLesson* newSplitLesson = [[ScheduleLesson alloc] init];
                al2.end = al.lesson.endDate;
                [result addObject:al2];
                
                newSplitLesson.lesson = al2.lesson;
                newSplitLesson.start = al.lesson.endDate;
                newSplitLesson.index = index;
                [newActive addObject:newSplitLesson];
                index++;
            }
        }
        
        for(ScheduleLesson* al2 in newActive) al2.total = index;
        currentSplits = index;
        
        active = [ScheduleLesson orderByEndTime:newActive];
        i2 = -1;
    }
    
    return result;
}

- (void)datePressed:(UIGestureRecognizer*)recognizer {
    if([Util checkConnection]){
        timetableDate = [NSDate date];
        
        NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"d.M.yyyy";
        _dateLabel.text = [formatter stringFromDate:timetableDate];
        
        [self fetchAndReloadSchedule];
    } else [self resetToTodayAndReload];
}

- (IBAction)nextPressed:(id)sender {
    if([Util checkConnection]){
        timetableDate = [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitDay value:1 toDate:timetableDate options:0];
        
        NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"d.M.yyyy";
        _dateLabel.text = [formatter stringFromDate:timetableDate];
        
        [self fetchAndReloadSchedule];
    } else [self resetToTodayAndReload];
}

- (IBAction)previousPressed:(id)sender {
    if([Util checkConnection]){
        timetableDate = [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitDay value:-1 toDate:timetableDate options:0];
        
        NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"d.M.yyyy";
        _dateLabel.text = [formatter stringFromDate:timetableDate];
        
        [self fetchAndReloadSchedule];
    } else [self resetToTodayAndReload];
}
@end
