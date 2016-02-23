//
//  UIPopupView.m
//
//
//  Created by Ricardo Koch on 10/28/14.
//  Copyright (c) 2014. All rights reserved.
//

#import "UIRotatingView.h"

@implementation UIRotatingView {
    BOOL firstRotation;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(orientationChanged:)
                                                     name:UIDeviceOrientationDidChangeNotification
                                                   object:nil];
        // Do any additional setup after loading the view.
        firstRotation = YES;
        
    }
    return self;
}

- (void)orientationChanged:(NSNotification *)notification
{
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    
    switch (deviceOrientation) {
        case UIDeviceOrientationPortrait:

            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDuration:firstRotation ? 0 : 0.3f];
            self.transform = CGAffineTransformMakeRotation(0);

            [UIView commitAnimations];
            break;
        case UIDeviceOrientationPortraitUpsideDown:

            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDuration:firstRotation ? 0 : 0.3f];
            self.transform = CGAffineTransformMakeRotation(-M_PI);

            [UIView commitAnimations];
            break;
        case UIDeviceOrientationLandscapeLeft:
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDuration:firstRotation ? 0 : 0.3f];
            self.transform = CGAffineTransformMakeRotation(M_PI_2);

            [UIView commitAnimations];
            break;
        case UIDeviceOrientationLandscapeRight:

            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDuration:firstRotation ? 0 : 0.3f];

            self.transform = CGAffineTransformMakeRotation(-M_PI_2);

            [UIView commitAnimations];
            break;
            
        default:
            break;
    }
    firstRotation = NO;
}

- (void)didMoveToSuperview {
    //update orientation
    [self orientationChanged:nil];
}

- (void)layoutSubviews {
}


- (void)removeFromSuperview {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super removeFromSuperview];
}

@end
