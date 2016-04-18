//
//  ViewController.m
//  OTPViewSample
//
//  Created by Abhinav Singh on 18/04/16.
//  Copyright © 2016 No Name. All rights reserved.
//

#import "ViewController.h"
#import "LSTOTPControl.h"

static int OTPLength = 4;

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    LSTOTPControl *control = [[LSTOTPControl alloc] initWithFrame:CGRectZero];
    control.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:control];
    
    NSDictionary *dict = NSDictionaryOfVariableBindings(control);
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[control]-0-|" options:0 metrics:nil views:dict]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-50-[control(==50)]" options:0 metrics:nil views:dict]];
    
    control.dotsGap = 10;
    control.dotsSize = 30;
    [control addTarget:self action:@selector(otpValueChanged:) forControlEvents:UIControlEventValueChanged];
    
    [control setupForOTPCount:OTPLength color:[UIColor orangeColor] andFont:[UIFont systemFontOfSize:20]];
}

-(void)otpValueChanged:(LSTOTPControl*)control {
    
    if (control.enteredDigits == OTPLength) {
        
        [control resignFirstResponder];
        
        UIAlertController *cont = [UIAlertController alertControllerWithTitle:@"Hey!" message:[NSString stringWithFormat:@"You have entered %@", control.text] preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:@"Okay"
                                                               style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * _Nonnull action) {
                                                                 
                                                                 [control reset];
        }];
        
        UIAlertAction *actionAgain = [UIAlertAction actionWithTitle:@"Enter Again"
                                                               style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * _Nonnull action) {
                                                                 
                                                                 [control reset];
                                                                 [control becomeFirstResponder];
                                                             }];
        
        
        [cont addAction:actionCancel];
        [cont addAction:actionAgain];
        
        [self presentViewController:cont animated:YES completion:nil];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
