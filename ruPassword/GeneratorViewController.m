//
//  GeneratorViewController.m
//  ruPassword
//
//  Created by Nikita Galayko on 13.12.11.
//  Copyright (c) 2011 Galayko.ru. All rights reserved.
//

#import "GeneratorViewController.h"
#import "AppDelegate.h"
#import "iRate.h"
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "NKUtils.h"

#define degreesToRadian(x) (M_PI * (x) / 180.0)

#define IPAD_CONTENT_HEIGHT 549
#define IPHONE_CONTENT_HEIGHT 480

@implementation GeneratorViewController

@synthesize ClipBtn, thePass, useChars, numbersSw, locaseSw, upcaseSw, uniqSw, specialSw, charsSw, pswlenLabel, pswlenSlider, scrollView, passwordLabel, passGenSettingLabel, upcaseLabel, locaseLabel, numbersLabel, uniqCharsLabel, specialCharsLabel, useCharsLabel, generatePassBtn;
@synthesize iPadDevice;

- (void)sendInAppSMS:(NSString *)str
{
    [Flurry logEvent:@"Generator.Send.SMS"];
    if ( [[[UIDevice currentDevice] systemVersion] doubleValue ] >= 4.0 )
    {
        MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
        if([MFMessageComposeViewController canSendText])
        {
            controller.body = str;
            controller.recipients = nil;
            controller.messageComposeDelegate = self;
            [self presentViewController:controller animated:YES completion:nil];
        }
    }
    else
    {
        copyStrToClipboard(str);
        [[UIApplication sharedApplication] openURL: [NSURL URLWithString: @"sms:"]];
    }
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
	switch (result)
    {
		case MessageComposeResultFailed:
            [[[UIAlertView alloc] initWithTitle: [iRate sharedInstance].applicationName message: NSLocalizedString(@"Failed to Send SMS", @"Ошибка отправки СМС!") delegate: self cancelButtonTitle: @"OK" otherButtonTitles: nil, nil] show];
            break;
//		case MessageComposeResultCancelled:
//		case MessageComposeResultSent:
		default:
			break;
	}
	[self dismissModalViewControllerAnimated:YES];
}

// Displays an email composition interface inside the application. Populates all the Mail fields.
- (void)sendEmail:(NSString *)pass
{
    DLog(@"notify Others");
    [Flurry logEvent:@"Generator.Send.Email"];
    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
    picker.mailComposeDelegate = self;
    picker.delegate = self;
    
    [picker setSubject: [iRate sharedInstance].applicationName];
    
    
    // Set up recipients
    /*NSArray *toRecipients = [NSArray arrayWithObject:@"first@example.com"];
     NSArray *ccRecipients = [NSArray arrayWithObjects:@"second@example.com", @"third@example.com", nil];
     NSArray *bccRecipients = [NSArray arrayWithObject:@"fourth@example.com"];
     
     [picker setToRecipients:toRecipients];
     [picker setCcRecipients:ccRecipients];
     [picker setBccRecipients:bccRecipients];*/
    
    // Attach an image to the email
    //NSString *path = [[NSBundle mainBundle] pathForResource:@"rainy" ofType:@"png"];
    //NSData *myData = [NSData dataWithContentsOfFile:path];
    //[picker addAttachmentData:myData mimeType:@"image/png" fileName:@"rainy"];
    
    // Fill out the email body text
    NSString *emailBody = [NSString stringWithFormat: @"%@", pass];
    
    // html email
    [picker setMessageBody: emailBody isHTML: YES];
    
    if (picker != nil)
    {
        [self presentModalViewController: picker animated: YES];
    }
    else
    {
        DLog(@"Mail not configured on the device");
    }
}

