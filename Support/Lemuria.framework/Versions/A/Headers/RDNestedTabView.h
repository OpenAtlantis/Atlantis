//
//  RDNestedTabView.h
//  Lemuria
//
//  Created by Rachel Blackman on 7/2/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Lemuria/RDNestedViewDisplay.h>
#import <Lemuria/RDNestedViewCollection.h>

@interface RDNestedTabView : NSTabView <RDNestedViewDisplay> {

    RDNestedViewCache           *_rdViewCollection;
    
    BOOL                         _rdSelfDrag;
    
    

}

@end
