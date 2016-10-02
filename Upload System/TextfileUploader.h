//
//  TextfileUploader.h
//  Atlantis
//
//  Created by Rachel Blackman on 5/21/06.
//  Copyright 2006 Riverdark Studios. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "UploadEngine.h"

@interface TextfileUploader : UploadEngine {

    FILE                    *_rdTextfileHandle;

}

@end
