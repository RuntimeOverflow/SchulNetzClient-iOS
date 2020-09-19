#import "Parser.h"
#import "Account.h"
#import "Data/Data.h"
#import "Libraries/TBXML/TBXML.h"
#import "Variables.h"

@implementation Parser
+(BOOL)parseGrades:(HTMLDocument*)doc forUser:(User*)user{
    @try{
        HTMLNode* tableBody = [doc firstNodeMatchingSelector:@".mdl-data-table tbody"];
        if(!tableBody || tableBody.childElementNodes.count <= 0) return false;
        
        NSMutableArray* rows = [tableBody.childElementNodes mutableCopy];
        [rows removeObjectAtIndex:0];
        
        if(rows.count % 3 != 0) return false;
        for (int i = 0; i < rows.count; i += 3) {
            HTMLElement* mainRow = rows[i];
            HTMLElement* gradesRow = rows[i + 1];
            
            if(mainRow.childElementNodes.count < 5 || mainRow.childElementNodes[0].childElementNodes.count <= 0 || mainRow.childElementNodes[0].textComponents[0].length <= 0 || mainRow.childElementNodes[0].childElementNodes[0].textComponents[0].length <= 0) continue;
            
            Subject* s = [user subjectForIdentifier:[mainRow.childElementNodes[0].childElementNodes[0].textComponents[0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
            if(!s) continue;
            
            s.name = [mainRow.childElementNodes[0].textComponents[0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            s.confirmed = mainRow.childElementNodes[3].childElementNodes.count <= 0 || mainRow.childElementNodes[3].childElementNodes[0].attributes[@"href"] == NULL;
            
            NSMutableArray* grades = [[NSMutableArray alloc] init];
            
            if(gradesRow.childElementNodes.count <= 0) continue;
            if(gradesRow.childElementNodes[0].childElementNodes.count > 0 && gradesRow.childElementNodes[0].childElementNodes[0].childElementNodes.count > 0){
                HTMLElement* gradesTable = gradesRow.childElementNodes[0].childElementNodes[0].childElementNodes[0];
                if(gradesRow.childElementNodes.count <= 0) continue;
                NSMutableArray* gradeRows = [gradesTable.childElementNodes mutableCopy];
                [gradeRows removeObjectAtIndex:0];
                
                for(HTMLElement* gradeRow in gradeRows){
                    if(gradeRow.childElementNodes.count < 4) continue;
                    Grade* g = [[Grade alloc] init];
                    
                    if(gradeRow.childElementNodes[0].textComponents.count > 0 && gradeRow.childElementNodes[0].textComponents[0].length > 0){
                        NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
                        formatter.dateFormat = @"dd.MM.yyyy";
                        g.date = [formatter dateFromString:[gradeRow.childElementNodes[0].textComponents[0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
                    }
                    
                    if(gradeRow.childElementNodes[1].textComponents.count > 0 && gradeRow.childElementNodes[1].textComponents[0].length > 0){
                        g.content = [gradeRow.childElementNodes[1].textComponents[0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                    }
                    
                    if(gradeRow.childElementNodes[2].textComponents.count > 0 && gradeRow.childElementNodes[2].textComponents[0].length > 0){
                        g.grade = [gradeRow.childElementNodes[2].textComponents[0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].doubleValue;
                        
                        if(gradeRow.childElementNodes[2].childElementNodes.count >= 2 && gradeRow.childElementNodes[2].childElementNodes[1].textComponents.count > 0 && gradeRow.childElementNodes[2].childElementNodes[1].textComponents[0].length > 0){
                            g.details = gradeRow.childElementNodes[2].childElementNodes[1].textComponents[0];
                        }
                    }
                    
                    if(gradeRow.childElementNodes[3].textComponents.count > 0 && gradeRow.childElementNodes[3].textComponents[0].length > 0){
                        g.weight = [gradeRow.childElementNodes[3].textComponents[0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].doubleValue;
                    }
                    
                    [grades addObject:g];
                }
            }
            
            s.grades = grades;
        }
    } @catch(NSException *exception){
        return false;
    } @finally{}
    
    return true;
}

+(BOOL)parseSubjects:(HTMLDocument*)doc forUser:(User*)user{
    NSMutableArray* previous = user.subjects;
    user.subjects = [[NSMutableArray alloc] init];
    
    @try{
        HTMLNode* list = [doc firstNodeMatchingSelector:@"#clsList"];
        if(!list){
            user.subjects = previous;
            return false;
        }
        
        for(HTMLElement* subject in list.childElementNodes){
            if(![subject firstNodeMatchingSelector:@".mdl-radio__label"]) continue;
            Subject* s = [[Subject alloc] init];
            
            s.identifier = [[subject firstNodeMatchingSelector:@".mdl-radio__label"].textComponents[0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            
            NSArray* parts = [s.identifier componentsSeparatedByString:@"-"];
            if(parts.count >= 3) s.shortName = parts[0];
            
            [user.subjects addObject:s];
        }
    } @catch(NSException *exception){
        user.subjects = previous;
        return false;
    } @finally{}
    
    return true;
}

+(BOOL)parseStudents:(HTMLDocument*)doc forUser:(User*)user{
    NSMutableArray* previous = user.students;
    user.students = [[NSMutableArray alloc] init];
    
    @try{
        HTMLNode* tableBody = [doc firstNodeMatchingSelector:@"#cls-table-Kursliste tbody"];
        if(!tableBody){
            user.students = previous;
            return false;
        }
        
        NSMutableArray* rows = [tableBody.childElementNodes mutableCopy];
        if(rows.count < 2){
            user.students = previous;
            return false;
        } else if(rows.count == 2) return true;
        
        [rows removeObjectAtIndex:0];
        [rows removeObjectAtIndex:0];
        
        for(HTMLElement* row in rows){
            if(row.childElementNodes.count < 15) continue;
            
            Student* s = [[Student alloc] init];
            if(row.childElementNodes[1].textComponents.count > 0) s.lastName = [row.childElementNodes[1].textComponents[0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            if(row.childElementNodes[2].textComponents.count > 0) s.firstName = [row.childElementNodes[2].textComponents[0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            if(row.childElementNodes[3].textComponents.count > 0) s.gender = [[row.childElementNodes[3].textComponents[0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].lowercaseString isEqualToString:@"w".lowercaseString];
            if(row.childElementNodes[4].textComponents.count > 0) s.degree = [row.childElementNodes[4].textComponents[0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            if(row.childElementNodes[5].textComponents.count > 0) s.bilingual = [[row.childElementNodes[5].textComponents[0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].lowercaseString isEqualToString:@"b".lowercaseString];
            if(row.childElementNodes[6].textComponents.count > 0) s.className = [row.childElementNodes[6].textComponents[0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            if(row.childElementNodes[7].textComponents.count > 0) s.address = [row.childElementNodes[7].textComponents[0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            if(row.childElementNodes[8].textComponents.count > 0) s.zipCode = [row.childElementNodes[8].textComponents[0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length > 0 ? [row.childElementNodes[8].textComponents[0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].intValue : -1;
            if(row.childElementNodes[9].textComponents.count > 0) s.city = [row.childElementNodes[9].textComponents[0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            if(row.childElementNodes[10].textComponents.count > 0) s.phone = [row.childElementNodes[10].textComponents[0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            if(row.childElementNodes[11].textComponents.count > 0 && row.childElementNodes[11].textComponents[0].length > 0){
                NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
                formatter.dateFormat = @"dd.MM.yyyy";
                s.dateOfBirth = [formatter dateFromString:[row.childElementNodes[11].textComponents[0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
            }
            if(row.childElementNodes[12].textComponents.count > 0) s.additionalClasses = [row.childElementNodes[12].textComponents[0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            if(row.childElementNodes[13].textComponents.count > 0) s.status = [row.childElementNodes[13].textComponents[0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            if(row.childElementNodes[14].textComponents.count > 0) s.placeOfWork = [row.childElementNodes[14].textComponents[0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            
            [user.students addObject:s];
        }
    } @catch(NSException *exception){
        user.students = previous;
        return false;
    } @finally{}
    
    return true;
}

+(BOOL)parseTeachers:(HTMLDocument*)doc forUser:(User*)user{
    NSMutableArray* previous = user.teachers;
    user.teachers = [[NSMutableArray alloc] init];
    
    @try{
        HTMLNode* tableBody = [doc firstNodeMatchingSelector:@"#cls-table-Lehrerliste tbody"];
        if(!tableBody){
            user.teachers = previous;
            return false;
        }
        
        NSMutableArray* rows = [tableBody.childElementNodes mutableCopy];
        if(rows.count < 2){
            user.teachers = previous;
            return false;
        } else if(rows.count == 2) return true;
        
        [rows removeObjectAtIndex:0];
        [rows removeObjectAtIndex:0];
        
        for(HTMLElement* row in rows){
            if(row.childElementNodes.count < 5) continue;
            
            Teacher* t = [[Teacher alloc] init];
            t.lastName = [row.childElementNodes[1].textComponents[0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            t.firstName = [row.childElementNodes[2].textComponents[0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            t.shortName = [row.childElementNodes[3].textComponents[0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            t.mail = [row.childElementNodes[4] nodesMatchingSelector:@"a"].count > 0 ? [[row.childElementNodes[4] firstNodeMatchingSelector:@"a"].textComponents[0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] : @"";
            
            [user.teachers addObject:t];
        }
    } @catch(NSException *exception){
        user.teachers = previous;
        return false;
    } @finally{}
    
    return true;
}

+(BOOL)parseSelf:(HTMLDocument*)doc forUser:(User*)user{
    @try{
        HTMLNode* card = [doc firstNodeMatchingSelector:@"#content-card"];
        if(!card || [card nodesMatchingSelector:@"table"].count < 2 || [card firstNodeMatchingSelector:@"table"].childElementNodes.count <= 0) return false;
        
        HTMLElement* tableBody = [card firstNodeMatchingSelector:@"table"].childElementNodes[0];
        if(tableBody.childElementNodes.count < 2 || tableBody.childElementNodes[0].childElementNodes.count < 2 || tableBody.childElementNodes[1].childElementNodes.count < 2) return false;
        
        NSString* lastName = [tableBody.childElementNodes[0].childElementNodes[1].textComponents[0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSString* firstName = [tableBody.childElementNodes[1].childElementNodes[1].textComponents[0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        BOOL found = false;
        for(Student* s in user.students){
            if([s.firstName.lowercaseString isEqualToString:firstName.lowercaseString] && [s.lastName.lowercaseString isEqualToString:lastName.lowercaseString]){
                s.me = true;
                found = true;
                break;
            }
        }
        
        if(!found) return false;
    } @catch(NSException *exception){
        return false;
    } @finally{}
    
    return true;
}

+(BOOL)parseTransactions:(HTMLDocument*)doc forUser:(User*)user{
    NSMutableArray* previous = user.transactions;
    user.transactions = [[NSMutableArray alloc] init];
    
    @try{
        HTMLNode* card = [doc firstNodeMatchingSelector:@"#content-card"];
        if(!card || [card nodesMatchingSelector:@"table"].count < 2 || [card nodesMatchingSelector:@"table"][1].childElementNodes.count <= 0){
            user.transactions = previous;
            return false;
        }
        
        HTMLElement* tableBody = [card nodesMatchingSelector:@"table"][1].childElementNodes[0];
        if(tableBody.childElementNodes.count < 2){
            user.transactions = previous;
            return false;
        } else if(tableBody.childElementNodes.count == 2) return true;
        
        NSMutableArray* rows = [tableBody.childElementNodes mutableCopy];
        [rows removeObjectAtIndex:0];
        [rows removeObjectAtIndex:rows.count - 1];
        
        for(HTMLElement* row in rows){
            if(row.childElementNodes.count < 4) continue;
            
            Transaction* t = [[Transaction alloc] init];
            
            if([row.childElementNodes[0].textComponents[0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length > 0){
                NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
                formatter.dateFormat = @"dd.MM.yyyy";
                
                t.date = [formatter dateFromString:[row.childElementNodes[0].textComponents[0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
            }
            
            t.reason = [row.childElementNodes[1].textComponents[0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            if(row.childElementNodes[2].childElementNodes.count > 0){
                t.amount = [[row.childElementNodes[2].childElementNodes[0].textComponents[0] stringByReplacingOccurrencesOfString:@"sFr" withString:@""] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].doubleValue;
            }
            
            [user.transactions addObject:t];
            
            if([card nodesMatchingSelector:@"p"].count <= 0) return false;
            user.balanceConfirmed = [[card firstNodeMatchingSelector:@"p"] nodesMatchingSelector:@"a"].count <= 0;
        }
    } @catch(NSException *exception){
        user.transactions = previous;
        return false;
    } @finally{}
    
    return true;
}

+(BOOL)parseAbsences:(HTMLDocument*)doc forUser:(User*)user{
    NSMutableArray* previous = user.absences;
    user.absences = [[NSMutableArray alloc] init];
    
    @try{
        if([doc nodesMatchingSelector:@"table tbody"].count < 2){
            user.absences = previous;
            return false;
        }
        
        HTMLElement* tableBody = [doc firstNodeMatchingSelector:@"table tbody"];
        if(tableBody.childElementNodes.count < 4){
            user.absences = previous;
            return false;
        } else if(tableBody.childElementNodes.count == 4) return true;
        
        NSMutableArray* rows = [tableBody.childElementNodes mutableCopy];
        [rows removeObjectAtIndex:0];
        [rows removeObjectAtIndex:rows.count - 1];
        [rows removeObjectAtIndex:rows.count - 1];
        [rows removeObjectAtIndex:rows.count - 1];
        
        for(HTMLElement* row in rows){
            if(row.childElementNodes.count < 7) continue;
            
            Absence* a = [[Absence alloc] init];
            
            NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
            formatter.dateFormat = @"dd.MM.yyyy";
            
            a.startDate = [formatter dateFromString:[row.childElementNodes[0].textComponents[0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
            
            a.endDate = [formatter dateFromString:[row.childElementNodes[1].textComponents[0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
            
            a.reason = [row.childElementNodes[2].textComponents[0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            a.additionalInformation = [row.childElementNodes[3].textComponents[0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            
            if(row.childElementNodes[4].childElementNodes.count > 0){
                a.lessonCount = [row.childElementNodes[4].childElementNodes[0].textComponents[0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].intValue;
            }
            
            if(row.childElementNodes[4].childElementNodes.count > 1){
                NSArray* reports = [[row.childElementNodes[4].childElementNodes[1].innerHTML stringByReplacingOccurrencesOfString:@"<br>" withString:@"\n"] componentsSeparatedByString:@"\n"];
                if(reports.count > 1){
                    for(NSString* report in reports){
                        if([report componentsSeparatedByString:@","].count > 2){
                            [a.subjectIdentifiers addObject:[[report componentsSeparatedByString:@","][2] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
                        }
                    }
                }
            }
            
            a.excused = [[row.childElementNodes[6].textComponents[0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].lowercaseString isEqualToString:@"Ja".lowercaseString];
            
            [user.absences addObject:a];
        }
    } @catch(NSException *exception){
        user.absences = previous;
        return false;
    } @finally{}
    
    return true;
}

+(BOOL)parseSchedulePage:(HTMLDocument*)doc forUser:(User*)user{
    @try{
        if([doc nodesMatchingSelector:@"#extinst"].count <= 0) return false;
        
        NSMutableArray* types = [[[doc firstNodeMatchingSelector:@"#extinst"].parentElement nodesMatchingSelector:@"a"] mutableCopy];
        for(HTMLNode* type in types){
            if(![[type class] isSubclassOfClass:[HTMLElement class]]) continue;
            
            if(!((HTMLElement*)type).attributes[@"href"]) continue;
            else if(![((HTMLElement*)type).attributes[@"href"] containsString:@"="]) continue;
            else if([((HTMLElement*)type).attributes[@"href"] rangeOfString:@"="].location + 1 >= ((HTMLElement*)type).attributes[@"href"].length) continue;
            
            NSString* shortName = [((HTMLElement*)type).attributes[@"href"] substringFromIndex:[((HTMLElement*)type).attributes[@"href"] rangeOfString:@"="].location + 1];
            user.lessonTypeDict[shortName] = ((HTMLElement*)type).textComponents[0];
        }
        
        if(![doc.innerHTML containsString:@"var zimmerliste = [{"]) return false;
        NSString* jsDict = [doc.innerHTML substringFromIndex:[doc.innerHTML rangeOfString:@"var zimmerliste = [{"].location + @"var zimmerliste = [{".length];
        jsDict = [jsDict substringToIndex:[jsDict rangeOfString:@"}];"].location];
        
        NSArray* entries = [jsDict componentsSeparatedByString:@"},{"];
        for(NSString* entry in entries){
            if([entry rangeOfString:@"\".*\":[0-9]*,\".*\":\".*\"" options:NSRegularExpressionSearch].location == NSNotFound) continue;
            
            NSString* key = [entry substringWithRange:NSMakeRange([entry rangeOfString:@":"].location + 1, [entry rangeOfString:@","].location - ([entry rangeOfString:@":"].location + 1))];
            NSString* value = [entry substringWithRange:NSMakeRange([entry rangeOfString:@"\":\""].location + @"\":\"".length, entry.length - 1 - ([entry rangeOfString:@"\":\""].location + @"\":\"".length))];
            user.roomDict[key] = value;
        }
    } @catch(NSException *exception){
        return false;
    } @finally{}
    
    return true;
}

+(NSMutableArray*)parseSchedule:(HTMLDocument*)doc{
    NSMutableArray* list = [[NSMutableArray alloc] init];
    
    @try{
        if([doc nodesMatchingSelector:@"event"].count <= 0) return NULL;
        
        for(HTMLNode* event in [doc nodesMatchingSelector:@"event"]){
            Lesson* lesson = [[Lesson alloc] init];
            
            NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
            if([event nodesMatchingSelector:@"start_date"].count > 0 && [[event firstNodeMatchingSelector:@"start_date"].innerHTML rangeOfString:@":[0-9]{2}:" options:NSRegularExpressionSearch].location != NSNotFound) formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
            else formatter.dateFormat = @"yyyy-MM-dd HH:mm";
            if([event nodesMatchingSelector:@"start_date"].count > 0) lesson.startDate = [formatter dateFromString:[[[event firstNodeMatchingSelector:@"start_date"].innerHTML stringByReplacingOccurrencesOfString:@"<!--[CDATA[" withString:@""] stringByReplacingOccurrencesOfString:@"]]-->" withString:@""]];
            
            if([event nodesMatchingSelector:@"end_date"].count > 0) lesson.endDate = [formatter dateFromString:[[[event firstNodeMatchingSelector:@"end_date"].innerHTML stringByReplacingOccurrencesOfString:@"<!--[CDATA[" withString:@""] stringByReplacingOccurrencesOfString:@"]]-->" withString:@""]];
            
            if([event nodesMatchingSelector:@"text"].count > 0) lesson.lessonIdentifier = [[[event firstNodeMatchingSelector:@"text"].innerHTML stringByReplacingOccurrencesOfString:@"<!--[CDATA[" withString:@""] stringByReplacingOccurrencesOfString:@"]]-->" withString:@""];
            if([event nodesMatchingSelector:@"zimmer"].count > 0) lesson.roomNumber = [[[event firstNodeMatchingSelector:@"zimmer"].innerHTML stringByReplacingOccurrencesOfString:@"<!--[CDATA[" withString:@""] stringByReplacingOccurrencesOfString:@"]]-->" withString:@""].intValue;
            if([event nodesMatchingSelector:@"event_type"].count > 0) lesson.type = [[[event firstNodeMatchingSelector:@"event_type"].innerHTML stringByReplacingOccurrencesOfString:@"<!--[CDATA[" withString:@""] stringByReplacingOccurrencesOfString:@"]]-->" withString:@""];
            
            if([event nodesMatchingSelector:@"color"].count > 0){
                NSScanner* scanner = [NSScanner scannerWithString:[[[[event firstNodeMatchingSelector:@"color"].innerHTML stringByReplacingOccurrencesOfString:@"<!--[CDATA[" withString:@""] stringByReplacingOccurrencesOfString:@"]]-->" withString:@""] stringByReplacingOccurrencesOfString:@"#" withString:@""]];
                [scanner setCharactersToBeSkipped:[NSCharacterSet symbolCharacterSet]];
                unsigned int colorInt = 0;
                [scanner scanHexInt:&colorInt];
                CGFloat red   = ((colorInt & 0xFF0000) >> 16) / 255.0f;
                CGFloat green = ((colorInt & 0x00FF00) >>  8) / 255.0f;
                CGFloat blue  = (colorInt & 0x0000FF) / 255.0f;
                lesson.color = [UIColor colorWithRed:red green:green blue:blue alpha:1];
            }
            
            if([event nodesMatchingSelector:@"markierung"].count > 0) lesson.marking = [[[event firstNodeMatchingSelector:@"markierung"].innerHTML stringByReplacingOccurrencesOfString:@"<!--[CDATA[" withString:@""] stringByReplacingOccurrencesOfString:@"]]-->" withString:@""];
            if([lesson.marking isEqualToString:@"none"]) lesson.marking = @"";
            
            if([event nodesMatchingSelector:@"neuerlehrer"].count > 0) lesson.replacementTeacher = [[[event firstNodeMatchingSelector:@"neuerlehrer"].innerHTML stringByReplacingOccurrencesOfString:@"<!--[CDATA[" withString:@""] stringByReplacingOccurrencesOfString:@"]]-->" withString:@""];
            
            [list addObject:lesson];
        }
    } @catch(NSException *exception){
        return NULL;
    } @finally{}
    
    return list;
}
@end
