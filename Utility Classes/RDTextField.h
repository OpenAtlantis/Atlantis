//
//  RDTextField.h
//  Atlantis
//
//  Created by Rachel Blackman on 7/28/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface RDTextField : NSSearchField {

    BOOL                    _rdOnlyEnterCommits;

}

- (BOOL) requireEnterCommit;
- (void) setRequireEnterCommit:(BOOL) enterCommit;

@end
