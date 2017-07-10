//
//  FCLivelyButton.m
//  FCLivelyButton
//
//  Created by 付晨曦 on 2017/7/6.
//  Copyright © 2017年 付晨曦. All rights reserved.
//

#import "FCLivelyButton.h"

NSString *const FCLivelyButtonHighlightScale                =   @"FCLivelyButtonHighlightScale";
NSString *const FCLivelyButtonLineWidth                     =   @"FCLivelyButtonLineWidth";
NSString *const FCLivelyButtonColor                         =   @"FCLivelyButtonColor";
NSString *const FCLivelyButtonHighlightedColor              =   @"FCLivelyButtonHighlightedColor";
NSString *const FCLivelyButtonHighlightAnimationDuration    =   @"FCLivelyButtonHighlightAnimationDuration";
NSString *const FCLivelyButtonUnHighlightAnimationDuration  =   @"FCLivelyButtonUnHighlightAnimationDuration";
NSString *const FCLivelyButtonStyleChangeAnimationDuration  =   @"FCLivelyButtonStyleChangeAnimationDuration";

#define GOLDEN_RATIO 1.618

@interface FCLivelyButton ()

@property (nonatomic, strong) CAShapeLayer *circleLayer;
@property (nonatomic, strong) CAShapeLayer *line1Layer;
@property (nonatomic, strong) CAShapeLayer *line2Layer;
@property (nonatomic, strong) CAShapeLayer *line3Layer;
@property (nonatomic, strong) NSArray *shapeLayers;

@property (nonatomic) FCLivelyButtonStyle buttonStyle;
@property (nonatomic) CGFloat dimension;
@property (nonatomic) CGPoint offset;
@property (nonatomic) CGPoint centerPoint;

@end

@implementation FCLivelyButton

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        
        [self initializer];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    
    if (self = [super initWithCoder:aDecoder]) {
        
        [self initializer];
    }
    return self;
}

- (void)initializer {
    
    self.line1Layer = [[CAShapeLayer alloc] init];
    self.line2Layer = [CAShapeLayer layer];
    self.line3Layer = [[CAShapeLayer alloc] init];
    self.circleLayer = [[CAShapeLayer alloc] init];
    self.shapeLayers = @[self.line1Layer, self.line2Layer, self.line3Layer, self.circleLayer];
    self.options = [FCLivelyButton defaultOptions];
    
    [self.shapeLayers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        CAShapeLayer *layer = obj;
        layer.fillColor = [UIColor clearColor].CGColor;
        layer.anchorPoint = CGPointMake(0.0, 0.0);
        layer.lineJoin = kCALineJoinRound;
        layer.lineCap = kCALineCapRound;
        layer.contentsScale = self.layer.contentsScale;
        
        // initialize with an empty path so we can animate the path w/o having to check for NULLs.
        CGPathRef dummyPath = CGPathCreateMutable();
        layer.path = dummyPath;
        CGPathRelease(dummyPath);
        
        [self.layer addSublayer:layer];
    }];
    
    
    [self addTarget:self action:@selector(showHighlight) forControlEvents:UIControlEventTouchDown];
    [self addTarget:self action:@selector(showUnHighlight) forControlEvents:UIControlEventTouchUpInside];
    [self addTarget:self action:@selector(showUnHighlight) forControlEvents:UIControlEventTouchUpOutside];
    
    // in case the button is not square, the offset will be use to keep our CGPath's centered in it.
    CGFloat width   = CGRectGetWidth(self.frame) - (self.contentEdgeInsets.left + self.contentEdgeInsets.right);
    CGFloat height  = CGRectGetHeight(self.frame) - (self.contentEdgeInsets.top + self.contentEdgeInsets.bottom);
    
    self.dimension = MIN(width, height);
    self.offset = CGPointMake((CGRectGetWidth(self.frame) - self.dimension) / 2.0f,
                              (CGRectGetHeight(self.frame) - self.dimension) / 2.0f);
    
    self.centerPoint = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
}

