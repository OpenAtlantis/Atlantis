//
//  RDTextField.m
//  Atlantis
//
//  Created by Rachel Blackman on 7/28/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import "RDTextField.h"

@interface RDTextFieldDelegate
- (void) controlTextDidCommitText:(NSNotification *)notification;
@end

@implementation RDTextField

- (id) initWithFrame:(NSRect) frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _rdOnlyEnterCommits = NO;
    }
    return self;
}

- (void) setRequireEnterCommit:(BOOL) enterCommit
{
    _rdOnlyEnterCommits = enterCommit;
}

- (BOOL) requireEnterCommit
{
    return _rdOnlyEnterCommits;
}

- (void) textView:(NSTextView *) textView doCommandBySelector:(SEL)selector
{
    if (_rdOnlyEnterCommits && (selector == @selector(insertNewline:))) {
        id myDelegate = [self delegate];
        if ([myDelegate respondsToSelector:@selector(controlTextDidCommitText:)]) {
            NSNotification *notification = [NSNotification notificationWithName:@"RDTextFieldDidCommitText" object:self];
            [myDelegate controlTextDidCommitText:notification];
        }        
    }
    else
        [super textView:textView doCommandBySelector:selector];
}

@end
