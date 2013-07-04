//
//  ALWindow.m
//  DemoProject
//
//  Created by Austin Louden on 7/3/13.
//  Copyright (c) 2013 Austin Louden. All rights reserved.
//

#import "ALWindow.h"
#import <MessageUI/MessageUI.h>
#import <QuartzCore/QuartzCore.h>

@implementation ALWindow
@synthesize emailSubject = _emailSubject, emailRecipients = _emailRecipients, emailBody = _emailBody, attachScreenshot = _attachScreenshot;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _attachScreenshot = YES;
    }
    return self;
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (motion == UIEventSubtypeMotionShake) {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                 delegate:self
                                                        cancelButtonTitle:@"Cancel"
                                                   destructiveButtonTitle:nil
                                                        otherButtonTitles:@"Report Bug", nil];
        [actionSheet showInView:self];
    }
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 0) {
        [self showEmailView];
    }    
}

#pragma mark - MFMailComposer

- (void)showEmailView
{
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
        mailer.mailComposeDelegate = self;
        
        // set subject, recipients
        [mailer setSubject:_emailSubject ? _emailSubject : @""];
        if(_emailRecipients) {
            [mailer setToRecipients:_emailRecipients];
        }
        
        // get app version, build number, ios version
        NSString *iosVersion = [UIDevice currentDevice].systemVersion;
        NSString *appVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleShortVersionString"];
        NSString *build = [[NSBundle mainBundle] objectForInfoDictionaryKey: (NSString *)kCFBundleVersionKey];
        NSString *defaultBody = [NSString stringWithFormat:@"Issue:\n\nExpected Behavior:\n\niOS Version: %@\nApp Version: %@\nBuild: %@", iosVersion,appVersion,build];
        [mailer setMessageBody:_emailBody ? _emailBody : defaultBody isHTML:NO];
        
        // take screen shot - note, this will not capture OpenGL ES elements
        if(_attachScreenshot) {
            UIGraphicsBeginImageContext(self.bounds.size);
            [self.layer renderInContext:UIGraphicsGetCurrentContext()];
            UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            NSData *data = UIImagePNGRepresentation(image);
            [mailer addAttachmentData:data mimeType:@"image/png" fileName:@"screenshot"];
        }
        
        [self.rootViewController presentViewController:mailer animated:YES completion:nil];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:@"Your device does not support email."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
}


- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    [self.rootViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
