//
//  FirstViewController.h
//  ruPassword
//
//  Created by Nikita Galayko on 13.12.11.
//  Copyright (c) 2011 Galayko.ru. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GradientButton.h"
#import <MessageUI/MessageUI.h>

@interface FirstViewController : UIViewController <UITextViewDelegate, UIActionSheetDelegate, MFMessageComposeViewControllerDelegate, MFMailComposeViewControllerDelegate, UINavigationControllerDelegate>
{
    UIButton *ClipBtn;
    UITextField *thePass;
    UITextField *useChars;
    UISwitch *numbersSw;
    UISwitch *locaseSw;
    UISwitch *upcaseSw;
    UISwitch *uniqSw;
    UISwitch *specialSw;
    UISwitch *charsSw;
    UILabel *pswlenLabel;

    UILabel *passwordLabel;
    UILabel *passGenSettingLabel;
    UILabel *upcaseLabel;
    UILabel *locaseLabel;
    UILabel *numbersLabel;
    UILabel *uniqCharsLabel;
    UILabel *specialCharsLabel;
    UILabel *useCharsLabel;
    UIButton *generatePassBtn;
    
    UISlider *pswlenSlider;
    IBOutlet UIScrollView *scrollView;
    
    UITextField *currentTextField;
    BOOL keyboardIsShown, iPadDevice;
}

@property (nonatomic, strong) IBOutlet UITextField *thePass;
@property (nonatomic, strong) IBOutlet UITextField *useChars;
@property (nonatomic, strong) IBOutlet UISwitch *numbersSw;
@property (nonatomic, strong) IBOutlet UISwitch *locaseSw;
@property (nonatomic, strong) IBOutlet UISwitch *upcaseSw;
@property (nonatomic, strong) IBOutlet UISwitch *uniqSw;
@property (nonatomic, strong) IBOutlet UISwitch *specialSw;
@property (nonatomic, strong) IBOutlet UISwitch *charsSw;
@property (nonatomic, strong) IBOutlet UIButton *ClipBtn;
@property (nonatomic, strong) IBOutlet UILabel *pswlenLabel;

@property (nonatomic, strong) IBOutlet UILabel *passwordLabel;
@property (nonatomic, strong) IBOutlet UILabel *passGenSettingLabel;
@property (nonatomic, strong) IBOutlet UILabel *upcaseLabel;
@property (nonatomic, strong) IBOutlet UILabel *locaseLabel;
@property (nonatomic, strong) IBOutlet UILabel *numbersLabel;
@property (nonatomic, strong) IBOutlet UILabel *uniqCharsLabel;
@property (nonatomic, strong) IBOutlet UILabel *specialCharsLabel;
@property (nonatomic, strong) IBOutlet UILabel *useCharsLabel;
@property (nonatomic, strong) IBOutlet UIButton *generatePassBtn;

@property (nonatomic, strong) IBOutlet UISlider *pswlenSlider;
@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;
@property (nonatomic, assign) BOOL iPadDevice;

-(IBAction)copyPassToClip:(id)sender;
-(IBAction)generatePassword:(id)sender;
-(IBAction)passLenChanged:(id)sender;

-(void)storeSettings;
-(BOOL)loadSettings;

@end
