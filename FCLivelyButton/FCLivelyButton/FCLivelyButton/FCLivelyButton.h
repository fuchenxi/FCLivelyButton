//
//  FCLivelyButton.h
//  FCLivelyButton
//
//  Created by 付晨曦 on 2017/7/6.
//  Copyright © 2017年 付晨曦. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, FCLivelyButtonStyle) {
    
    FCLivelyButtonStyleHamburger,
    FCLivelyButtonStyleClose,
    FCLivelyButtonStylePlus,
    FCLivelyButtonStyleCirclePlus,
    FCLivelyButtonStyleCircleClose,
    FCLivelyButtonStyleCaretUp,
    FCLivelyButtonStyleCaretDown,
    FCLivelyButtonStyleCaretLeft,
    FCLivelyButtonStyleCaretRight,
    FCLivelyButtonStyleArrowLeft,
    FCLivelyButtonStyleArrowRight
};

@interface FCLivelyButton : UIButton

@property (nonatomic, strong) NSDictionary *options;

- (FCLivelyButtonStyle)buttonStyle;

+(NSDictionary *) defaultOptions;

- (void)setStyle:(FCLivelyButtonStyle)style animated:(BOOL)animated;

/// button customization options:
/// scale to apply to the button CGPath(s) when the button is pressed. Default is 0.9:
UIKIT_EXTERN NSString *const FCLivelyButtonHighlightScale;
/// the button CGPaths stroke width, default 1.0f pixel
UIKIT_EXTERN NSString *const FCLivelyButtonLineWidth;
/// the button CGPaths stroke color, default is black
UIKIT_EXTERN NSString *const FCLivelyButtonColor;
/// the button CGPaths stroke color when highlighted, default is light gray
UIKIT_EXTERN NSString *const FCLivelyButtonHighlightedColor;
/// duration in second of the highlight (pressed down) animation, default 0.1
UIKIT_EXTERN NSString *const FCLivelyButtonHighlightAnimationDuration;
/// duration in second of the unhighlight (button release) animation, defualt 0.15
UIKIT_EXTERN NSString *const FCLivelyButtonUnHighlightAnimationDuration;
/// duration in second of the style change animation, default 0.3
UIKIT_EXTERN NSString *const FCLivelyButtonStyleChangeAnimationDuration;

@end