#pragma mark - Animate Button Pressed Event
- (void)showHighlight {
    
    float highlightScale = [[self valueForOptionKey:FCLivelyButtonHighlightScale] floatValue];
    
    [self.shapeLayers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [obj setStrokeColor:[[self valueForOptionKey:FCLivelyButtonHighlightedColor] CGColor]];
        
        CAShapeLayer *layer = obj;
        
        CGAffineTransform transform = [self transformWithScale:highlightScale];
        CGPathRef scaledPath =  CGPathCreateMutableCopyByTransformingPath(layer.path, &transform);
        
        CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"path"];
        anim.duration = [[self valueForOptionKey:FCLivelyButtonHighlightAnimationDuration] floatValue];
        anim.removedOnCompletion = NO;
        anim.fromValue = (__bridge id) layer.path;
        anim.toValue = (__bridge id) scaledPath;
        [anim setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault]];
        [layer addAnimation:anim forKey:nil];
        
        layer.path = scaledPath;
        CGPathRelease(scaledPath);
    }];
}

- (void)showUnHighlight {
    
    float unHighlightScale = 1/[[self valueForOptionKey:FCLivelyButtonHighlightScale] floatValue];
    
    [self.shapeLayers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [obj setStrokeColor:[[self valueForOptionKey:FCLivelyButtonColor] CGColor]];
        
        CAShapeLayer *layer = obj;
        CGPathRef path = layer.path;
        
        CGAffineTransform transform = [self transformWithScale:unHighlightScale];
        CGPathRef finalPath =  CGPathCreateMutableCopyByTransformingPath(path, &transform);
        
        CGAffineTransform uptransform = [self transformWithScale:unHighlightScale * 1.07];
        CGPathRef scaledUpPath = CGPathCreateMutableCopyByTransformingPath(path, &uptransform);
        
        CGAffineTransform downtransform = [self transformWithScale:unHighlightScale * 0.97];
        CGPathRef scaledDownPath = CGPathCreateMutableCopyByTransformingPath(path, &downtransform);
        
        NSArray *values = @[
                            (__bridge id) layer.path,
                            (id) CFBridgingRelease(scaledUpPath),
                            (id) CFBridgingRelease(scaledDownPath),
                            (__bridge id) finalPath
                            ];
        NSArray *times = @[ @(0.0), @(0.85), @(0.93), @(1.0) ];
        
        CAKeyframeAnimation *anim = [CAKeyframeAnimation animationWithKeyPath:@"path"];
        anim.duration = [[self valueForOptionKey:FCLivelyButtonUnHighlightAnimationDuration] floatValue];;
        
        anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault];
        anim.removedOnCompletion = NO;
        
        anim.values = values;
        anim.keyTimes = times;
        
        [layer addAnimation:anim forKey:nil];
        
        layer.path = finalPath;
        CGPathRelease(finalPath);
    }];
    
    return;
}

