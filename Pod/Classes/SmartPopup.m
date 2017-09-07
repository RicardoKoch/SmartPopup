//
//  SmartPopup.m
//
//  Created by Ricardo Koch on 10/13/14.
//  Copyright (c) 2014. All rights reserved.
//

#import "SmartPopup.h"
#import "UIImage+ImageEffects.h"
#import "UIRotatingView.h"

#define kSmartPopupBackgroundTag 90001
#define kSmartPopupPopupTag 90002
#define kSmartPopupBackgroundBlurTag 90003
#define kSmartPopupBorderMargin 10
#define kSmartPopupBottomMessageBorderMargin 20
#define kSmartPopupButtonHeight 46

@interface SmartPopupDefinition : NSObject
@property SmartPopupInstance *objectId;
@property NSString *title;
@property NSString *message;
//SmartPopupButton
@property NSArray *buttonsDefined;
@property UIImage *image;
@property UIView *imageView;
@property SmartPopupType type;
@property NSString *xibName;
@end

@implementation SmartPopupDefinition
- (instancetype)init
{
    self = [super init];
    if (self) { self.buttonsDefined = [NSMutableArray array]; }
    return self;
}
@end


@implementation SmartPopupButton
+(instancetype)buttonWithText:(NSString *)text andBlock:(SmartPopupButtonBlock)block {
    SmartPopupButton *instance = [[SmartPopupButton alloc] init];
    if (instance) {
        instance.labelText = NSLocalizedString(text, @"");
        instance.block = block;
        
        [instance.titleLabel setFont:[UIFont boldSystemFontOfSize:14]];
        [instance setTitle:instance.labelText forState:UIControlStateNormal];
        [instance setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [instance addTarget:instance action:@selector(didTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    }
    return instance;
}
-(void)didTouchUpInside:(UIButton*)sender {
    [[SmartPopup instance] dismiss:self.popupId];
    self.block(self.popupId);
}
@end

@interface SmartPopup ()

@property NSMutableArray *activePopups; //SmartPopupDefinition
@property (nonatomic, strong) UIDynamicAnimator *animator;

//private methods
- (SmartPopupInstance *)generateInstanceCode;
- (BOOL)isPopupActive:(SmartPopupInstance *)popup;
- (SmartPopupInstance *)showWithDefinition:(SmartPopupDefinition *)popup;
- (UIView*)createBaseBackground;
- (UIView *)createBaseUIForPopup:(SmartPopupDefinition *)popup inContainer:(UIView*)container;
- (void)createButtonsForPopup:(SmartPopupDefinition*)popup inView:(UIView*)popView;
- (void)animateLaunch:(SmartPopupDefinition *)popDef inContainer:(UIView*)container;
- (void)animateDismiss:(UIView*)forView;

@end

@implementation SmartPopup

static SmartPopup *sharedSingleton = nil;
+ (SmartPopup *)instance {
    @synchronized(self) {
        if (!sharedSingleton){
            sharedSingleton = [[self alloc] init];
        }
    }
    return(sharedSingleton);
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.activePopups = [NSMutableArray array];
		
		[[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(orientationChanged:)
													 name:UIDeviceOrientationDidChangeNotification
												   object:nil];
    }
    return self;
}

#pragma mark - Public Methods

- (SmartPopupInstance *)showfromXib:(Class)xibClass withArgs:(NSArray *)args {
    
    if ([xibClass conformsToProtocol:@protocol(SmartPopupViewProtocol)] ) {
        
        id<SmartPopupViewProtocol> popup = [((id<SmartPopupViewProtocol>)xibClass) createFromXib];
        self.customView = popup;
        [popup setArgs:args];
        
        return [self showWithType:SmartPopupTypeXib image:nil title:@"" message:@"" buttons:nil];
    }
    else {
        NSLog(@"Show popup failed. Xib does not conform to popup protocol");
        return nil;
    }
}

- (SmartPopupInstance *)showWithType:(SmartPopupType)type image:(UIImage *)image title:(NSString *)title message:(NSString *)message andButtonBlocks:(SmartPopupButton *)blocks, ... {
    
    NSMutableArray *blockList = [NSMutableArray array];
    va_list args;
    va_start(args, blocks);
    for (SmartPopupButton *arg = blocks; arg != nil; arg = va_arg(args, SmartPopupButton*))
    {
        [blockList addObject:arg];
    }
    va_end(args);
    
    return [self showWithType:type image:image title:title message:message buttons:blockList];
}

- (SmartPopupInstance *)showWithType:(SmartPopupType)type image:(UIImage *)image title:(NSString *)title message:(NSString *)message buttons:(NSArray *)buttons
 {
     //store definition of the popup
     SmartPopupDefinition *popDef = [[SmartPopupDefinition alloc] init];
     popDef.title = title;
     popDef.message = message;
     popDef.type = type;
     popDef.image = image;
     
     popDef.buttonsDefined = buttons;
     popDef.objectId = [self generateInstanceCode];
     
     [self.customView willShowWithId:popDef.objectId];
     
     return [self showWithDefinition:popDef];
}

- (SmartPopupInstance *)showWithImageView:(UIView *)imageV title:(NSString *)title message:(NSString *)message buttons:(NSArray *)buttons {
    
    //store definition of the popup
    SmartPopupDefinition *popDef = [[SmartPopupDefinition alloc] init];
    popDef.title = title;
    popDef.message = message;
    popDef.type = SmartPopupTypeImageView;
    popDef.imageView = imageV;
    
    popDef.buttonsDefined = buttons;
    popDef.objectId = [self generateInstanceCode];
    
    [self.customView willShowWithId:popDef.objectId];
    
    return [self showWithDefinition:popDef];
}

- (SmartPopupInstance *)showWithTitle:(NSString *)title message:(NSString *)message buttons:(NSArray *)buttons {

    //store definition of the popup
    SmartPopupDefinition *popDef = [[SmartPopupDefinition alloc] init];
    popDef.title = title;
    popDef.message = message;
    popDef.type = SmartPopupTypeNoImage;
    
    popDef.buttonsDefined = buttons;
    popDef.objectId = [self generateInstanceCode];
    
    [self.customView willShowWithId:popDef.objectId];
    
    return [self showWithDefinition:popDef];
}

- (void)dismiss:(SmartPopupInstance *)popup {
    
    if ([self.activePopups count] > 0) {


        UIView *container = [self backgroundView];
        
        SmartPopupDefinition *popToDismiss = nil;
        BOOL isTop = NO;
        for (int i = 0; i < [self.activePopups count]; i++) {
            
            SmartPopupDefinition *popDef = self.activePopups[i];
            
            if ([popup isEqualToString:popDef.objectId]) {
                if (i==0) {
                    isTop=YES;
                }
                popToDismiss = popDef;
            }
        }
        
        if (popToDismiss) {
            [self.activePopups removeObject:popToDismiss];
        }
        
        //if the item is the top of the list, remove it animated, else just remove from the array
        if (isTop) {
            UIView *popView = [container viewWithTag:kSmartPopupPopupTag];
            [self animateDismiss:popView];
        }
        
        if ([self.activePopups count] == 0) {
            
            container.tag = 0;
            [UIView animateWithDuration: 0.5f animations:^{
                container.alpha=0;
            } completion:^(BOOL finished) {
                [container removeFromSuperview];
            }];
            
        }
        else {
            //show the next top popup
            [self showWithDefinition:self.activePopups[0]];
        }

        
    }
    
}


#pragma mark - Private Methods

- (SmartPopupInstance *)showWithDefinition:(SmartPopupDefinition *)popup {
    
    //create the background overlay
    UIView *popContainer = [self createBaseBackground];
    
    //create the popup base
    UIView *popView = [self createBaseUIForPopup:popup inContainer:popContainer];
    
    if (popup.type != SmartPopupTypeXib) {
        
        //custom code for default popup content
        float titleXPosition = kSmartPopupBorderMargin;
        CGSize titleSize = CGSizeMake(popView.frame.size.width - kSmartPopupBorderMargin*2, 30);
        switch (popup.type) {
            case SmartPopupTypeImage: {
                
                UIImageView *imv = [[UIImageView alloc] initWithImage:popup.image];
                [popView addSubview:imv];
                CGRect newF = imv.frame;
                newF.origin = CGPointMake(kSmartPopupBorderMargin, kSmartPopupBorderMargin);
                imv.frame = newF;
                
                titleXPosition += newF.size.width+kSmartPopupBorderMargin;
                titleSize = CGSizeMake(titleSize.width - titleXPosition, newF.size.height);
                
                break;
            }
            case SmartPopupTypeImageView: {
                
                [popView addSubview:popup.imageView];
                CGRect newF = popup.imageView.frame;
                newF.origin = CGPointMake(kSmartPopupBorderMargin, kSmartPopupBorderMargin);
                popup.imageView.frame = newF;
                
                titleXPosition += newF.size.width+kSmartPopupBorderMargin;
                titleSize = CGSizeMake(titleSize.width - titleXPosition, newF.size.height);
                
                break;
            }
            case SmartPopupTypeLoading: {
                
                UIActivityIndicatorView *aiv = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                [aiv startAnimating];
                [popView addSubview:aiv];
                CGRect newF = aiv.frame;
                newF.origin = CGPointMake(kSmartPopupBorderMargin, kSmartPopupBorderMargin);
                aiv.frame = newF;
                
                titleXPosition += newF.size.width+kSmartPopupBorderMargin;
                titleSize = CGSizeMake(titleSize.width - titleXPosition, newF.size.height);
                
                break;
            }
            case SmartPopupTypeNoImage:
                break;
            default: ;
        }
        
        //create the content elements
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(titleXPosition, kSmartPopupBorderMargin, titleSize.width, titleSize.height)];
        titleLabel.font = [UIFont boldSystemFontOfSize:16];
        titleLabel.text = NSLocalizedString(popup.title, @"");
        titleLabel.adjustsFontSizeToFitWidth = YES;
        titleLabel.textAlignment = popup.type == SmartPopupTypeNoImage ? NSTextAlignmentCenter : NSTextAlignmentLeft;
        titleLabel.textColor = [UIColor colorWithRed:66/225.f green:66/225.f blue:66/225.f alpha:1];
        //titleLabel.backgroundColor = [UIColor lightGrayColor];
        [popView addSubview:titleLabel];
        
        CGFloat messageHeight = 0;
        CGFloat messageYPosition = titleLabel.frame.size.height+kSmartPopupBorderMargin;
        if ([popup.message length] > 0) {
            
            UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(titleXPosition, messageYPosition + kSmartPopupBorderMargin, titleSize.width, messageHeight)];
            messageLabel.font = [UIFont systemFontOfSize:12];
            messageLabel.text = NSLocalizedString(popup.message, @"");
            messageLabel.numberOfLines = 0;
            messageLabel.textAlignment = NSTextAlignmentLeft;
            messageLabel.textColor = [UIColor colorWithRed:66/225.f green:66/225.f blue:66/225.f alpha:1];
            //messageLabel.backgroundColor = [UIColor yellowColor];
            //calculate the size
            CGSize size = [messageLabel sizeThatFits:CGSizeMake(messageLabel.frame.size.width, CGFLOAT_MAX)];
            
            messageHeight = size.height;
            //update label size
            CGRect newF = messageLabel.frame;
            newF.size.height = messageHeight;
            messageLabel.frame = newF;
            
            [popView addSubview:messageLabel];
            
            messageYPosition += kSmartPopupBottomMessageBorderMargin; //bottom border
        }
        
        //update popup height
        CGRect newF = popView.frame;
        newF.size.height = messageYPosition + messageHeight;
        popView.frame = newF;
        
        //create buttons at bottom of popup
        [self createButtonsForPopup:popup inView:popView];

    }
    else {
        //from xib
    }
	
	//center the popup
	popView.center = popContainer.center;
	
    //show animation
    [self animateLaunch:popup inContainer:popContainer];
    
    return popup.objectId;
}

- (UIViewController *)rootViewController {
	return [UIApplication sharedApplication].windows[0].rootViewController;
}

- (UIView*)createBaseBackground {

    UIView *bg = nil;
    bg = [self backgroundView];
    if (bg == nil) {
		UIView *rootView = [self rootViewController].view;
        CGRect screen = rootView.bounds;
        bg = [[UIView alloc] initWithFrame:screen];
        bg.backgroundColor = [UIColor clearColor];
		bg.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        bg.tag = kSmartPopupBackgroundTag;
		
		UIVisualEffectView *effect = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleRegular]];
		effect.tag = kSmartPopupBackgroundBlurTag;
		effect.frame = screen;
		effect.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
		effect.alpha = 0;
		[bg addSubview:effect];
		[UIView animateWithDuration:0.7 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
			effect.alpha = 0.9;
		} completion:nil];
		
