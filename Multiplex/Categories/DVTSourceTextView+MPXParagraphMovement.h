//
//  DVTSourceTextView+MPXParagraphMovement.h
//  Multiplex
//
//  Created by Kolin Krewinkel on 8/26/15.
//  Copyright © 2015 Kolin Krewinkel. All rights reserved.
//

#import <DVTKit/DVTSourceTextView.h>

/**
 * For some reason, -moveToBeginningOfParagraph: and -moveParagraphBackwardsModifyingSelection: are used rather than
 * a matching set (-x and -xModifyingSelection).
 */
@interface DVTSourceTextView (MPXParagraphMovement)

@end
