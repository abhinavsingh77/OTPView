//
//  LSTOTPControl.m
//  OTPViewSample
//
//  Created by Abhinav Singh on 18/04/16.
//  Copyright © 2016 No Name. All rights reserved.
//

#import "LSTOTPControl.h"

@import CoreText;

@implementation LSTDotView

- (instancetype)initWithFrame:(CGRect)frame color:(UIColor*)clr font:(UIFont*)font{
    
    self = [super initWithFrame:frame];
    if (self) {
        
        contentColor = clr;
        textFont = font;
        
        shapeLayer = [CAShapeLayer layer];
        shapeLayer.geometryFlipped = YES;
        shapeLayer.fillColor = contentColor.CGColor;
        [self.layer addSublayer:shapeLayer];
        
        self.backgroundColor = [UIColor clearColor];
        self.layer.borderColor = clr.CGColor;
        self.layer.borderWidth = 1;
        
        self.userInteractionEnabled = NO;
    }
    
    return self;
}

-(void)layoutSubviews {
    
    [super layoutSubviews];
    
    self.layer.cornerRadius = (self.frame.size.width/2.0);
    shapeLayer.frame = self.layer.bounds;
}

-(void)setText:(NSString*)text {
    
    if (!_text.length && text.length) {
        
        _text = text;
        [self animateFromEmptyToFilledUp];
    }else if (_text.length && !text.length){
        
        _text = text;
        [self animateFromFilledUpToEmpty];
    }else {
        _text = text;
    }
}

-(void)animateFromEmptyToFilledUp {
    
    UIBezierPath *fromPath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake((self.frame.size.width/2.0f)-1, (self.frame.size.height/2.0f)-1, 2, 2)];
    
    CGPathRef toPath = [self pathFromSingleCharacter:self.text];
    CGRect rect = CGPathGetPathBoundingBox(toPath);
    rect.size.width += 1;
    
    CGAffineTransform tt = CGAffineTransformMakeTranslation(((self.frame.size.width-(rect.size.width))/2.0)-1, ((self.frame.size.height-rect.size.height)/2.0));
    
    toPath = CGPathCreateCopyByTransformingPath(toPath, &tt);
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"path"];
    animation.delegate = self;
    animation.fromValue = (__bridge id _Nullable)(fromPath.CGPath);
    animation.toValue = (__bridge id _Nullable)(toPath);
    animation.duration = 0.3;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    animation.fillMode = kCAFillModeForwards;
    [animation setValue:@"EmptyToFilledUp" forKey:@"AnimationIdentifier"];
    
    shapeLayer.path = toPath;
    
    [shapeLayer addAnimation:animation forKey:@"EmptyToFilledUp"];
}

-(void)animateFromFilledUpToEmpty {
    
    UIBezierPath *toPath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake((self.frame.size.width/2.0f)-1, (self.frame.size.height/2.0f)-1, 2, 2)];
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"path"];
    animation.delegate = self;
    animation.toValue = (__bridge id _Nullable)(toPath.CGPath);
    animation.fromValue = (__bridge id _Nullable)(shapeLayer.path);
    animation.duration = 0.3;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.fillMode = kCAFillModeForwards;
    
    shapeLayer.path = nil;
    
    [shapeLayer addAnimation:animation forKey:@"FilledUpToEmpty"];
}

- (void)animationDidStop:(CAAnimation *)animation finished:(BOOL)finished {
    
    NSString *identifier = [animation valueForKey:@"AnimationIdentifier"];
    if ([identifier isEqualToString:@"EmptyToFilledUp"]) {
        
        __block NSString *forText = self.text;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            if ([forText isEqualToString:self.text]) {
                
                UIBezierPath *toPath = [UIBezierPath bezierPathWithOvalInRect:self.bounds];
                CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"path"];
                animation.delegate = self;
                animation.fromValue = (__bridge id _Nullable)(shapeLayer.path);
                animation.toValue = (__bridge id _Nullable)(toPath.CGPath);
                animation.duration = 0.3;
                animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
                animation.fillMode = kCAFillModeForwards;
                
                shapeLayer.path = toPath.CGPath;
                
                [shapeLayer addAnimation:animation forKey:@"FinalEmptyToFilledUp"];
            }
        });
    }
}

//Refrence:https://github.com/aderussell/string-to-CGPathRef
-(CGPathRef)pathFromSingleCharacter:(NSString*)string {
    
    NSAttributedString *attributed = [[NSAttributedString alloc] initWithString:[string substringToIndex:1] attributes:@{NSFontAttributeName:textFont}];
    
    CTLineRef line = CTLineCreateWithAttributedString((__bridge CFAttributedStringRef)attributed);
    
    CFArrayRef runArray = CTLineGetGlyphRuns(line);
    
    // Get FONT for this run
    CTRunRef run = (CTRunRef)CFArrayGetValueAtIndex(runArray, 0);
    CTFontRef runFont = CFDictionaryGetValue(CTRunGetAttributes(run), kCTFontAttributeName);
    
    // get Glyph & Glyph-data
    CFRange thisGlyphRange = CFRangeMake(0, 1);
    CGGlyph glyph;
    CGPoint position;
    CTRunGetGlyphs(run, thisGlyphRange, &glyph);
    CTRunGetPositions(run, thisGlyphRange, &position);
    
    CGPathRef letter = CTFontCreatePathForGlyph(runFont, glyph, NULL);
    
    return letter;
}

@end

@implementation LSTOTPControl

- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        
        [self initialSetup];
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    
    self = [super initWithCoder:coder];
    if (self) {
        
        [self initialSetup];
    }
    
    return self;
}

