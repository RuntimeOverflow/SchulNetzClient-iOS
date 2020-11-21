#import "Change.h"
#import <UserNotifications/UserNotifications.h>
#import "../Util.h"

@implementation Change
@synthesize previous;
@synthesize current;

@synthesize varName;

@synthesize type;

-(instancetype)initWithPrevious:(NSObject*)previousObject current:(NSObject*)currentObject varName:(NSString*)variableName changeType:(ChangeType)changeType{
    previous = previousObject;
    current = currentObject;
    
    varName = variableName;
    
    type = changeType;
    
    return self;
}

+(NSMutableArray*)getChanges:(User*)previous current:(User*)current{
    NSMutableArray* changes = [[NSMutableArray alloc] init];
    if(!previous || !current) return changes;
    
    if(previous.balanceConfirmed != current.balanceConfirmed) [changes addObject:[[Change alloc] initWithPrevious:previous current:current varName:@"balanceConfirmed" changeType:MODIFIED]];
    
    int previousIndex = 0;
    int currentIndex = 0;
    while(previousIndex < previous.teachers.count || currentIndex < current.teachers.count){
        Teacher* previousTeacher = previousIndex < previous.teachers.count ? previous.teachers[previousIndex] : NULL;
        Teacher* currentTeacher = currentIndex < current.teachers.count ? current.teachers[currentIndex] : NULL;
        
        if(previousTeacher && [previousTeacher isEqual:currentTeacher]) {
            if(![previousTeacher.firstName isEqual:currentTeacher.firstName]) [changes addObject:[[Change alloc] initWithPrevious:previousTeacher current:currentTeacher varName:@"firstName" changeType:MODIFIED]];
            if(![previousTeacher.lastName isEqual:currentTeacher.lastName]) [changes addObject:[[Change alloc] initWithPrevious:previousTeacher current:currentTeacher varName:@"lastName" changeType:MODIFIED]];
            if((previousTeacher.mail == NULL ^ currentTeacher.mail == NULL) || (previousTeacher.mail && ![previousTeacher.mail isEqual:currentTeacher.mail])) [changes addObject:[[Change alloc] initWithPrevious:previousTeacher current:currentTeacher varName:@"mail" changeType:MODIFIED]];
            
            previousIndex++;
            currentIndex++;
        } else if(previousTeacher && ![current.teachers containsObject:previousTeacher]) {
            [changes addObject:[[Change alloc] initWithPrevious:previousTeacher current:NULL varName:@"" changeType:REMOVED]];
            
            previousIndex++;
        } else if(currentTeacher && ![previous.teachers containsObject:currentTeacher]) {
            [changes addObject:[[Change alloc] initWithPrevious:NULL current:currentTeacher varName:@"" changeType:ADDED]];
            
            currentIndex++;
        } else{
            previousIndex++;
            currentIndex++;
        }
    }
    
    previousIndex = 0;
    currentIndex = 0;
    while(previousIndex < previous.students.count || currentIndex < current.students.count){
        Student* previousStudent = previousIndex < previous.students.count ? previous.students[previousIndex] : NULL;
        Student* currentStudent = currentIndex < current.students.count ? current.students[currentIndex] : NULL;
        
        if(previousStudent && [previousStudent isEqual:currentStudent]) {
            if(previousStudent.gender != currentStudent.gender) [changes addObject:[[Change alloc] initWithPrevious:previousStudent current:currentStudent varName:@"gender" changeType:MODIFIED]];
            if(![previousStudent.degree isEqual:currentStudent.degree]) [changes addObject:[[Change alloc] initWithPrevious:previousStudent current:currentStudent varName:@"degree" changeType:MODIFIED]];
            if(previousStudent.bilingual != currentStudent.bilingual) [changes addObject:[[Change alloc] initWithPrevious:previousStudent current:currentStudent varName:@"bilingual" changeType:MODIFIED]];
            if(![previousStudent.className isEqual:currentStudent.className]) [changes addObject:[[Change alloc] initWithPrevious:previousStudent current:currentStudent varName:@"className" changeType:MODIFIED]];
            if(![previousStudent.address isEqual:currentStudent.address]) [changes addObject:[[Change alloc] initWithPrevious:previousStudent current:currentStudent varName:@"address" changeType:MODIFIED]];
            if(previousStudent.zipCode != currentStudent.zipCode) [changes addObject:[[Change alloc] initWithPrevious:previousStudent current:currentStudent varName:@"zipCode" changeType:MODIFIED]];
            if(![previousStudent.city isEqual:currentStudent.city]) [changes addObject:[[Change alloc] initWithPrevious:previousStudent current:currentStudent varName:@"city" changeType:MODIFIED]];
            if(![previousStudent.phone isEqual:currentStudent.phone]) [changes addObject:[[Change alloc] initWithPrevious:previousStudent current:currentStudent varName:@"phone" changeType:MODIFIED]];
            if(previousStudent.dateOfBirth.timeIntervalSince1970 != currentStudent.dateOfBirth.timeIntervalSince1970) [changes addObject:[[Change alloc] initWithPrevious:previousStudent current:currentStudent varName:@"dateOfBirth" changeType:MODIFIED]];
            if(![previousStudent.additionalClasses isEqual:currentStudent.additionalClasses]) [changes addObject:[[Change alloc] initWithPrevious:previousStudent current:currentStudent varName:@"additionalClasses" changeType:MODIFIED]];
            if(![previousStudent.status isEqual:currentStudent.status]) [changes addObject:[[Change alloc] initWithPrevious:previousStudent current:currentStudent varName:@"status" changeType:MODIFIED]];
            if(![previousStudent.placeOfWork isEqual:currentStudent.placeOfWork]) [changes addObject:[[Change alloc] initWithPrevious:previousStudent current:currentStudent varName:@"placeOfWork" changeType:MODIFIED]];
            if(previousStudent.self != currentStudent.self) [changes addObject:[[Change alloc] initWithPrevious:previousStudent current:currentStudent varName:@"self" changeType:MODIFIED]];
            
            previousIndex++;
            currentIndex++;
        } else if(previousStudent && ![current.students containsObject:previousStudent]) {
            [changes addObject:[[Change alloc] initWithPrevious:previousStudent current:NULL varName:@"" changeType:REMOVED]];
            
            previousIndex++;
        } else if(currentStudent && ![previous.students containsObject:currentStudent]) {
            [changes addObject:[[Change alloc] initWithPrevious:NULL current:currentStudent varName:@"" changeType:ADDED]];
            
            currentIndex++;
        } else{
            previousIndex++;
            currentIndex++;
        }
    }
    
    previousIndex = 0;
    currentIndex = 0;
    while(previousIndex < previous.subjects.count || currentIndex < current.subjects.count){
        Subject* previousSubject = previousIndex < previous.subjects.count ? previous.subjects[previousIndex] : NULL;
        Subject* currentSubject = currentIndex < current.subjects.count ? current.subjects[currentIndex] : NULL;
        
        if(previousSubject && [previousSubject isEqual:currentSubject]) {
            if(![previousSubject.identifier isEqual:currentSubject.identifier]) [changes addObject:[[Change alloc] initWithPrevious:previousSubject current:currentSubject varName:@"identifier" changeType:MODIFIED]];
            if((previousSubject.name == NULL ^ currentSubject.name == NULL) || (previousSubject.name && ![previousSubject.name isEqual:currentSubject.name])) [changes addObject:[[Change alloc] initWithPrevious:previousSubject current:currentSubject varName:@"name" changeType:MODIFIED]];
            if(previousSubject.confirmed != currentSubject.confirmed) [changes addObject:[[Change alloc] initWithPrevious:previousSubject current:currentSubject varName:@"confirmed" changeType:MODIFIED]];
            if(previousSubject.hiddenGrades != currentSubject.hiddenGrades) [changes addObject:[[Change alloc] initWithPrevious:previousSubject current:currentSubject varName:@"hiddenGrades" changeType:MODIFIED]];
            
            previousIndex++;
            currentIndex++;
            
            int previousSubIndex = 0;
            int currentSubIndex = 0;
            while(previousSubIndex < previousSubject.grades.count || currentSubIndex < currentSubject.grades.count){
                Grade* previousGrade = previousSubIndex < previousSubject.grades.count ? previousSubject.grades[previousSubIndex] : NULL;
                Grade* currentGrade = currentSubIndex < currentSubject.grades.count ? currentSubject.grades[currentSubIndex] : NULL;
                
                if(previousGrade && [previousGrade isEqual:currentGrade]) {
                    if((previousGrade.date == NULL ^ currentGrade.date == NULL) || (previousGrade.date && previousGrade.date.timeIntervalSince1970 != currentGrade.date.timeIntervalSince1970)) [changes addObject:[[Change alloc] initWithPrevious:previousGrade current:currentGrade varName:@"date" changeType:MODIFIED]];
                    else if(previousGrade.grade != currentGrade.grade) [changes addObject:[[Change alloc] initWithPrevious:previousGrade current:currentGrade varName:@"grade" changeType:MODIFIED]];
                    else if((previousGrade.details == NULL ^ currentGrade.details == NULL) || (previousGrade.details && ![previousGrade.details isEqual:currentGrade.details])) [changes addObject:[[Change alloc] initWithPrevious:previousGrade current:currentGrade varName:@"details" changeType:MODIFIED]];
                    else if(previousGrade.weight != currentGrade.weight) [changes addObject:[[Change alloc] initWithPrevious:previousGrade current:currentGrade varName:@"weight" changeType:MODIFIED]];
                    
                    previousSubIndex++;
                    currentSubIndex++;
                } else if(previousGrade && ![currentSubject.grades containsObject:previousGrade]) {
                    [changes addObject:[[Change alloc] initWithPrevious:previousGrade current:NULL varName:@"" changeType:REMOVED]];
                    
                    previousSubIndex++;
                } else if(currentGrade && ![previousSubject.grades containsObject:currentGrade]) {
                    [changes addObject:[[Change alloc] initWithPrevious:NULL current:currentGrade varName:@"" changeType:ADDED]];
                    
                    currentSubIndex++;
                } else{
                    previousSubIndex++;
                    currentSubIndex++;
                }
            }
        } else if(previousSubject && ![current.subjects containsObject:previousSubject]) {
            [changes addObject:[[Change alloc] initWithPrevious:previousSubject current:NULL varName:@"" changeType:REMOVED]];
            
            previousIndex++;
        } else if(currentSubject && ![previous.subjects containsObject:currentSubject]) {
            [changes addObject:[[Change alloc] initWithPrevious:NULL current:currentSubject varName:@"" changeType:ADDED]];
            
            currentIndex++;
        } else{
            previousIndex++;
            currentIndex++;
        }
    }
    
    previousIndex = 0;
    currentIndex = 0;
    while(previousIndex < previous.transactions.count || currentIndex < current.transactions.count){
        Transaction* previousTransaction = previousIndex < previous.transactions.count ? previous.transactions[previousIndex] : NULL;
        Transaction* currentTransaction = currentIndex < current.transactions.count ? current.transactions[currentIndex] : NULL;
        
        if(previousTransaction && [previousTransaction isEqual:currentTransaction]) {
            if(previousTransaction.date.timeIntervalSince1970 != currentTransaction.date.timeIntervalSince1970) [changes addObject:[[Change alloc] initWithPrevious:previousTransaction current:currentTransaction varName:@"date" changeType:MODIFIED]];
            if(previousTransaction.amount != currentTransaction.amount) [changes addObject:[[Change alloc] initWithPrevious:previousTransaction current:currentTransaction varName:@"amount" changeType:MODIFIED]];
            
            previousIndex++;
            currentIndex++;
        } else if(previousTransaction && ![current.transactions containsObject:previousTransaction]) {
            [changes addObject:[[Change alloc] initWithPrevious:previousTransaction current:NULL varName:@"" changeType:REMOVED]];
            
            previousIndex++;
        } else if(currentTransaction && ![previous.transactions containsObject:currentTransaction]) {
            [changes addObject:[[Change alloc] initWithPrevious:NULL current:currentTransaction varName:@"" changeType:ADDED]];
            
            currentIndex++;
        } else{
            previousIndex++;
            currentIndex++;
        }
    }
    
    previousIndex = 0;
    currentIndex = 0;
    while(previousIndex < previous.absences.count || currentIndex < current.absences.count){
        Absence* previousAbsence = previousIndex < previous.absences.count ? previous.absences[previousIndex] : NULL;
        Absence* currentAbsence = currentIndex < current.absences.count ? current.absences[currentIndex] : NULL;
        
        if(previousAbsence && [previousAbsence isEqual:currentAbsence]) {
            if(previousAbsence.startDate.timeIntervalSince1970 != currentAbsence.startDate.timeIntervalSince1970) [changes addObject:[[Change alloc] initWithPrevious:previousAbsence current:currentAbsence varName:@"startDate" changeType:MODIFIED]];
            if(previousAbsence.endDate.timeIntervalSince1970 != currentAbsence.endDate.timeIntervalSince1970) [changes addObject:[[Change alloc] initWithPrevious:previousAbsence current:currentAbsence varName:@"endDate" changeType:MODIFIED]];
            if((previousAbsence.additionalInformation == NULL ^ currentAbsence.additionalInformation == NULL) || (previousAbsence.additionalInformation && ![previousAbsence.additionalInformation isEqual:currentAbsence.additionalInformation])) [changes addObject:[[Change alloc] initWithPrevious:previousAbsence current:currentAbsence varName:@"additionalInformation" changeType:MODIFIED]];
            if(previousAbsence.lessonCount != currentAbsence.lessonCount) [changes addObject:[[Change alloc] initWithPrevious:previousAbsence current:currentAbsence varName:@"lessonCount" changeType:MODIFIED]];
            if(previousAbsence.excused != currentAbsence.excused) [changes addObject:[[Change alloc] initWithPrevious:previousAbsence current:currentAbsence varName:@"excused" changeType:MODIFIED]];
            
            previousIndex++;
            currentIndex++;
        } else if(previousAbsence && ![current.absences containsObject:previousAbsence]) {
            [changes addObject:[[Change alloc] initWithPrevious:previousAbsence current:NULL varName:@"" changeType:REMOVED]];
            
            previousIndex++;
        } else if(currentAbsence && ![previous.absences containsObject:currentAbsence]) {
            [changes addObject:[[Change alloc] initWithPrevious:NULL current:currentAbsence varName:@"" changeType:ADDED]];
            
            currentIndex++;
        } else{
            previousIndex++;
            currentIndex++;
        }
    }
    
    return changes;
}

