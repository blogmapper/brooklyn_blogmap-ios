//
//  InfoViewController.m
//  BlogMap
//
//  Created by Jacob Colleran on 3/25/15.
//  Copyright (c) 2015 blogMap. All rights reserved.
//

#import "InfoViewController.h"

#import "TUSafariActivity.h"
#import "AFNetworkActivityIndicatorManager.h"
#import "AppDelegate.h"

#import <MessageUI/MessageUI.h>

#define APP_STORE_ID @"1010898388"

#define FEEDBACK_SECTION 0
#define RATING_SECTION 1
#define FACEBOOK_SECTION 2
#define TWITTER_SECTION 3

@interface InfoViewController () <MFMailComposeViewControllerDelegate>

@end

@implementation InfoViewController
{
    NSMutableArray *tableData;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //background image
    UIImageView *backgroundImage;
    backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ios-linen"]];
    [[self view] addSubview:backgroundImage];
    [backgroundImage.superview sendSubviewToBack:backgroundImage];
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"ios-linen"] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.view.backgroundColor = [UIColor clearColor];
    self.navigationController.navigationBar.backgroundColor = [UIColor clearColor];
    
    //custom title
    UILabel *labelTitle = [[UILabel alloc] initWithFrame:CGRectZero];
    labelTitle.backgroundColor = [UIColor clearColor];
    labelTitle.font = [UIFont fontWithName:@"Bauhaus 93" size:30];
    labelTitle.textAlignment = NSTextAlignmentCenter;
    labelTitle.textColor = [UIColor colorWithRed:28.0/255.0 green:154.0/255.0 blue:28.0/255.0 alpha:1.0];
    self.navigationItem.titleView = labelTitle;
    labelTitle.text = @"blogMap";
    [labelTitle sizeToFit];
    
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithAttributedString:labelTitle.attributedText];
    [text addAttribute:NSForegroundColorAttributeName
                 value:[UIColor colorWithRed:193.0/255.0 green:35.0/255.0 blue:35.0/255.0 alpha:1.0]
                 range:NSMakeRange(4, 3)];
    [labelTitle setAttributedText:text];
    
    //initialize table content
    tableData = [NSMutableArray arrayWithObjects:@"Give us feedback", @"Rate us in App Store", @"Like us on Facebook", @"Follow us on Twitter", nil];
    
    //remove separator for empty cells
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
}

-(void)viewDidLayoutSubviews
{
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.tableView setLayoutMargins:UIEdgeInsetsZero];
    }
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    

}


- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    // To make sure table cells have correct height
    [self.tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [tableData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"SimpleTableItem";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    
    cell.textLabel.text = [tableData objectAtIndex:indexPath.row];
    //cell.textLabel.textColor = [UIColor colorWithRed:38.0/255.0 green:242.0/255.0 blue:195.0/255.0 alpha:1.0];
    cell.textLabel.textColor = [UIColor whiteColor];
    
    cell.contentView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"ios-linen"]];
    cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    if (indexPath.row == FEEDBACK_SECTION) {
        cell.imageView.image = [UIImage imageNamed:@"email-iconMint.png"];
    }
    
    if (indexPath.row == RATING_SECTION) {
        cell.imageView.image = [UIImage imageNamed:@"rateusicon.png"];
    }
    
    if (indexPath.row == FACEBOOK_SECTION) {
        cell.imageView.image = [UIImage imageNamed:@"FB-fLogo-Blue-printpackaging.png"];
    }
    
    if (indexPath.row == TWITTER_SECTION) {
        cell.imageView.image = [UIImage imageNamed:@"TwitterLogo_#55acee.png"];
    }
    
    
    
    [self.tableView setBackgroundColor:[UIColor grayColor]];
    
    [tableView setSeparatorColor:[UIColor grayColor]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString *urlString;
    
    if (indexPath.row == FEEDBACK_SECTION) {
        NSString *subject = @"blogMap | Brooklyn iPhone/iPad App";
        [self sendMailWithRecipient:@"support@blogmapapp.com" subject: subject message:nil];
    }
    
    if (indexPath.row == RATING_SECTION) {
        urlString = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id%@", APP_STORE_ID];
    }
    
    if (indexPath.row == FACEBOOK_SECTION) {
        urlString = @"fb://profile/881418721928515";
    }
    
    if (indexPath.row == TWITTER_SECTION) {
        urlString = @"twitter://user?screen_name=blogMap";
    }

    
    NSURL *url = [NSURL URLWithString:urlString];
    if ([UIApplication.sharedApplication canOpenURL:url]) {
        [UIApplication.sharedApplication openURL:url];
    } else {
        if (indexPath.row != FEEDBACK_SECTION) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"You do not have this app extension on your device." message:nil preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
            
            [alertController addAction:ok];
            [self presentViewController:alertController animated:YES completion:nil];
            
            }
    }
    

}

- (void)sendMailWithRecipient:(NSString *)recipient subject:(NSString *)subject message:(NSString *)message
{
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *composeViewController = [[MFMailComposeViewController alloc] init];
        composeViewController.mailComposeDelegate = self;
        
        if (recipient) {
            composeViewController.toRecipients = @[recipient];
        }
        composeViewController.subject = subject;
        [composeViewController setMessageBody:message isHTML:NO];
        
        [self presentViewController:composeViewController animated:YES completion:NULL];
    }
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

@end

