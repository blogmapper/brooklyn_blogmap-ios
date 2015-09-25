//
//  BlogpostTableViewController.m
//  BlogMap
//
//  Created by Jacob Colleran on 3/25/15.
//  Copyright (c) 2015 blogMap. All rights reserved.
//
//  Portions of code below were copied or modified with permission from:
//
//  StolpersteinListViewController.m
//  Stolpersteine
//
//  Copyright (C) 2013 Option-U Software
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "BlogpostTableViewController.h"

#import "Blogpost.h"
#import "BlogpostWebViewController.h"
#import "BlogpostNetworkService.h"
#import "AppDelegate.h"
#import "Localization.h"

static NSString * const CELL_IDENTIFIER = @"cell";

@interface BlogpostTableViewController ()

@end

@implementation BlogpostTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //custom background
    UIImageView *backgroundImage;
    backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ios-linen"]];
    [[self view] addSubview:backgroundImage];
    [backgroundImage.superview sendSubviewToBack:backgroundImage];
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"ios-linen"] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.view.backgroundColor = [UIColor clearColor];
    self.navigationController.navigationBar.backgroundColor = [UIColor clearColor];
    
    //custom back button
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Table" style:UIBarButtonItemStylePlain target:nil action:nil];
    backButton.title = @"Table";
    [backButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                        [UIFont fontWithName:@"Futura-Medium" size:16], NSFontAttributeName,
                                        [UIColor whiteColor], NSForegroundColorAttributeName,
                                        nil]
                              forState:UIControlStateNormal];
    self.navigationItem.backBarButtonItem = backButton;
    
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
    
    //remove separator for empty cells
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.blogposts count];
}

- (void)updateWithBlogpost:(Blogpost *)blogpost index:(NSUInteger)index
{
    self.blogpost = blogpost;
    
}

- (BOOL)canSelectCurrentBlogpost
{
    BOOL canSelectRow = (self.blogpost.sourceURL != nil);
    return canSelectRow;
}

//this fixes auto-resizing bug on rotation
-(void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        [self.tableView reloadData];
    } completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        
    }];
    
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_IDENTIFIER forIndexPath:indexPath];
    
    cell.imageView.image = nil;
    
    Blogpost *blogpost = [self.blogposts objectAtIndex:indexPath.row];
    
    tableView.rowHeight = 70.0;
    
    cell.detailTextLabel.lineBreakMode = NSLineBreakByWordWrapping;
    cell.detailTextLabel.numberOfLines = 0;
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:12.0];
    cell.textLabel.text = [NSString stringWithFormat:@"%@, %@", blogpost.address, blogpost.neighborhood];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ | %@",blogpost.sourceName, blogpost.title];
    
    cell.imageView.image = [[UIImage alloc] initWithCIImage:nil];
    
    // Fetch thumbnail using GCD
    dispatch_queue_t downloadThumbnailQueue = dispatch_queue_create("Get Photo Thumbnail", NULL);
    dispatch_async(downloadThumbnailQueue, ^{
        UIImage *originalImage = nil;
        UIImage *thumbnail = nil;
        NSData *imageData = [[NSData alloc] initWithContentsOfURL:blogpost.imageURL];
        originalImage = [[UIImage alloc] initWithData:imageData];
        //NSLog(@"%@", imageData);
        CGSize destinationSize = CGSizeMake(90, 90);
        UIGraphicsBeginImageContext(destinationSize);
        [originalImage drawInRect:CGRectMake(0,0,destinationSize.width,destinationSize.height)];
        thumbnail = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        dispatch_async(dispatch_get_main_queue(), ^{
            UITableViewCell *cellToUpdate = [self.tableView cellForRowAtIndexPath:indexPath]; // create a copy of the cell to avoid keeping a strong pointer to "cell" since that one may have been reused by the time the block is ready to update it.
            if (cellToUpdate != nil) {
                [cellToUpdate.imageView setImage:thumbnail];
                [cellToUpdate setNeedsLayout];
            }
        });
    });
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(tintColor)]) {
        if (tableView == self.tableView) {
            
            
            CGFloat cornerRadius = 5.f;
            cell.backgroundColor = UIColor.clearColor;
            CAShapeLayer *layer = [[CAShapeLayer alloc] init];
            CGMutablePathRef pathRef = CGPathCreateMutable();
            CGRect bounds = CGRectInset(cell.bounds, 5, 0);
            BOOL addLine = NO;
            
            if (indexPath.row == 0 && indexPath.row == [tableView numberOfRowsInSection:indexPath.section]-1) {
                CGPathAddRoundedRect(pathRef, nil, bounds, cornerRadius, cornerRadius);
            } else if (indexPath.row == 0) {
                CGPathMoveToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMaxY(bounds));
                CGPathAddArcToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMinY(bounds), CGRectGetMidX(bounds), CGRectGetMinY(bounds), cornerRadius);
                CGPathAddArcToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMinY(bounds), CGRectGetMaxX(bounds), CGRectGetMidY(bounds), cornerRadius);
                CGPathAddLineToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMaxY(bounds));
                addLine = YES;
            } else if (indexPath.row == [tableView numberOfRowsInSection:indexPath.section]-1) {
                CGPathMoveToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMinY(bounds));
                CGPathAddArcToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMaxY(bounds), CGRectGetMidX(bounds), CGRectGetMaxY(bounds), cornerRadius);
                CGPathAddArcToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMaxY(bounds), CGRectGetMaxX(bounds), CGRectGetMidY(bounds), cornerRadius);
                CGPathAddLineToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMinY(bounds));
            } else {
                CGPathAddRect(pathRef, nil, bounds);
                addLine = YES;
            }
            layer.path = pathRef;
            CFRelease(pathRef);
            layer.fillColor = [UIColor whiteColor].CGColor;
            
            if (addLine == YES) {
                CALayer *layer = cell.layer;
                CALayer *lineLayer = [[CALayer alloc] init];
                CGFloat lineHeight = (1.f / [UIScreen mainScreen].scale);
                lineLayer.frame = CGRectMake(CGRectGetMinX(bounds)+5, bounds.size.height-lineHeight, bounds.size.width-5, lineHeight);
                lineLayer.backgroundColor = tableView.separatorColor.CGColor;
                [layer addSublayer:lineLayer];
            }
            UIView *testView = [[UIView alloc] initWithFrame:bounds];
            [testView.layer insertSublayer:layer atIndex:0];
            testView.backgroundColor = UIColor.clearColor;
            cell.backgroundView = testView;
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
        [self performSegueWithIdentifier:@"showWebView" sender:self];
    
}


- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSLog(@"preparing for segue: %@",segue.identifier);
    
    if ( [segue.identifier isEqualToString:@"showWebView"]){
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        Blogpost *blogpost = [self.blogposts objectAtIndex:indexPath.row];
        BlogpostWebViewController *webViewController = (BlogpostWebViewController *)segue.destinationViewController;
        webViewController.blogpost = blogpost;
        //webViewController.title = @"blogmap";
        
    }
        
}



@end