//        UIImageView *iv = [[UIImageView alloc] initWithFrame:screen];
//		iv.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
//		iv.tag = kSmartPopupBackgroundBlurTag;
//		[bg addSubview:iv];

		[[self rootViewController].view addSubview:bg];
//		[self applyBackgroundBlur];
    }

    return bg;
}

- (UIView *)createBaseUIForPopup:(SmartPopupDefinition *)popDef inContainer:(UIView*)container {
    
    UIView *pop;
    
    //check if there's another visible popup and remove it
    if ([self.activePopups count] > 0) {
        //kSmartPopupPopupTag
        UIView *pop = [container viewWithTag:kSmartPopupPopupTag];
        if (pop) {
            [self animateDismiss:pop];
        }
    }
	
    if (popDef.type != SmartPopupTypeXib) {
        CGRect popupSize;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            popupSize = CGRectMake(0, 0, 280, 10);
        }
        else {
            popupSize = CGRectMake(0, 0, 280, 10);
        }
        
        pop = [[UIView alloc] initWithFrame:popupSize];
        pop.clipsToBounds = NO;
        pop.backgroundColor = [UIColor whiteColor];
		
        [container addSubview:pop];
    }
    else {
        
        [self.customView config];
        pop = (UIView *)self.customView;
		
        [container addSubview:pop];
    }
	
    pop.layer.cornerRadius = 6;
    pop.layer.borderWidth = 2;
    pop.layer.borderColor = [UIColor colorWithRed:245.0f/255 green:245.0f/255 blue:245.0f/255 alpha:1].CGColor;
    
    pop.tag = kSmartPopupPopupTag;
    return pop;
}

