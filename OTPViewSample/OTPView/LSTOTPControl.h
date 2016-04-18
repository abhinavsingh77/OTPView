//
//  LSTOTPControl.h
//  OTPViewSample
//
//  Created by Abhinav Singh on 18/04/16.
//  Copyright © 2016 No Name. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LSTDotView : UIView {
    
    UIFont *textFont;
    CAShapeLayer *shapeLayer;
    UIColor *contentColor;
}

@property(nonatomic, strong) NSString *text;

@end

@interface LSTOTPControl : UIControl <UIKeyInput> {
    
    NSMutableArray *dotsArray;
    UIView *contentView;
}

@property(readonly, assign) NSInteger enteredDigits;

@property(nonatomic, assign) CGFloat dotsSize;
@property(nonatomic, assign) CGFloat dotsGap;

-(NSString*)text;
-(void)reset;

-(void)setupForOTPCount:(int)cnt color:(UIColor*)color andFont:(UIFont*)font;

@end