#pragma mark - Setup Style
- (void)setStyle:(FCLivelyButtonStyle)style animated:(BOOL)animated {
    
    self.buttonStyle = style;
    CGFloat width   = CGRectGetWidth(self.frame) - (self.contentEdgeInsets.left + self.contentEdgeInsets.right);
    CGFloat height  = CGRectGetHeight(self.frame) - (self.contentEdgeInsets.top + self.contentEdgeInsets.bottom);
    self.dimension = MIN(width, height);
    self.offset = CGPointMake((CGRectGetWidth(self.frame) - self.dimension) / 2.0f,
                              (CGRectGetHeight(self.frame) - self.dimension) / 2.0f);
    self.centerPoint = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    
    CGPathRef newCirclePath = NULL;
    CGPathRef newLine1Path = NULL;
    CGPathRef newLine2Path = NULL;
    CGPathRef newLine3Path = NULL;
    
    CGFloat newCircleAlpha = 0.0f;
    CGFloat newLine1Alpha = 0.0f;
    
    switch (style) {
        
        case FCLivelyButtonStyleHamburger: {
            
            newCirclePath = [self createCenteredCircleWithRadius:self.dimension/20.0f];
            newCircleAlpha = 0.0f;
            newLine1Path = [self createCenteredLineWithRadius:self.dimension/2.0f angle:0 offset:CGPointMake(0, 0)];
            newLine1Alpha = 1.0f;
            newLine2Path = [self createCenteredLineWithRadius:self.dimension/2.0f angle:0 offset:CGPointMake(0, -self.dimension/2.0f/GOLDEN_RATIO)];
            newLine3Path = [self createCenteredLineWithRadius:self.dimension/2.0f angle:0 offset:CGPointMake(0, self.dimension/2.0f/GOLDEN_RATIO)];
            
        } break;
        
        case FCLivelyButtonStyleClose: {
            
            newCirclePath = [self createCenteredCircleWithRadius:self.dimension/20.0f];
            newCircleAlpha = 0.0f;
            newLine1Path = [self createCenteredLineWithRadius:self.dimension/20.0f angle:0 offset:CGPointMake(0, 0)];
            newLine1Alpha = 0.0f;
            newLine2Path = [self createCenteredLineWithRadius:self.dimension/2.0f angle:+M_PI_4 offset:CGPointMake(0, 0)];
            newLine3Path = [self createCenteredLineWithRadius:self.dimension/2.0f angle:-M_PI_4 offset:CGPointMake(0, 0)];
            
        } break;
            
        case FCLivelyButtonStylePlus: {
            
            newCirclePath = [self createCenteredCircleWithRadius:self.dimension/20.0f];
            newCircleAlpha = 0.0f;
            newLine1Path = [self createCenteredLineWithRadius:self.dimension/20.0f angle:0 offset:CGPointMake(0, 0)];
            newLine1Alpha = 0.0f;
            newLine2Path = [self createCenteredLineWithRadius:self.dimension/2.0f angle:+M_PI_2 offset:CGPointMake(0, 0)];
            newLine3Path = [self createCenteredLineWithRadius:self.dimension/2.0f angle:0 offset:CGPointMake(0, 0)];
            
        } break;
            
        case FCLivelyButtonStyleCirclePlus: {
            
            newCirclePath = [self createCenteredCircleWithRadius:self.dimension/2.0f];
            newCircleAlpha = 1.0f;
            newLine1Path = [self createCenteredLineWithRadius:self.dimension/20.0f angle:0 offset:CGPointMake(0, 0)];
            newLine1Alpha = 0.0f;
            newLine2Path = [self createCenteredLineWithRadius:self.dimension/2.0f/GOLDEN_RATIO angle:M_PI_2 offset:CGPointMake(0, 0)];
            newLine3Path = [self createCenteredLineWithRadius:self.dimension/2.0f/GOLDEN_RATIO angle:0 offset:CGPointMake(0, 0)];
            
        } break;
            
        case FCLivelyButtonStyleCircleClose: {
            
            newCirclePath = [self createCenteredCircleWithRadius:self.dimension/2.0f];
            newCircleAlpha = 1.0f;
            newLine1Path = [self createCenteredLineWithRadius:self.dimension/20.0f angle:0 offset:CGPointMake(0, 0)];
            newLine1Alpha = 0.0f;
            newLine2Path = [self createCenteredLineWithRadius:self.dimension/2.0f/GOLDEN_RATIO angle:+M_PI_4 offset:CGPointMake(0, 0)];
            newLine3Path = [self createCenteredLineWithRadius:self.dimension/2.0f/GOLDEN_RATIO angle:-M_PI_4 offset:CGPointMake(0, 0)];
            
        } break;
            
        case FCLivelyButtonStyleCaretUp: {
            
            newCirclePath = [self createCenteredCircleWithRadius:self.dimension/20.0f];
            newCircleAlpha = 0.0f;
            newLine1Path = [self createCenteredLineWithRadius:self.dimension/20.0f angle:0 offset:CGPointMake(0, 0)];
            newLine1Alpha = 0.0f;
            newLine2Path = [self createCenteredLineWithRadius:self.dimension/4.0f - self.line2Layer.lineWidth/2.0f angle:M_PI_4 offset:CGPointMake(self.dimension/6.0f,0.0f)];
            newLine3Path = [self createCenteredLineWithRadius:self.dimension/4.0f - self.line3Layer.lineWidth/2.0f angle:3*M_PI_4 offset:CGPointMake(-self.dimension/6.0f,0.0f)];
            
        } break;
            
        case FCLivelyButtonStyleCaretDown: {
            
            newCirclePath = [self createCenteredCircleWithRadius:self.dimension/20.0f];
            newCircleAlpha = 0.0f;
            newLine1Path = [self createCenteredLineWithRadius:self.dimension/20.0f angle:0 offset:CGPointMake(0, 0)];
            newLine1Alpha = 0.0f;
            newLine2Path = [self createCenteredLineWithRadius:self.dimension/4.0f - self.line2Layer.lineWidth/2.0f angle:-M_PI_4 offset:CGPointMake(self.dimension/6.0f,0.0f)];
            newLine3Path = [self createCenteredLineWithRadius:self.dimension/4.0f - self.line3Layer.lineWidth/2.0f angle:-3*M_PI_4 offset:CGPointMake(-self.dimension/6.0f,0.0f)];
            
        } break;
            
        case FCLivelyButtonStyleCaretLeft: {
            
            newCirclePath = [self createCenteredCircleWithRadius:self.dimension/20.0f];
            newCircleAlpha = 0.0f;
            newLine1Path = [self createCenteredLineWithRadius:self.dimension/20.0f angle:0 offset:CGPointMake(0, 0)];
            newLine1Alpha = 0.0f;
            newLine2Path = [self createCenteredLineWithRadius:self.dimension/4.0f - self.line2Layer.lineWidth/2.0f angle:-3*M_PI_4 offset:CGPointMake(0.0f,self.dimension/6.0f)];
            newLine3Path = [self createCenteredLineWithRadius:self.dimension/4.0f - self.line3Layer.lineWidth/2.0f angle:3*M_PI_4 offset:CGPointMake(0.0f,-self.dimension/6.0f)];
            
        } break;
            
        case FCLivelyButtonStyleCaretRight: {
            
            newCirclePath = [self createCenteredCircleWithRadius:self.dimension/20.0f];
            newCircleAlpha = 0.0f;
            newLine1Path = [self createCenteredLineWithRadius:self.dimension/20.0f angle:0 offset:CGPointMake(0, 0)];
            newLine1Alpha = 0.0f;
            newLine2Path = [self createCenteredLineWithRadius:self.dimension/4.0f - self.line2Layer.lineWidth/2.0f angle:-M_PI_4 offset:CGPointMake(0.0f,self.dimension/6.0f)];
            newLine3Path = [self createCenteredLineWithRadius:self.dimension/4.0f - self.line3Layer.lineWidth/2.0f angle:M_PI_4 offset:CGPointMake(0.0f,-self.dimension/6.0f)];
            
        } break;
            
        case FCLivelyButtonStyleArrowLeft: {
            
            newCirclePath = [self createCenteredCircleWithRadius:self.dimension/20.0f];
            newCircleAlpha = 0.0f;
            newLine1Path = [self createCenteredLineWithRadius:self.dimension/2.0f angle:M_PI offset:CGPointMake(0, 0)];
            newLine1Alpha = 1.0f;
            newLine2Path = [self createLineFromPoint:CGPointMake(0, self.dimension/2.0f)
                                             toPoint:CGPointMake(self.dimension/2.0f/GOLDEN_RATIO, self.dimension/2+self.dimension/2.0f/GOLDEN_RATIO)];
            newLine3Path = [self createLineFromPoint:CGPointMake(0, self.dimension/2.0f)
                                             toPoint:CGPointMake(self.dimension/2.0f/GOLDEN_RATIO, self.dimension/2-self.dimension/2.0f/GOLDEN_RATIO)];
            
        } break;
            
        case FCLivelyButtonStyleArrowRight: {
            
            newCirclePath = [self createCenteredCircleWithRadius:self.dimension/20.0f];
            newCircleAlpha = 0.0f;
            newLine1Path = [self createCenteredLineWithRadius:self.dimension/2.0f angle:0 offset:CGPointMake(0, 0)];
            newLine1Alpha = 1.0f;
            newLine2Path = [self createLineFromPoint:CGPointMake(self.dimension, self.dimension/2.0f)
                                             toPoint:CGPointMake(self.dimension - self.dimension/2.0f/GOLDEN_RATIO, self.dimension/2+self.dimension/2.0f/GOLDEN_RATIO)];
            newLine3Path = [self createLineFromPoint:CGPointMake(self.dimension, self.dimension/2.0f)
                                             toPoint:CGPointMake(self.dimension - self.dimension/2.0f/GOLDEN_RATIO, self.dimension/2-self.dimension/2.0f/GOLDEN_RATIO)];
            
        } break;
         
        default: NSAssert(FALSE, @"unknown type"); break;
    }
    
    NSTimeInterval duration = [[self valueForOptionKey:FCLivelyButtonStyleChangeAnimationDuration] floatValue];
    
    // animate all the layer path and opacity
    if (animated) {
        
        {
            CABasicAnimation *circleAnim = [CABasicAnimation animationWithKeyPath:@"path"];
            circleAnim.removedOnCompletion = NO;
            circleAnim.duration = duration;
            circleAnim.fromValue = (__bridge id)self.circleLayer.path;
            circleAnim.toValue = (__bridge id)newCirclePath;
            [circleAnim setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault]];
            [self.circleLayer addAnimation:circleAnim forKey:@"animateCirclePath"];
        }
        
        {
            CABasicAnimation *circleAlphaAnim = [CABasicAnimation animationWithKeyPath:@"opacity"];
            circleAlphaAnim.removedOnCompletion = NO;
            circleAlphaAnim.duration = duration;
            circleAlphaAnim.fromValue = @(self.circleLayer.opacity);
            circleAlphaAnim.toValue = @(newCircleAlpha);
            [circleAlphaAnim setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault]];
            [self.circleLayer addAnimation:circleAlphaAnim forKey:@"animateCircleOpacityPath"];
        }
        
        {
            CABasicAnimation *line1Anim = [CABasicAnimation animationWithKeyPath:@"path"];
            line1Anim.removedOnCompletion = NO;
            line1Anim.duration = duration;
            line1Anim.fromValue = (__bridge id)self.line1Layer.path;
            line1Anim.toValue = (__bridge id)newLine1Path;
            [line1Anim setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault]];
            [self.line1Layer addAnimation:line1Anim forKey:@"animateLine1Path"];
        }
        
        {
            CABasicAnimation *line1AlphaAnim = [CABasicAnimation animationWithKeyPath:@"opacity"];
            line1AlphaAnim.removedOnCompletion = NO;
            line1AlphaAnim.duration = duration;
            line1AlphaAnim.fromValue = @(self.line1Layer.opacity);
            line1AlphaAnim.toValue = @(newLine1Alpha);
            [line1AlphaAnim setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault]];
            [self.line1Layer addAnimation:line1AlphaAnim forKey:@"animateLine1OpacityPath"];
        }
        
        {
            CABasicAnimation *line2Anim = [CABasicAnimation animationWithKeyPath:@"path"];
            line2Anim.removedOnCompletion = NO;
            line2Anim.duration = duration;
            line2Anim.fromValue = (__bridge id)self.line2Layer.path;
            line2Anim.toValue = (__bridge id)newLine2Path;
            [line2Anim setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault]];
            [self.line2Layer addAnimation:line2Anim forKey:@"animateLine2Path"];
        }
        
        {
            CABasicAnimation *line3Anim = [CABasicAnimation animationWithKeyPath:@"path"];
            line3Anim.removedOnCompletion = NO;
            line3Anim.duration = duration;
            line3Anim.fromValue = (__bridge id)self.line3Layer.path;
            line3Anim.toValue = (__bridge id)newLine3Path;
            [line3Anim setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault]];
            [self.line3Layer addAnimation:line3Anim forKey:@"animateLine3Path"];
        }
    }
    
    self.circleLayer.path = newCirclePath;
    self.circleLayer.opacity = newCircleAlpha;
    self.line1Layer.path = newLine1Path;
    self.line1Layer.opacity = newLine1Alpha;
    self.line2Layer.path = newLine2Path;
    self.line3Layer.path = newLine3Path;
    
    CGPathRelease(newCirclePath);
    CGPathRelease(newLine1Path);
    CGPathRelease(newLine2Path);
    CGPathRelease(newLine3Path);
}