// Dismisses the email composition interface when users tap Cancel or Send. Proceeds to update the message field with the result of the operation.
- (void)mailComposeController: (MFMailComposeViewController *) controller didFinishWithResult: (MFMailComposeResult) result error: (NSError *) error
{
    NSString *message;
    UIAlertView *v;
    // Notifies users about errors associated with the interface
    switch (result) {
        case MFMailComposeResultCancelled:
            message = @"Result: canceled";
            break;
            
        case MFMailComposeResultSaved:
            message = @"Result: saved";
            break;
            
        case MFMailComposeResultSent:
            message = @"Sent Email OK";
            //v = [[UIAlertView alloc] initWithTitle:@"App Email" message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            //[v show];
            //[v release];
            break;
            
        case MFMailComposeResultFailed:
            message = NSLocalizedString(@"Failed to Send Email", @"Ошибка отправки E-Mail!");
            v = [[UIAlertView alloc] initWithTitle: [iRate sharedInstance].applicationName message: message delegate: self cancelButtonTitle: @"OK" otherButtonTitles: nil, nil];
            [v show];
            break;
            
        default:
            message = @"Result: not sent";
            break;
    }
    DLog(@"message = %@", message);
    // display an error
    [self dismissModalViewControllerAnimated: YES];
}

- (void)hideKeyboard
{
    if ([thePass isFirstResponder])
        [thePass resignFirstResponder];
    if ([useChars isFirstResponder])
        [useChars resignFirstResponder];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    DLog(@"buttonIndex = %i", buttonIndex);
    if ( buttonIndex == actionSheet.cancelButtonIndex ) return;
    NSString *s = thePass.text;
    switch (buttonIndex)
    {
        case 0:
            copyStrToClipboard(s);
            break;
        case 1:
            [self sendInAppSMS:s];
            break;
            
        case 2:
            [self sendEmail:s];
            break;
            
        default:
            break;
    }
}

- (void)checkCanClip
{
    ClipBtn.hidden = (thePass.text.length < 1 );
}

- (IBAction)passLenChanged:(id)sender
{
    int pswlen = pswlenSlider.value;
    pswlenLabel.text = [NSString stringWithFormat:NSLocalizedString(@"PasswordLengthStr", @""), pswlen];
    [self generatePassword:nil];
}

- (IBAction)generatePassword:(id)sender
{
    [Flurry logEvent:@"Generator.Generate.Password"];
    [self fetchPasswordGeneratorSettings];
    
    thePass.text = [passGenerator generate];

    if ( pswlenSlider.value != passGenerator.passwordLength )
    {
        pswlenSlider.value = passGenerator.passwordLength;
        [self passLenChanged:self];
    }
    pswlenSlider.maximumValue = [passGenerator maximumLength];
    
    [self hideKeyboard];
    
    [self checkCanClip];
    if (sender)
    {
        [[iRate sharedInstance] logEvent:NO];
        [passGenerator saveSettings];
    }
}

- (UITapGestureRecognizer *)tapGesture
{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    tap.numberOfTapsRequired = 1;
    tap.delegate = self;
    tap.cancelsTouchesInView = NO;
    return tap;
}

- (void)handleTapGesture:(UITapGestureRecognizer *)tapGesture
{
    [Flurry logEvent:@"Generator.TapGesture" withParameters:[NSDictionary dictionaryWithObject:[tapGesture.view class] forKey:@"view.class"]];
    [self hideKeyboard];
}

- (IBAction)copyPassToClip:(id)sender
{
    [self hideKeyboard];
    [Flurry logEvent:@"Generator.CopyToClipboard"];
    copyStrToClipboard(thePass.text);
    [[iRate sharedInstance] logEvent:NO];
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"ClipBtn", @"Копировать") delegate:self
                                                    cancelButtonTitle:NSLocalizedString(@"Cancel", @"Отмена")
                                               destructiveButtonTitle:nil 
                                                    otherButtonTitles:NSLocalizedString(@"Copy to Clipboard", @"Копировать"),
                                                                      NSLocalizedString(@"Send by SMS", @"Отправить по СМС..."),
                                                                      NSLocalizedString(@"Send by E-Mail", @"Отправить по E-Mail..."), nil];
    actionSheet.delegate = self;
    [actionSheet showFromTabBar:self.tabBarController.tabBar];
}

