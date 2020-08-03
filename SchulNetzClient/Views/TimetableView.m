#import "TimetableView.h"
#import "../Util.h"

@implementation TimetableView
@synthesize lessons = _lessons;

- (void)drawRect:(CGRect)rect{
    if(!_lessons) return;
    
    UIFont* font = [UIFont systemFontOfSize:14];
    
    int minHour = 0;
    int maxHour = 24;
    
    CGSize timeBounds = [@"00:00" sizeWithAttributes:@{NSFontAttributeName:font}];
    
    float topOffset = timeBounds.height / 2;
    float bottomOffset = timeBounds.height / 2;
    float leftOffset = timeBounds.width + 12;
    
    NSMutableArray<ScheduleLesson*>* startOrdered = [ScheduleLesson orderByStartTime:_lessons];
    if(startOrdered.count > 0) minHour = (int)[[NSCalendar currentCalendar] component:NSCalendarUnitHour fromDate:startOrdered[0].start];
    
    NSMutableArray<ScheduleLesson*>* endOrdered = [ScheduleLesson orderByEndTime:_lessons];
    if(endOrdered.count > 0) maxHour = MIN((int)[[NSCalendar currentCalendar] component:NSCalendarUnitHour fromDate:endOrdered[endOrdered.count - 1].end] + 1, 24);
    
    float heightPerMinute = (rect.size.height - topOffset - bottomOffset) / (maxHour - minHour) / 60.f;
    
    NSDictionary* sideTimeAttributes = @{NSFontAttributeName:font, NSForegroundColorAttributeName:UIColor.lightGrayColor};
    for(int i = minHour;i <= maxHour; i++){
        NSAttributedString* str = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%02d:00", i] attributes:sideTimeAttributes];
        [str drawAtPoint:CGPointMake(0, (i - minHour) * 60 * heightPerMinute)];
        
        UIBezierPath* line = [UIBezierPath bezierPath];
        [line moveToPoint:CGPointMake(leftOffset - 8, (i - minHour) * 60 * heightPerMinute + timeBounds.height / 2)];
        [line addLineToPoint:CGPointMake(self.bounds.size.width, (i - minHour) * 60 * heightPerMinute + timeBounds.height / 2)];
        [line stroke];
    }
    
    NSDateComponents* c = [[NSCalendar currentCalendar] components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute fromDate:[[NSDate alloc] initWithTimeIntervalSince1970:(_lessons.count > 0 ? _lessons[0].start.timeIntervalSince1970 : 0)]];
    c.minute = 0;
    c.hour = 0;
    
    NSDate* d = [[NSCalendar currentCalendar] dateFromComponents:c];
    
    NSDateComponents* comp = [[NSDateComponents alloc] init];
    comp.day = 1;
    
    d = [[NSCalendar currentCalendar] dateByAddingComponents:comp toDate:d options:0];
    
    for(ScheduleLesson* l in _lessons){
        if([l.start compare:d] == NSOrderedDescending) continue;
        
        UIColor* primary = l.lesson.color;
        UIColor* secondary = [Util darkenColor:primary];
        
        NSDictionary* textAttributes = @{NSFontAttributeName:font, NSForegroundColorAttributeName:secondary};
        
        float y = [[NSCalendar currentCalendar] component:NSCalendarUnitMinute fromDate:l.start] + ([[NSCalendar currentCalendar] component:NSCalendarUnitHour fromDate:l.start] - minHour) * 60;
        float height = [[NSCalendar currentCalendar] component:NSCalendarUnitMinute fromDate:l.end] + ([[NSCalendar currentCalendar] component:NSCalendarUnitHour fromDate:l.end] - minHour) * 60 - y;
        if([l.end compare:d] == NSOrderedSame) height = (maxHour - minHour) * 60 * 60;
        float width = (self.bounds.size.width - leftOffset) / (float)l.total;
        float x = l.index * width;
        
        NSString* title = @"";
        if(l.lesson.subject){
            title = [NSString stringWithFormat:@"%@ [%@]", (l.lesson.subject.name ? l.lesson.subject.name : l.lesson.subject.shortName), l.lesson.room];
            if(width < [title sizeWithAttributes:@{NSFontAttributeName:font}].width + 24 + timeBounds.width) title = [NSString stringWithFormat:@"%@ [%@]", l.lesson.subject.shortName, l.lesson.room];
            if(width < [title sizeWithAttributes:@{NSFontAttributeName:font}].width + 24 + timeBounds.width) title = [NSString stringWithFormat:@"%@", (l.lesson.subject.name ? l.lesson.subject.name : l.lesson.subject.shortName)];
            if(width < [title sizeWithAttributes:@{NSFontAttributeName:font}].width + 24 + timeBounds.width) title = [NSString stringWithFormat:@"%@", l.lesson.subject.shortName];
        } else{
            title = [NSString stringWithFormat:@"%@ [%@]", l.lesson.lessonIdentifier, l.lesson.room];
            if(width < [title sizeWithAttributes:@{NSFontAttributeName:font}].width + 24 + timeBounds.width) title = l.lesson.lessonIdentifier;
        }
        
        CGSize stringBounds = [title sizeWithAttributes:@{NSFontAttributeName:font}];
        
        UIBezierPath* path = [UIBezierPath bezierPathWithRect:CGRectMake(leftOffset + x, topOffset + y * heightPerMinute, width, height * heightPerMinute)];
        path.lineWidth = 3.f;
        [primary set];
        [path fill];
        
        path = [UIBezierPath bezierPathWithRect:CGRectMake(leftOffset + x + path.lineWidth / 2.f, topOffset + y * heightPerMinute + path.lineWidth / 2.f, width - path.lineWidth, height * heightPerMinute - path.lineWidth)];
        path.lineWidth = 3.f;
        [secondary set];
        [path stroke];
        
        if(height * heightPerMinute / 1.5f >= stringBounds.height && width >= stringBounds.width + 24 + timeBounds.width){
            NSAttributedString* str = [[NSAttributedString alloc] initWithString:title attributes:textAttributes];
            [str drawAtPoint:CGPointMake(leftOffset + x + 8, topOffset + (y + height / 2) * heightPerMinute - stringBounds.height / 2)];
        }
        
        if(height * heightPerMinute >= timeBounds.height * 2 + 2 * path.lineWidth && width >= timeBounds.width + 2 * 8){
            NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
            formatter.dateFormat = @"HH:mm";
            
            NSAttributedString* str = [[NSAttributedString alloc] initWithString:[formatter stringFromDate:l.start] attributes:textAttributes];
            [str drawAtPoint:CGPointMake(leftOffset + x + width - timeBounds.width - 8, topOffset + y * heightPerMinute + path.lineWidth)];
            
            str = [[NSAttributedString alloc] initWithString:[formatter stringFromDate:l.end] attributes:textAttributes];
            [str drawAtPoint:CGPointMake(leftOffset + x + width - timeBounds.width - 8, topOffset + (y + height) * heightPerMinute - path.lineWidth - timeBounds.height)];
        }
    }
}

-(void)setLessons:(NSMutableArray<ScheduleLesson*>*)lessons{
    _lessons = lessons;
    [self setNeedsDisplay];
}
@end
