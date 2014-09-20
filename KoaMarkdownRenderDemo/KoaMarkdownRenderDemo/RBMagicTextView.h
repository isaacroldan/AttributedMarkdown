//
//  RBMagicTextView.h
//  Redbooth
//
//  Created by Isaac Roldán Armengol on 28/6/14.
//  Copyright (c) 2014 teambox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMMarkdown.h"


@protocol RBMagicTextViewDelegate <NSObject>

- (void)textViewHeightWasUpdatedWithHeight:(float)height;

@end


@interface RBMagicTextView : UITextView

@property (nonatomic, weak) id<RBMagicTextViewDelegate> gifDelegate;
@property (nonatomic, strong) NSMutableArray *imageViewArray;

- (void)renderAttributedString:(NSAttributedString*)attributedString;
- (void)renderMarkdownString:(NSString*)markdown;

@end
