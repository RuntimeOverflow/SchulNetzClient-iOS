#import "Parser.h"
#import "Account.h"
#import "Data/Data.h"
#import "Libraries/TBXML/TBXML.h"
#import "Variables.h"

@implementation Parser
static User* user;

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
+(void) parsePage: (HTMLDocument*) src pageId: (int) pageId{
    user = [Variables get].user;
    
    SEL parseMethod = NSSelectorFromString([@"" stringByAppendingFormat: @"parse%@:", [[Parser getName:pageId] capitalizedString]]);
    
    if([self respondsToSelector:parseMethod]) [self performSelector:parseMethod withObject:src];
    
    [Variables get].user = user;
}
#pragma clang diagnostic pop

+(void) parseGrades: (HTMLDocument*) src{
    NSMutableArray<HTMLNode*>* rows = [[NSMutableArray alloc] initWithArray:[[src firstNodeMatchingSelector:@"table"] firstNodeMatchingSelector:@"tbody"].childElementNodes];
    [rows removeObjectAtIndex:0];
    
    for(int i = 0; i < rows.count / 3; i++){
        HTMLNode* main = [rows objectAtIndex:i * 3];
        NSMutableArray<HTMLNode*>* gradeNodes = [[NSMutableArray alloc] initWithArray:[[rows objectAtIndex:i * 3 + 1] firstNodeMatchingSelector:@"tbody"].childElementNodes];
        
        if(gradeNodes.count >= 2) {
            [gradeNodes removeObjectAtIndex:0];
            [gradeNodes removeObjectAtIndex:gradeNodes.count - 1];
        }
        
        Subject* subject = [[Subject alloc] init];
        subject.identifier = [[[[main.childElementNodes objectAtIndex:0].childElementNodes objectAtIndex:0].textComponents objectAtIndex:0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        subject.name = [[[main.childElementNodes objectAtIndex:0].textComponents objectAtIndex:0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        subject.shortName = [subject.identifier substringToIndex:[subject.identifier rangeOfString:@"-"].location + 1];
        subject.confirmed = [main.childElementNodes objectAtIndex:3].childElementNodes.count < 1;
        subject.hiddenGrades = [[[main.childElementNodes objectAtIndex:1].textComponents[0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] containsString:@"*"];
        
        for(HTMLNode* gradeNode in gradeNodes){
            Grade* g = [[Grade alloc] init];
            
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"dd.MM.yyyy"];
            g.date = [dateFormatter dateFromString:[gradeNode.childElementNodes objectAtIndex:0].innerHTML];
            
            g.content = [[gradeNode.childElementNodes objectAtIndex:1].textComponents[0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            
            if([gradeNode.childElementNodes objectAtIndex:2].textComponents.count > 0){
                NSString* gradeString = [[gradeNode.childElementNodes objectAtIndex:2].textComponents objectAtIndex:0];
                gradeString = [gradeString stringByReplacingOccurrencesOfString:@" " withString:@""];
                gradeString = [gradeString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
                g.grade = [gradeString doubleValue];
            } else g.grade = 0;
            
            if([gradeNode.childElementNodes objectAtIndex:2].childElementNodes.count > 0 && [[gradeNode.childElementNodes objectAtIndex:2].childElementNodes objectAtIndex:1].textComponents.count > 0){
                
                NSArray* detailsArray = [[gradeNode.childElementNodes objectAtIndex:2].childElementNodes objectAtIndex:1].textComponents;
                
                for(int i = 0; i < detailsArray.count; i++){
                    g.details = [[g.details stringByAppendingString:[detailsArray objectAtIndex:i]] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                    if(i < detailsArray.count - 1) g.details = [g.details stringByAppendingString:@"\n"];
                }
            } else g.details = @"";
            
            g.weight = [[gradeNode.childElementNodes objectAtIndex:3].innerHTML doubleValue];
            
            [subject.grades addObject:g];
        }
        
        [user.subjects addObject:subject];
    }
}

+(void) parseAbsences: (HTMLDocument*) src{
    NSMutableArray<HTMLNode*>* rows = [[NSMutableArray alloc] initWithArray:[[src firstNodeMatchingSelector:@"table"] firstNodeMatchingSelector:@"tbody"].childElementNodes];
    [rows removeObjectAtIndex:0];
    [rows removeObjectAtIndex:rows.count - 1];
    [rows removeObjectAtIndex:rows.count - 1];
    [rows removeObjectAtIndex:rows.count - 1];
    
    for(HTMLNode* row in rows){
        Absence* a = [[Absence alloc] init];
        
        NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
        formatter.locale = [NSLocale currentLocale];
        formatter.dateFormat = @"dd.MM.yyyy";
        
        a.startDate = [formatter dateFromString:row.childElementNodes[0].innerHTML];
        a.endDate = [formatter dateFromString:row.childElementNodes[1].innerHTML];
        a.reason = row.childElementNodes[2].innerHTML;
        a.additionalInformation = row.childElementNodes[3].innerHTML;
        a.lessonCount = [row.childElementNodes[4].childElementNodes[0].textContent intValue];
        a.excused = [row.childElementNodes[6].innerHTML isEqualToString:@"Ja"];
        
        [user.absences addObject:a];
    }
}

+(void) parseTransactions: (HTMLDocument*) src{
    
}

+(void) parseSchedule: (HTMLDocument*) src{
    /*NSString* roomsString = [src innerHTML];
    long start = [roomsString rangeOfString:@"var zimmerliste = ["].location + @"var zimmerliste = [".length;
    long end = (int)[roomsString rangeOfString:@"]" options:0 range:NSMakeRange(start, [roomsString length] - start)].location;
    
    roomsString = [roomsString substringWithRange:NSMakeRange(start, end - start)];
    
    NSMutableDictionary* rooms = [[NSMutableDictionary alloc] init];
    for(NSString* pair in [roomsString componentsSeparatedByString:@"},{"]){
        NSRange keyRange = NSMakeRange([pair rangeOfString:@"\"key\":"].location + @"\"key\":".length, [pair rangeOfString:@","].location - ([pair rangeOfString:@"\"key\":"].location + @"\"key\":".length));
        NSString* key = [pair substringWithRange:keyRange];
        
        NSRange labelRange = NSMakeRange([pair rangeOfString:@"\"label\":\""].location + @"\"label\":\"".length, [pair rangeOfString:@"\"" options: 0 range: NSMakeRange([pair rangeOfString:@"\"label\":\""].location + @"\"label\":\"".length, pair.length - ([pair rangeOfString:@"\"label\":\""].location + @"\"label\":\"".length))].location - ([pair rangeOfString:@"\"label\":\""].location +  @"\"label\":\"".length));
        NSString* label = [[pair substringWithRange:labelRange] stringByApplyingTransform:@"Any-Hex" reverse:YES];
        
        [rooms setObject:label forKey:key];
    }
    
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    NSDate* today = [[NSDate alloc] initWithTimeIntervalSinceNow:0];
    NSDate* tomorrow = [[NSDate alloc] initWithTimeIntervalSinceNow:24 * 60 * 60];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd";
    
    NSMutableString *urlString = [[NSMutableString alloc]initWithFormat:@"https://%@/scheduler_processor.php?view=", [Variables get].account.host];
    [urlString appendString: @"day"];
    [urlString appendString: @"&curr_date="];
    [urlString appendString: [formatter stringFromDate:today]];
    [urlString appendString: @"&min_date="];
    [urlString appendString: [formatter stringFromDate:today]];
    [urlString appendString: @"&max_date="];
    [urlString appendString: [formatter stringFromDate:tomorrow]];
    [urlString appendString: @"&ansicht="];
    [urlString appendString: @"schueleransicht"];
    [urlString appendString: @"&id="];
    [urlString appendString: [Account getCurrent].currentId];
    [urlString appendString: @"&transid="];
    [urlString appendString: [Account getCurrent].currentTransId];
    [urlString appendString: @"&pageid="];
    [urlString appendString: @"22202"];
    [urlString appendString: @"&timeshift="];
    [urlString appendString: @"-60"];
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];

    [urlRequest setHTTPMethod:@"GET"];
    [urlRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [urlRequest setValue:@"keep-alive" forHTTPHeaderField:@"Connection"];
    [urlRequest setValue:[Account getCurrent].currentCookies forHTTPHeaderField:@"Cookie"];
    
    __block BOOL done = NO;
    NSURLSessionDataTask *dataTask = [defaultSession dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if(error != NULL || data == NULL) return;
        
        TBXML* xml = [TBXML newTBXMLWithXMLData:data error:nil];
        
        TBXMLElement* event = [TBXML childElementNamed:@"event" parentElement:[xml rootXMLElement]];
        while(event != nil){
            Lesson* l = [[Lesson alloc] init];
            
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            
            [formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
            l.startDate = [formatter dateFromString:[TBXML textForElement: [TBXML childElementNamed:@"start_date" parentElement:event]]];
            if(l.startDate == nil){
                [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                l.startDate = [formatter dateFromString:[TBXML textForElement: [TBXML childElementNamed:@"start_date" parentElement:event]]];
            }
            
            [formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
            l.endDate = [formatter dateFromString:[TBXML textForElement: [TBXML childElementNamed:@"end_date" parentElement:event]]];
            if(l.endDate == nil){
                [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                l.endDate = [formatter dateFromString:[TBXML textForElement: [TBXML childElementNamed:@"end_date" parentElement:event]]];
            }
            
            l.type = [TBXML textForElement: [TBXML childElementNamed:@"event_type" parentElement:event]];
            
            l.marking = [TBXML textForElement: [TBXML childElementNamed:@"markierung" parentElement:event]];
            
            l.room = [rooms objectForKey:[TBXML textForElement: [TBXML childElementNamed:@"zimmer" parentElement:event]]];
            
            l.lessonIdentifier = [TBXML textForElement: [TBXML childElementNamed:@"text" parentElement:event]];
            
            l.subject = nil;
            for(Subject* s in user.subjects){
                if([s.identifier isEqualToString: [TBXML textForElement: [TBXML childElementNamed:@"kurskuerzel" parentElement:event]]]) {
                    l.subject = s;
                    break;
                }
            }
            
            [user.lessons addObject:l];
            
            event = event->nextSibling;
        }
        
        done = YES;
    }];
    [dataTask resume];

    while (!done) {
        NSDate *date = [[NSDate alloc] initWithTimeIntervalSinceNow:0.1];
        [[NSRunLoop currentRunLoop] runUntilDate:date];
    }*/
}

+(void) parseEvents: (HTMLDocument*) src{
    
}

+(void) parseTeachers: (HTMLDocument*) src{
    NSOrderedSet<HTMLNode*>* allRows = [[src firstNodeMatchingSelector:@"table"] firstNodeMatchingSelector:@"tbody"].children;
    
    NSMutableArray* rows = allRows.array.mutableCopy;
    [rows removeObjectAtIndex:0];
    [rows removeObjectAtIndex:0];
    [rows removeObjectAtIndex:0];
    [rows removeObjectAtIndex:0];
    [rows removeObjectAtIndex:0];
    [rows removeObjectAtIndex:0];
    
    for(HTMLNode* row in rows){
        Teacher* t = [[Teacher alloc] init];
        
        if(row.childElementNodes[1].numberOfChildren) t.lastName = [row.childElementNodes[1].textComponents[0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if(row.childElementNodes[2].numberOfChildren) t.firstName = [row.childElementNodes[2].textComponents[0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if(row.childElementNodes[3].numberOfChildren) t.shortName = [row.childElementNodes[3].textComponents[0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if(row.childElementNodes[4].numberOfChildren) t.mail = [row.childElementNodes[4].childElementNodes[0].textComponents[0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        [user.teachers addObject:t];
    }
}

+(void) parseStudents: (HTMLDocument*) src{
    NSMutableArray<HTMLNode*>* rows = [[NSMutableArray alloc] initWithArray:[[[src firstNodeMatchingSelector:@"table"] firstNodeMatchingSelector:@"tbody"] nodesMatchingSelector:@"tr"]];
    
    [rows removeObjectAtIndex:0];
    [rows removeObjectAtIndex:0];
    
    for(HTMLNode* row in rows){
        Student* s = [[Student alloc] init];
        
        NSString* dateOfBirth = @"";
        
        if(row.childElementNodes[1].numberOfChildren) s.lastName = [row.childElementNodes[1].textContent stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if(row.childElementNodes[2].numberOfChildren) s.firstName = [row.childElementNodes[2].textContent stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if(row.childElementNodes[3].numberOfChildren) s.gender = [[row.childElementNodes[3].textContent stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@"w"];
        if(row.childElementNodes[4].numberOfChildren) s.degree = [row.childElementNodes[4].textContent stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if(row.childElementNodes[5].numberOfChildren) s.bilingual = [[row.childElementNodes[5].textContent stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@"b"];
        if(row.childElementNodes[6].numberOfChildren) s.className = [row.childElementNodes[6].textContent stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if(row.childElementNodes[7].numberOfChildren) s.address = [row.childElementNodes[7].textContent stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if(row.childElementNodes[8].numberOfChildren) s.zipCode = [row.childElementNodes[8].textContent stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].intValue;
        if(row.childElementNodes[9].numberOfChildren) s.city = [row.childElementNodes[9].textContent stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if(row.childElementNodes[10].numberOfChildren) s.phone = [row.childElementNodes[10].textContent stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if(row.childElementNodes[11].numberOfChildren) dateOfBirth = [row.childElementNodes[11].textContent stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if(row.childElementNodes[12].numberOfChildren) s.additionalClasses = [row.childElementNodes[12].textContent stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if(row.childElementNodes[13].numberOfChildren) s.status = [row.childElementNodes[13].textContent stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if(row.childElementNodes[14].numberOfChildren) s.placeOfWork = [row.childElementNodes[14].textContent stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"dd.MM.yyyy";
        s.dateOfBirth = [formatter dateFromString:dateOfBirth];
        
        [user.students addObject:s];
    }
}

+(NSString*) getName: (int) pageId{
    NSString* result = @"";
    
    switch (pageId) {
        case 21311:
            result = @"grades";
            break;
        case 21111:
            result = @"absences";
            break;
        case 21411:
            result = @"transactions";
            break;
        case 22202:
            result = @"schedule";
            break;
        case 22108:
            result = @"events";
            break;
        case 22352:
            result = @"teachers";
            break;
        case 22326:
            result = @"students";
            break;
        default:
            break;
    }
    
    return result;
}

+(NSArray*) allPages{
    NSMutableArray* array = [[NSMutableArray alloc] init];
    
    [array addObject:[[NSNumber alloc] initWithInt:22352]];
    [array addObject:[[NSNumber alloc] initWithInt:21311]];
    [array addObject:[[NSNumber alloc] initWithInt:21111]];
    [array addObject:[[NSNumber alloc] initWithInt:21411]];
    [array addObject:[[NSNumber alloc] initWithInt:22202]];
    [array addObject:[[NSNumber alloc] initWithInt:22108]];
    //[array addObject:[[NSNumber alloc] initWithInt:21312]];
    //[array addObject:[[NSNumber alloc] initWithInt:1]];
    //[array addObject:[[NSNumber alloc] initWithInt:22500]];
    //[array addObject:[[NSNumber alloc] initWithInt:21200]];
    //[array addObject:[[NSNumber alloc] initWithInt:22206]];
    //[array addObject:[[NSNumber alloc] initWithInt:22300]];
    //[array addObject:[[NSNumber alloc] initWithInt:22313]];
    //[array addObject:[[NSNumber alloc] initWithInt:24030]];
    //[array addObject:[[NSNumber alloc] initWithInt:22320]];
    [array addObject:[[NSNumber alloc] initWithInt:22326]];
    //[array addObject:[[NSNumber alloc] initWithInt:10000]];
    //[array addObject:[[NSNumber alloc] initWithInt:10002]];
    //[array addObject:[[NSNumber alloc] initWithInt:10003]];
    //[array addObject:[[NSNumber alloc] initWithInt:23180]];
    //[array addObject:[[NSNumber alloc] initWithInt:23182]];
    
    return array;
}
@end