- (void)createButtonsForPopup:(SmartPopupDefinition*)popup inView:(UIView*)popView {
 
    BOOL sideBySide = NO; //buttons displayed side by side
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        sideBySide = YES;
    }
    else {
    }
    
    //Create the buttons
    NSUInteger buttonsCount = [popup.buttonsDefined count];
    float btnWidth;
    float yPos = popView.frame.size.height + kSmartPopupBorderMargin;
    float xPos = kSmartPopupBorderMargin;
    if (sideBySide) {
        
        btnWidth = (popView.frame.size.width - (buttonsCount*kSmartPopupBorderMargin*2)) / (float)buttonsCount;
    }
    else {
        btnWidth = popView.frame.size.width - kSmartPopupBorderMargin*2;
    }
    
    CGFloat buttonHeight = 0;
    for (int i = 0; i < [popup.buttonsDefined count]; i++) {
        
        SmartPopupButton *btnDef = popup.buttonsDefined[i];
        btnDef.popupId = popup.objectId;
        
        UIImage *buttonImage = [UIImage imageNamed:(i == 0) ? @"BlueButton" : @"GrayButton"];
        buttonImage = [buttonImage stretchableImageWithLeftCapWidth:10 topCapHeight:0];
        [btnDef setBackgroundImage:buttonImage forState:UIControlStateNormal];
        
        UIImage *buttonImageSel = [UIImage imageNamed:(i == 0) ? @"BlueButtonP" : @"GrayButtonP"];
        buttonImageSel = [buttonImageSel stretchableImageWithLeftCapWidth:10 topCapHeight:0];
        [btnDef setBackgroundImage:buttonImageSel forState:UIControlStateHighlighted];
        
        buttonHeight = buttonImage.size.height;
        [popView addSubview:btnDef];
        CGRect btnF = CGRectMake(xPos, yPos, btnWidth, buttonHeight);
        btnDef.frame = btnF;
        
        if (sideBySide) {
            xPos += btnWidth + kSmartPopupBorderMargin*2;
        } else {
            yPos += kSmartPopupBorderMargin + buttonHeight;
        }
    }
    
    if (sideBySide) {
        yPos += kSmartPopupBorderMargin + buttonHeight;
    }
    
    //update popup height
    CGRect newF = popView.frame;
    newF.size.height = yPos;
    popView.frame = newF;

}