+(void)publishNotifications:(NSArray<Change*>*)changes{
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"notificationsEnabled"]) for(Change* change in changes){
        Class c = NULL;
        
        if(change.previous) c = [change.previous class];
        else if(change.current) c = [change.current class];
        else continue;
        
        if(c == [Grade class]){
            if((change.type == ADDED && ((Grade*)change.current).grade != 0) || (change.type == MODIFIED && [change.varName isEqualToString:@"grade"] && ((Grade*)change.previous).grade == 0)){
                [self sendNotificationWithTitle:NSLocalizedString(@"newGrade", @"") withContent:[NSString stringWithFormat:@"[%@] %@: %@", ((Grade*)change.current).subject.name, ((Grade*)change.current).content, [NSNumber numberWithDouble:((Grade*)change.current).grade].stringValue]];
            } else if(change.type == MODIFIED && [change.varName isEqualToString:@"grade"] && ((Grade*)change.current).grade == 0){
                [self sendNotificationWithTitle:NSLocalizedString(@"modifiedGrade", @"") withContent:[NSString stringWithFormat:@"[%@] %@: %@ -> %@", ((Grade*)change.current).subject.name, ((Grade*)change.current).content, [NSNumber numberWithDouble:((Grade*)change.previous).grade].stringValue, [NSNumber numberWithDouble:((Grade*)change.current).grade].stringValue]];
            }
        } else if(c == [Absence class]){
            if(change.type == ADDED){
                NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
                NSString* body = [NSString stringWithFormat:@"%@%@ (%@)", [formatter stringFromDate:((Absence*)change.current).startDate], (((Absence*)change.current).startDate.timeIntervalSince1970 != ((Absence*)change.current).endDate.timeIntervalSince1970 ? [NSString stringWithFormat:@" - %@", [formatter stringFromDate:((Absence*)change.current).endDate]] : @""), [NSString stringWithFormat:@"%@ %@", [NSNumber numberWithInt:((Absence*)change.current).lessonCount].stringValue, (((Absence*)change.current).lessonCount != 1 ? NSLocalizedString(@"lessons", @"") : NSLocalizedString(@"lesson", @""))]];
                [self sendNotificationWithTitle:(((Absence*)change.current).excused ? NSLocalizedString(@"newExcusedAbsence", @"") : NSLocalizedString(@"newAbsence", @"")) withContent:body];
            } else if(change.type == MODIFIED && [change.varName isEqualToString:@"excused"] && ((Absence*)change.current).excused){
                NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
                NSString* body = [NSString stringWithFormat:@"%@%@ (%@)", [formatter stringFromDate:((Absence*)change.current).startDate], (((Absence*)change.current).startDate.timeIntervalSince1970 != ((Absence*)change.current).endDate.timeIntervalSince1970 ? [NSString stringWithFormat:@" - %@", [formatter stringFromDate:((Absence*)change.current).endDate]] : @""), [NSString stringWithFormat:@"%@ %@", [NSNumber numberWithInt:((Absence*)change.current).lessonCount].stringValue, (((Absence*)change.current).lessonCount != 1 ? NSLocalizedString(@"lessons", @"") : NSLocalizedString(@"lesson", @""))]];
                [self sendNotificationWithTitle:NSLocalizedString(@"excusedAbsence", @"") withContent:body];
            }
        } else if(c == [Transaction class]){
            if(change.type == ADDED){
                [self sendNotificationWithTitle:NSLocalizedString(@"newTransaction", @"") withContent:[NSString stringWithFormat:@"%@ -> %.2f", ((Transaction*)change.current).reason, ((Transaction*)change.current).amount]];
            }
        }
    }
}

+(void)sendNotificationWithTitle:(NSString*)title withContent:(NSString*)content{
    if([Util notificationsAllowed]){
        UNMutableNotificationContent* notificationContent = [[UNMutableNotificationContent alloc] init];
        notificationContent.title = title;
        notificationContent.body = content;
        notificationContent.categoryIdentifier = @"GENERAL";
        if([Util soundsAllowed]) notificationContent.sound = [UNNotificationSound defaultSound];

        UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:0.001 repeats:NO];
        
        UNNotificationRequest* request = [UNNotificationRequest
               requestWithIdentifier:[[NSProcessInfo processInfo] globallyUniqueString] content:notificationContent trigger:trigger];
        
        UNUserNotificationCenter* center = [UNUserNotificationCenter currentNotificationCenter];
        [center addNotificationRequest:request withCompletionHandler:^(NSError* error) {
           
        }];
    }
}
@end