#pragma mark - Creat Path
- (CGAffineTransform)transformWithScale:(CGFloat)scale {
    
    CGAffineTransform transform = CGAffineTransformMakeTranslation((self.dimension + 2 * self.offset.x) * ((1-scale)/2.0f),
                                                                   (self.dimension + 2 * self.offset.y)  * ((1-scale)/2.0f));
    return CGAffineTransformScale(transform, scale, scale);
}

/// you are responsible for releasing the return CGPath
- (CGPathRef)createCenteredCircleWithRadius:(CGFloat)radius {
    CGMutablePathRef path = CGPathCreateMutable();
    
    CGPathMoveToPoint(path, NULL, self.centerPoint.x + radius, self.centerPoint.y);
    /// note: if clockwise is set to true, the circle will not draw on an actual device,
    /// event hough it is fine on the simulator...
    CGPathAddArc(path, NULL, self.centerPoint.x, self.centerPoint.y, radius, 0, 2 * M_PI, false);
    
    return path;
}

/// you are responsible for releasing the return CGPath
- (CGPathRef)createCenteredLineWithRadius:(CGFloat)radius angle:(CGFloat)angle offset:(CGPoint)offset {
    
    CGMutablePathRef path = CGPathCreateMutable();
    
    /// 计算 cos
    float c = cosf(angle);
    /// 计算 sin
    float s = sinf(angle);
    
    CGPathMoveToPoint(path, NULL,
                      self.centerPoint.x + offset.x + radius * c,
                      self.centerPoint.y + offset.y + radius * s);
    CGPathAddLineToPoint(path, NULL,
                         self.centerPoint.x + offset.x - radius * c,
                         self.centerPoint.y + offset.y - radius * s);
    
    return path;
}