- (void)animateLaunch:(SmartPopupDefinition *)popDef inContainer:(UIView*)container {
    
    //init the animator
    UIView *popView = [container viewWithTag:kSmartPopupPopupTag];
    
    
    UIDynamicAnimator *animator = [[UIDynamicAnimator alloc] initWithReferenceView:container];
    self.animator = animator;
    
    //the snap will have no horizontal/vertical movement. Change popView position to add movement.
    popView.center = container.center;
    
    UISnapBehavior *snapBehavior = [[UISnapBehavior alloc] initWithItem:popView snapToPoint:container.center];
    snapBehavior.damping = 0.5;
    [self.animator addBehavior:snapBehavior];
    
    //animate the transparency
    popView.alpha = 0.0;
    popView.transform = CGAffineTransformMakeScale(0.2f, 0.2f);
    [UIView animateWithDuration:0.6f delay:0 usingSpringWithDamping:0.6f initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionBeginFromCurrentState animations:^{
        
        popView.alpha = 1;
        popView.transform = CGAffineTransformIdentity;
    } completion:nil];
    
    //add motion effect
    // Set vertical effect
    UIInterpolatingMotionEffect *verticalMotionEffect = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.y" type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
    verticalMotionEffect.minimumRelativeValue = @(-15);
    verticalMotionEffect.maximumRelativeValue = @(15);
    
    // Set horizontal effect
    UIInterpolatingMotionEffect *horizontalMotionEffect = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.x" type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
    horizontalMotionEffect.minimumRelativeValue = @(-15);
    horizontalMotionEffect.maximumRelativeValue = @(15);
    
    // Create group to combine both
    UIMotionEffectGroup *group = [UIMotionEffectGroup new];
    group.motionEffects = @[horizontalMotionEffect, verticalMotionEffect];
    
    // Add both effects to your view
    [popView addMotionEffect:group];
    
    
    //add the popup to the top of the active list
    [self.activePopups insertObject:popDef atIndex:0];
}