-(UITextAutocorrectionType)autocorrectionType {
    return UITextAutocorrectionTypeNo;
}

-(UITextAutocapitalizationType)autocapitalizationType {
    return UITextAutocapitalizationTypeNone;
}

-(UITextSpellCheckingType)spellCheckingType {
    return UITextSpellCheckingTypeNo;
}

-(UIKeyboardType)keyboardType {
    return UIKeyboardTypeNumberPad;
}

-(UIKeyboardAppearance)keyboardAppearance {
    return UIKeyboardAppearanceDefault;
}

-(UIReturnKeyType)returnKeyType {
    return UIReturnKeyDefault;
}

-(BOOL)enablesReturnKeyAutomatically {
    return NO;
}

-(BOOL)isSecureTextEntry {
    return NO;
}

-(void)initialSetup {
    
    contentView = [[UIView alloc] initWithFrame:CGRectZero];
    contentView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:contentView];
    
    NSDictionary *dict = NSDictionaryOfVariableBindings(contentView);
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[contentView]-0-|" options:0 metrics:nil views:dict]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[contentView]-0-|" options:0 metrics:nil views:dict]];
    
    self.dotsGap = 20;
    self.dotsSize = 30;
    
    dotsArray = [NSMutableArray new];
    
    self.backgroundColor = [UIColor whiteColor];
}

-(BOOL)canBecomeFirstResponder {
    
    return YES;
}

-(BOOL)hasText {
    return NO;
}

-(void)insertText:(NSString *)text {
    
    LSTDotView *toFillNext = nil;
    for ( LSTDotView *dtView in dotsArray ) {
        if (!dtView.text.length) {
            toFillNext = dtView;
            break;
        }
    }
    
    if (toFillNext) {
        
        _enteredDigits += 1;
        [toFillNext setText:text];
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
}

-(void)deleteBackward {
    
    LSTDotView *toEmptyNext = nil;
    for ( LSTDotView *dtView in dotsArray.reverseObjectEnumerator ) {
        if (dtView.text.length) {
            toEmptyNext = dtView;
            break;
        }
    }
    
    if (toEmptyNext) {
        
        _enteredDigits -= 1;
        [toEmptyNext setText:nil];
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
}

-(void)setupForOTPCount:(int)cnt color:(UIColor*)color andFont:(UIFont*)font {
    
    if (cnt > 3) {
        
        [contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [contentView removeConstraints:contentView.constraints];
        
        UIView *leftPadding = [[UIView alloc] initWithFrame:CGRectZero];
        leftPadding.userInteractionEnabled = NO;
        leftPadding.translatesAutoresizingMaskIntoConstraints = NO;
        [contentView addSubview:leftPadding];
        
        UIView *rightPadding = [[UIView alloc] initWithFrame:CGRectZero];
        rightPadding.userInteractionEnabled = NO;
        rightPadding.translatesAutoresizingMaskIntoConstraints = NO;
        [contentView addSubview:rightPadding];
        
        NSDictionary *dictMetrics = @{@"hGap":@(self.dotsGap), @"size":@(self.dotsSize)};
        
        LSTDotView *lastAdded = nil;
        for ( int i = 0; i < cnt ; i++ ) {
            
            LSTDotView *dotView = [[LSTDotView alloc] initWithFrame:CGRectZero color:color font:font];
            dotView.translatesAutoresizingMaskIntoConstraints = NO;
            [contentView addSubview:dotView];
            [dotsArray addObject:dotView];
            
            NSDictionary *dict = NSDictionaryOfVariableBindings(dotView);
            
            [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[dotView(==size)]" options:0 metrics:dictMetrics views:dict]];
            [contentView addConstraint:[NSLayoutConstraint constraintWithItem:dotView
                                                                    attribute:NSLayoutAttributeCenterY
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:contentView
                                                                    attribute:NSLayoutAttributeCenterY
                                                                   multiplier:1 constant:0]];
            if (lastAdded) {
                
                dict = NSDictionaryOfVariableBindings(lastAdded, dotView);
                [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[lastAdded]-hGap-[dotView(==size)]" options:0 metrics:dictMetrics views:dict]];
            }else {
                
                dict = NSDictionaryOfVariableBindings(leftPadding, dotView, rightPadding);
                [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[leftPadding(==rightPadding)]-0-[dotView(==size)]" options:0 metrics:dictMetrics views:dict]];
            }
            
            lastAdded = dotView;
        }
        
        NSDictionary *dict = NSDictionaryOfVariableBindings(rightPadding, lastAdded, leftPadding);
        [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[lastAdded]-0-[rightPadding(==leftPadding)]-0-|" options:0 metrics:dictMetrics views:dict]];
        [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[rightPadding]-0-|" options:0 metrics:dictMetrics views:dict]];
        [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[leftPadding]-0-|" options:0 metrics:dictMetrics views:dict]];
    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    [super touchesBegan:touches withEvent:event];
    
    if (![self isFirstResponder]) {
        [self becomeFirstResponder];
    }
}

-(NSString*)text {
    
    NSMutableString *retText = nil;
    for ( LSTDotView *dtView in dotsArray ) {
        if (dtView.text.length) {
            
            if (!retText) {
                retText = [@"" mutableCopy];
            }
            
            [retText appendString:dtView.text];
        }else {
            break;
        }
    }
    
    return retText;
}

-(void)reset {
    
    for ( LSTDotView *dtView in dotsArray.reverseObjectEnumerator ) {
        [dtView setText:nil];
    }
    
    _enteredDigits = 0;
}

@end