#import "UIPickerTextField.h"

@implementation UIPickerTextField
-(CGRect)caretRectForPosition:(UITextPosition*) position{
    return CGRectZero;
}

-(BOOL)canPerformAction:(SEL)action withSender:(id)sender{
    if(action == @selector(paste:) || action == @selector(cut:)) return false;
    else return [super canPerformAction:action withSender:sender];
}
@end