- (CGPathRef)createLineFromPoint:(CGPoint)p1 toPoint:(CGPoint)p2 {
    
    CGMutablePathRef path = CGPathCreateMutable();
    
    CGPathMoveToPoint(path, NULL, self.offset.x + p1.x, self.offset.y + p1.y);
    CGPathAddLineToPoint(path, NULL, self.offset.x + p2.x, self.offset.y + p2.y);
    
    return path;
}

#pragma mark - Option
- (void)setOptions:(NSDictionary *)options {
    
    _options = options;
    
    [self.shapeLayers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        CAShapeLayer *layer = obj;
        layer.lineWidth = [[self valueForOptionKey:FCLivelyButtonLineWidth] floatValue];
        layer.strokeColor = [[self valueForOptionKey:FCLivelyButtonColor] CGColor];
    }];
}

- (id)valueForOptionKey:(NSString *)key {
    
    if (self.options[key]) {
        
        return self.options[key];
    }
    return [FCLivelyButton defaultOptions][key];
}

+ (NSDictionary *)defaultOptions {
    
    return @{
             FCLivelyButtonLineWidth                    : @(1.0),
             FCLivelyButtonHighlightScale               : @(0.9),
             FCLivelyButtonColor                        : [UIColor blackColor],
             FCLivelyButtonHighlightedColor             : [UIColor lightGrayColor],
             FCLivelyButtonHighlightAnimationDuration   : @(0.1),
             FCLivelyButtonUnHighlightAnimationDuration : @(0.15),
             FCLivelyButtonStyleChangeAnimationDuration : @(0.3)
             };
}

#pragma mark - Dealloc
- (void)dealloc {
    
    for (CALayer* layer in [self.layer sublayers]) {
    
        [layer removeAllAnimations];
    }
    
    [self.layer removeAllAnimations];
    self.shapeLayers = nil;
}

@end