- (void)fetchPasswordGeneratorSettings
{
    passGenerator.passwordLength = (int)pswlenSlider.value;
    passGenerator.useUpcaseChars = upcaseSw.isOn;
    passGenerator.useLocaseChars = locaseSw.isOn;
    passGenerator.useOnlyUniqueChars = uniqSw.isOn;
    passGenerator.useNumbers = numbersSw.isOn;
    passGenerator.useSpecialChars = specialSw.isOn;
    passGenerator.useCustomChars = charsSw.isOn;
    passGenerator.customChars = useChars.text;
}

- (void)updatePasswordGeneratorSettingsAnimated:(BOOL)animated
{
    pswlenSlider.value = passGenerator.passwordLength;
    [upcaseSw setOn:passGenerator.useUpcaseChars animated:animated];
    [locaseSw setOn:passGenerator.useLocaseChars animated:animated];
    [uniqSw setOn:passGenerator.useOnlyUniqueChars animated:animated];
    [specialSw setOn:passGenerator.useSpecialChars animated:animated];
    [numbersSw setOn:passGenerator.useNumbers animated:animated];
    [charsSw setOn:passGenerator.useCustomChars animated:animated];
    useChars.text = passGenerator.customChars;
    pswlenSlider.maximumValue = passGenerator.maximumLength;
}

- (void)storeSettings
{
    [self fetchPasswordGeneratorSettings];
    [passGenerator saveSettings];
}

- (IBAction)defaultSettings:(id)sender
{
    [passGenerator defaultSettings];
    [self updatePasswordGeneratorSettingsAnimated:YES];
}

- (void)loadSettings
{
    [passGenerator loadSettings];
    [self updatePasswordGeneratorSettingsAnimated:NO];
}

#pragma mark - Edits & keyboard lifecycle

//---when a TextField view begins editing---
- (void)textFieldDidBeginEditing:(UITextField *)textFieldView
{  
    currentTextField = textFieldView;
}

//---when a TextField view is done editing---
- (void)textFieldDidEndEditing:(UITextField *) textFieldView
{  
    currentTextField = nil;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[textField resignFirstResponder];
	return NO;
}

- (void)moveScrollViewForKeyboard:(NSNotification*)aNotification up: (BOOL) up
{
    NSDictionary* userInfo = [aNotification userInfo];
    
    // Get animation info from userInfo
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    
    CGRect keyboardEndFrame;
    
    [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    
    if ( [[[UIDevice currentDevice] systemVersion] doubleValue] < 3.2 )
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated"
        [[userInfo objectForKey:UIKeyboardBoundsUserInfoKey] getValue:&keyboardEndFrame];
#pragma GCC diagnostic pop
    else
        [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardEndFrame];
    
    
    // Animate up or down
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:animationCurve];
    
    CGRect newFrame = scrollView.frame;
    CGRect keyboardFrame = [self.view convertRect:keyboardEndFrame toView:nil];
    
    newFrame.size.height -= ( keyboardFrame.size.height /* - appDelegate.tabBarController.tabBar.frame.size.height */ ) * (up? 1 : -1);
    scrollView.frame = newFrame;
    
    if ( up )
    {
        CGRect textFieldRect = [currentTextField frame];
        [scrollView scrollRectToVisible:textFieldRect animated:YES];
    }
    
    [UIView commitAnimations];
}

- (void)keyboardWillShow:(NSNotification *) notification
{
    [self moveScrollViewForKeyboard:notification up:YES];
}

- (void)keyboardWillHide:(NSNotification *) notification
{
    [self moveScrollViewForKeyboard:notification up:NO];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    iPadDevice = ( ([UIDevice instancesRespondToSelector:@selector(userInterfaceIdiom)]) && ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) );
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        self.title = NSLocalizedString(@"Generator", @"Generator");
        self.tabBarItem.image = [UIImage imageNamed:@"key"];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [self storeSettings];
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (void)applicationWillTerminateNotification:(NSNotification *)notification
{
    [self storeSettings];
}

