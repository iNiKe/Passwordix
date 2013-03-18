//
//  GeneratorViewController.h
//  ruPassword
//
//  Created by Nikita Galayko on 13.12.11.
//  Copyright (c) 2011 Galayko.ru. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GradientButton.h"
#import <MessageUI/MessageUI.h>
#import "PasswordGenerator.h"

@interface GeneratorViewController : UIViewController <UITextViewDelegate, UIActionSheetDelegate, MFMessageComposeViewControllerDelegate, MFMailComposeViewControllerDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate>
{
    BOOL keyboardIsShown, iPadDevice;
    PasswordGenerator *passGenerator;
    UITextField *currentTextField;
}

@property (nonatomic, strong) IBOutlet UITextField *thePass, *useChars;
@property (nonatomic, strong) IBOutlet UISwitch *numbersSw, *locaseSw, *upcaseSw, *uniqSw, *specialSw, *charsSw;
@property (nonatomic, strong) IBOutlet UIButton *ClipBtn;
@property (nonatomic, strong) IBOutlet UILabel *pswlenLabel;

@property (nonatomic, strong) IBOutlet UILabel *passwordLabel, *passGenSettingLabel, *upcaseLabel, *locaseLabel, *numbersLabel, *uniqCharsLabel, *specialCharsLabel, *useCharsLabel;
@property (nonatomic, strong) IBOutlet UIButton *generatePassBtn;

@property (nonatomic, strong) IBOutlet UISlider *pswlenSlider;
@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;
@property (nonatomic, assign) BOOL iPadDevice;

- (IBAction)copyPassToClip:(id)sender;
- (IBAction)generatePassword:(id)sender;
- (IBAction)passLenChanged:(id)sender;
- (IBAction)defaultSettings:(id)sender;

@end
