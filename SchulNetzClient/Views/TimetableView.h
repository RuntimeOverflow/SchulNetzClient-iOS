#import <UIKit/UIKit.h>
#import "../Data/Lesson.h"

@interface TimetableView : UIView
@property (nonatomic, setter=setLessons:) NSMutableArray<ScheduleLesson*>* lessons;

-(void)setLessons:(NSMutableArray<ScheduleLesson*>*)lessons;
@end
