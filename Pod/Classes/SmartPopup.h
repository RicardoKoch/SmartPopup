//
//  SmartPopup.h
//
//  Created by Ricardo Koch on 10/13/14.
//  Copyright (c) 2014. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NSString SmartPopupInstance;

typedef enum {
    SmartPopupTypeImage = 0,
    SmartPopupTypeNoImage = 1,
    SmartPopupTypeLoading = 2,
    SmartPopupTypeXib = 3,
    SmartPopupTypeImageView = 4
} SmartPopupType;

@class SmartPopupButton;
typedef void (^SmartPopupButtonBlock)(SmartPopupInstance*);

@interface SmartPopupButton : UIButton
@property (strong) NSString *labelText;
@property (strong) SmartPopupInstance *popupId;
@property (strong) SmartPopupButtonBlock block;
+(instancetype)buttonWithText:(NSString *)text andBlock:(SmartPopupButtonBlock)block;
@end

@protocol SmartPopupViewProtocol <NSObject>
+(id<SmartPopupViewProtocol>)createFromXib;
-(void)willShowWithId:(NSString *)identifier;
-(void)config;
-(void)setArgs:(NSArray *)args;
@end

@interface SmartPopup : NSObject

@property id<SmartPopupViewProtocol> customView;

+ (SmartPopup *)instance;

- (SmartPopupInstance *)showWithType:(SmartPopupType)type image:(UIImage *)image title:(NSString *)title message:(NSString *)message andButtonBlocks:(SmartPopupButton *)blocks, ...;

- (SmartPopupInstance *)showWithType:(SmartPopupType)type image:(UIImage *)image title:(NSString *)title message:(NSString *)message buttons:(NSArray *)buttons;

- (SmartPopupInstance *)showWithImageView:(UIView *)imageV title:(NSString *)title message:(NSString *)message buttons:(NSArray *)buttons;

- (SmartPopupInstance *)showfromXib:(Class)xibClass withArgs:(NSArray *)args;

- (void)dismiss:(SmartPopupInstance *)popup;

- (UIView *)backgroundView;

@end
