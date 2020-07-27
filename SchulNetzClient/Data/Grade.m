#import "Grade.h"

@implementation Grade
@synthesize date;
@synthesize content;
@synthesize grade;
@synthesize details;
@synthesize weight;

-(instancetype)init{
    details = @"";
    
    return self;
}

-(void)encodeWithCoder:(NSCoder*)coder{
    [coder encodeObject:date forKey:@"date"];
    [coder encodeObject:content forKey:@"content"];
    [coder encodeDouble:grade forKey:@"grade"];
    [coder encodeObject:details forKey:@"details"];
    [coder encodeDouble:weight forKey:@"weight"];
}

-(instancetype)initWithCoder:(NSCoder*)coder{
    date = [coder decodeObjectForKey:@"date"];
    content = [coder decodeObjectForKey:@"content"];
    grade = [coder decodeDoubleForKey:@"grade"];
    details = [coder decodeObjectForKey:@"details"];
    weight = [coder decodeDoubleForKey:@"weight"];
    
    return self;
}

+(BOOL)supportsSecureCoding{
    return true;
}

+(UIColor*)colorForGrade:(double)grade{
    UIColor* color = UIColor.blackColor;
    
    if(grade >= 6) color = [UIColor colorWithRed:0 green:1 blue:0 alpha:1];
    else if(grade < 6 && grade > 4){
        double positiveImpact = (grade - 4) / 2;
        double negativeImpact = 1 - positiveImpact;
        
        const CGFloat* positiveColor = CGColorGetComponents([UIColor colorWithRed:0 green:1 blue:0 alpha:1].CGColor);
        const CGFloat* negativeColor = CGColorGetComponents([UIColor colorWithRed:1 green:1 blue:0 alpha:1].CGColor);
        
        color = [UIColor colorWithRed:positiveImpact * positiveColor[0] + negativeImpact * negativeColor[0] green:positiveImpact * positiveColor[1] + negativeImpact * negativeColor[1] blue:positiveImpact * positiveColor[2] + negativeImpact * negativeColor[2] alpha:1];
    }
    else if(grade == 4) color = [UIColor colorWithRed:1 green:1 blue:0.0 alpha:1];
    else if(grade < 4 && grade > 1){
        double positiveImpact = (grade - 1) / 3;
        double negativeImpact = 1 - positiveImpact;
        
        const CGFloat* positiveColor = CGColorGetComponents([UIColor colorWithRed:1 green:0.5 blue:0 alpha:1].CGColor);
        const CGFloat* negativeColor = CGColorGetComponents([UIColor colorWithRed:1 green:0 blue:0 alpha:1].CGColor);
        
        color = [UIColor colorWithRed:positiveImpact * positiveColor[0] + negativeImpact * negativeColor[0] green:positiveImpact * positiveColor[1] + negativeImpact * negativeColor[1] blue:positiveImpact * positiveColor[2] + negativeImpact * negativeColor[2] alpha:1];
    }
    else if(grade == 1) color = [UIColor colorWithRed:1 green:0 blue:0.0 alpha:1];
    else if(grade < 1 || isnan(grade)) color = [UIColor colorWithRed:0.375 green:0.375 blue:0.375 alpha:1];
    
    return color;
}

-(BOOL)isEqual:(id)other{
    if(other == self){
        return YES;
    } else if([self class] != [other class]){
        return NO;
    } else {
        return [content isEqualToString:((Grade*)other).content];
    }
}

-(NSUInteger)hash{
    return [content hash];
}
@end