#pragma mark - View lifecycle

- (void)localize
{
    passwordLabel.text = NSLocalizedString(@"passwordLabel", @"passwordLabel");
    [generatePassBtn setTitle: NSLocalizedString(@"generatePassBtn", @"generatePassBtn") forState:UIControlStateNormal];
    [ClipBtn setTitle: NSLocalizedString(@"ClipBtn", @"ClipBtn") forState:UIControlStateNormal];
    passGenSettingLabel.text = NSLocalizedString(@"passGenSettingLabel", @"passGenSettingLabel");
    upcaseLabel.text = NSLocalizedString(@"upcaseLabel", @"upcaseLabel");
    locaseLabel.text = NSLocalizedString(@"locaseLabel", @"locaseLabel");
    numbersLabel.text = NSLocalizedString(@"numbersLabel", @"numbersLabel");
    uniqCharsLabel.text = NSLocalizedString(@"uniqCharsLabel", @"uniqCharsLabel");
    specialCharsLabel.text = NSLocalizedString(@"specialCharsLabel", @"specialCharsLabel");
    useCharsLabel.text = NSLocalizedString(@"useCharsLabel", @"useCharsLabel");
    useChars.placeholder = NSLocalizedString(@"useCharsPlaceholder", @"useCharsPlaceholder");
    self.navigationItem.title = NSLocalizedString(@"Password Generator",nil);
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    passGenerator = [PasswordGenerator generator];
    [self loadSettings];
    [ClipBtn useImages:@"InstallButton" pressedImage:@"InstallButtonPressed" capWidth:3 capHeight:11];
    [generatePassBtn useImages:@"InstallButton" pressedImage:@"InstallButtonPressed" capWidth:3 capHeight:11];
    
//    [generatePassBtn useWhiteStyle]; [ClipBtn useWhiteActionSheetStyle];
    [self localize];
    
    [self updateScrollContentSize];
    [self checkCanClip];
    srand([[NSDate date] timeIntervalSince1970]);
    [self passLenChanged:self];
    if ( [[[UIDevice currentDevice] systemVersion] floatValue] >= 3.2 )
    {
        self.view.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];
    }
    [self.view addGestureRecognizer:[self tapGesture]];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    //---registers the notifications for keyboard---
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(keyboardWillShow:) 
                                                 name:UIKeyboardWillShowNotification
                                               object:self.view.window]; 
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(applicationWillTerminateNotification:)
                                                 name:UIApplicationWillTerminateNotification
                                               object:[UIApplication sharedApplication]];

    if ( [[[UIDevice currentDevice] systemVersion] doubleValue] >= 4.0 )
    {
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(applicationWillTerminateNotification:)
                                                     name:UIApplicationDidEnterBackgroundNotification
                                                   object:[UIApplication sharedApplication]];
    }
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    //---removes the notifications for keyboard---
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillTerminateNotification object:nil];

    if ( [[[UIDevice currentDevice] systemVersion] doubleValue] >= 4.0 )
    {
        [[NSNotificationCenter defaultCenter] 
         removeObserver:self 
         name:UIApplicationDidEnterBackgroundNotification 
         object:nil];
    }
    
    [self storeSettings];

	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    [self updateScrollContentSize];
    return YES;
}

- (BOOL)shouldAutorotate
{
    [self updateScrollContentSize];
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

- (void)updateScrollContentSize
{
    CGRect viewFrame = self.view.frame;
    CGFloat width = viewFrame.size.width;
    CGFloat height = viewFrame.size.height;
    if (iPadDevice)
    {
        scrollView.frame = CGRectMake(0, 44, width, height);
        [scrollView setContentSize:CGSizeMake(width, IPAD_CONTENT_HEIGHT)];
    }
    else
    {
        scrollView.frame = CGRectMake(0, 0, width, height);
        [scrollView setContentSize:CGSizeMake(width, IPHONE_CONTENT_HEIGHT)];
    }
}

@end