- (void)animateDismiss:(UIView*)forView {
    
    [self.animator removeAllBehaviors];
    forView.tag = 0;
    forView.transform = CGAffineTransformMakeScale(1,1);
    [UIView animateWithDuration:0.5f delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        forView.transform = CGAffineTransformMakeScale(0.6f, 0.6f);
        forView.alpha=0;
    } completion:^(BOOL finished) {
        [forView removeFromSuperview];
    }];
}

- (SmartPopupInstance *)generateInstanceCode {
    CFUUIDRef theUUID = CFUUIDCreate(NULL);
    CFStringRef string = CFUUIDCreateString(NULL, theUUID);
    CFRelease(theUUID);
    NSString *retString = CFBridgingRelease(string);
    
    return retString;
}

- (BOOL)isPopupActive:(SmartPopupInstance *)popup {
    for (SmartPopupDefinition *pop in self.activePopups) {
        if ([popup isEqual:pop.objectId]) {
            return YES;
        }
    }
    return NO;
}

- (UIView *)backgroundView {
	UIView *topView = [self rootViewController].view;
    return [topView viewWithTag:kSmartPopupBackgroundTag];
}

- (void)applyBackgroundBlur {
	
	UIView *topView = [self rootViewController].view;
	UIImageView *view = (UIImageView *)[topView viewWithTag:kSmartPopupBackgroundBlurTag];
	
	BlurArgs *args = [[BlurArgs alloc] init];
	args.tintColor = [UIColor colorWithRed:118/255.0f green:118/255.0f blue:118/255.0f alpha:0];
	args.colorAlpha = 0.2f;
	args.blurFinal = 8;
	args.saturationIncrement = 0.6f;
	
	UIImage *bgImg = [UIImage getImageFromWindow];
	view.image = bgImg;
	[bgImg applyAnimatedBlur:args inView:view];
}

- (void)orientationChanged:(NSNotification *)notification {
	
	UIView *container = [self backgroundView];
	UIView *popView = [container viewWithTag:kSmartPopupPopupTag];
	popView.center = container.center;
}

@end
