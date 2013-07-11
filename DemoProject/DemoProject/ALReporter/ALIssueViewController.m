//
//  ALIssueViewController.m
//  DemoProject
//
//  Created by Austin Louden on 7/8/13.
//  Copyright (c) 2013 Austin Louden. All rights reserved.
//

#import "ALIssueViewController.h"
#import "UAGithubEngine.h"
#import <QuartzCore/QuartzCore.h>

@interface ALIssueViewController ()
{
    UITapGestureRecognizer *recognizer;
}

@end

@implementation ALIssueViewController
@synthesize engine = _engine, repository = _repository, issueDictionary = _issueDictionary, labels = _labels, asignees = _asignees, milestones = _milestones;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBar.hidden =  YES;
    self.view.backgroundColor = [UIColor colorWithWhite:(245.0f/255.0f) alpha:1.0f];
    [self setupUI];
    [self getRepoData];
    
    recognizer = [[UITapGestureRecognizer alloc] init];
    recognizer.delegate = self;
    recognizer.enabled = NO;
    [self.view addGestureRecognizer:recognizer];
}

#pragma mark - Setup

- (void)setupUI
{
    UILabel *createLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 10.0f, 100.0f, 30.0f)];
    createLabel.text = @"New Issue";
    createLabel.backgroundColor = [UIColor clearColor];
    createLabel.textColor = [UIColor colorWithWhite:0.2f alpha:1.0f];
    createLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:16.0f];
    [self.view addSubview:createLabel];
    
    UILabel *repoLabel = [[UILabel alloc] initWithFrame:CGRectMake(95.0f, 10.0f, 165.0f, 30.0f)];
    repoLabel.text = [NSString stringWithFormat:@"(%@)", [_repository objectForKey:@"name"]];
    repoLabel.backgroundColor = [UIColor clearColor];
    repoLabel.textColor = [UIColor colorWithWhite:0.2f alpha:1.0f];
    repoLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:16.0f];
    [self.view addSubview:repoLabel];
    
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelButton.frame = CGRectMake(265.0f, 11.0f, 50.0f, 30.0f);
    cancelButton.titleLabel.lineBreakMode = NSLineBreakByCharWrapping;
    cancelButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    cancelButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14.0f];
    [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [cancelButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(cancelPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cancelButton];
    
    UITextField *titleField = [[UITextField alloc] initWithFrame:CGRectMake(0.0f, 45.0f, self.view.frame.size.width, 50.0f)];
    titleField.text = @"Title";
    titleField.delegate = self;
    titleField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    titleField.backgroundColor = [UIColor colorWithRed:(59.0f/255.0f) green:(123.0f/255.0f) blue:(191.0f/255.0f) alpha:1.0f];
    titleField.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:16.0f];
    titleField.textAlignment = NSTextAlignmentCenter;
    titleField.textColor = [UIColor whiteColor];
    [self.view addSubview:titleField];
    
    UIButton *assignButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [assignButton setBackgroundColor:[UIColor colorWithRed:(61.0f/255.0f) green:(154.0f/255.0f) blue:(232.0f/255.0f) alpha:1.0f]];
    assignButton.frame = CGRectMake(0.0f, 95.0f, self.view.frame.size.width/2, 50.0f);
    assignButton.titleLabel.lineBreakMode = NSLineBreakByCharWrapping;
    assignButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    assignButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:14.0f];
    [assignButton setTitle:@"Tap to assign\na teammate" forState:UIControlStateNormal];
    [assignButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [assignButton addTarget:self action:@selector(assignPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:assignButton];
    
    UIButton *milestoneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [milestoneButton setBackgroundColor:[UIColor colorWithRed:(89.0f/255.0f) green:(163.0f/255.0f) blue:(252.0f/255.0f) alpha:1.0f]];
    milestoneButton.frame = CGRectMake(self.view.frame.size.width/2, 95.0f, self.view.frame.size.width/2, 50.0f);
    milestoneButton.titleLabel.lineBreakMode = NSLineBreakByCharWrapping;
    milestoneButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    milestoneButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:14.0f];
    [milestoneButton setTitle:@"Tap to set\na milestone" forState:UIControlStateNormal];
    [milestoneButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [milestoneButton addTarget:self action:@selector(milestonePressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:milestoneButton];
    
    UITextView *bodyField = [[UITextView alloc] initWithFrame:CGRectMake(0.0f, 145.0f, self.view.frame.size.width, 150.0f)];
    bodyField.delegate = self;
    bodyField.font = [UIFont fontWithName:@"HelveticaNeue" size:14.0f];
    bodyField.backgroundColor = [UIColor whiteColor];
    bodyField.text = @"Leave a comment...";
    [self.view addSubview:bodyField];
    
    UIButton *createIssueButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [createIssueButton setBackgroundColor:[UIColor colorWithRed:(30.0f/255.0f) green:(30.0f/255.0f) blue:(34.0f/255.0f) alpha:1.0f]];
    createIssueButton.frame = CGRectMake(0.0f, self.view.frame.size.height-50.0f, self.view.frame.size.width, 50.0f);
    createIssueButton.titleLabel.lineBreakMode = NSLineBreakByCharWrapping;
    createIssueButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    createIssueButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:14.0f];
    [createIssueButton setTitle:@"Create Issue" forState:UIControlStateNormal];
    [createIssueButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [createIssueButton addTarget:self action:@selector(createIssuePressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:createIssueButton];
}

- (void)setupLabels
{
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 295.0f, self.view.frame.size.height, self.view.frame.size.height-295.0f-50.0f)];
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.allowsMultipleSelection = YES;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:tableView];
}

- (void)getRepoData
{
    [_engine labelsForRepository:[_repository objectForKey:@"full_name"] success:^(id response) {
        _labels = response;
        [self setupLabels];
    } failure:^(NSError *error) {
        NSLog(@"Request failed with error %@", error);
    }];
    
    [_engine assigneesForRepository:[_repository objectForKey:@"full_name"] success:^(id response) {
        _asignees = response;
    } failure:^(NSError *error) {
        ;
    }];
    
    [_engine milestonesForRepository:@"" success:^(id response) {
        _milestones = response;
    } failure:^(NSError *error) {
        ;
    }];
}

#pragma mark - Actions

- (void)assignPressed
{
    NSLog(@"assign pressed");
}

- (void)milestonePressed
{
    NSLog(@"milestone pressed");
}

- (void)cancelPressed
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)createIssuePressed:(UIButton *)button
{
    /*
     {
         "title": "Found a bug",
         "body": "I'm having a problem with this.",
         "assignee": "octocat",
         "milestone": 1,
         "labels": [
         "Label1",
         "Label2"
         ]
     }
     */
    self.view.userInteractionEnabled = NO;
    _issueDictionary = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@"Test Issue #1", @"title",
                                                                    @"This is the body of the issue.", @"body",
                                                                    @[@"test"],@"labels", nil];
    [button setTitle:@"Submitting issue..." forState:UIControlStateNormal];
    [_engine addIssueForRepository:[_repository objectForKey:@"full_name"] withDictionary:_issueDictionary success:^(id response) {
        [button setTitle:@"Success!" forState:UIControlStateNormal];
    } failure:^(NSError *error) {
        NSLog(@"error");
    }];
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UITextFieldDelegate
#pragma mark - UITextViewDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    recognizer.enabled = YES;
    if([textField.text isEqualToString:@"Title"]) {
        textField.text = @"";
    }
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    recognizer.enabled = YES;
    if([textView.text isEqualToString:@"Leave a comment..."]) {
        textView.text = @"";
    }
    
}

#pragma mark = UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    [self dismissKeyboard];
    recognizer.enabled = NO;
    return YES;
}

- (void)dismissKeyboard
{
    for(UIView* view in [self.view subviews]) {
        if([view isKindOfClass:[UITextField class]] && [view isFirstResponder]) {
            [view resignFirstResponder];
        } else if ([view isKindOfClass:[UITextView class]] && [view isFirstResponder]) {
            [view resignFirstResponder];
        }
    }
}

- (UIColor *)colorFromHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:0]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _labels.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 45.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell Identifier"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Cell Identifier"];
    }
    
    NSDictionary *label = [_labels objectAtIndex:indexPath.row];
    cell.textLabel.text = [label objectForKey:@"name"];
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:14.0f];
    cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.textLabel.textColor = [UIColor colorWithWhite:(25.0f/255.0f) alpha:1.0f];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UIView *labelColorView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 2.0f, 45.0f)];
    labelColorView.backgroundColor = [self colorFromHexString:[label objectForKey:@"color"]];
    [cell.contentView addSubview:labelColorView];
    
    UIView *labelColorView2 = [[UIView alloc] initWithFrame:CGRectMake(self.view.frame.size.width-2.0f, 0.0f, 2.0f, 45.0f)];
    labelColorView2.backgroundColor = [self colorFromHexString:[label objectForKey:@"color"]];
    [cell.contentView addSubview:labelColorView2];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *label = [_labels objectAtIndex:indexPath.row];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.layer.borderColor = [self colorFromHexString:[label objectForKey:@"color"]].CGColor;
    cell.layer.borderWidth = 2.0f;
    
    UIView *alphaView = [[UIView alloc] initWithFrame:CGRectMake(2.0f, 2.0f, self.view.frame.size.width-4.0f, 41.0f)];
    alphaView.tag = 11;
    CGColorRef alphaColor = [self colorFromHexString:[label objectForKey:@"color"]].CGColor;
    alphaView.backgroundColor = [UIColor colorWithCGColor:CGColorCreateCopyWithAlpha(alphaColor, 0.2f)];
    [cell.contentView addSubview:alphaView];
    [cell.contentView sendSubviewToBack:alphaView];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.layer.borderColor = [UIColor clearColor].CGColor;
    cell.layer.borderWidth = 0.0f;
    
    for(UIView *view in [cell.contentView subviews]) {
        if(view.tag == 11) {
            [view removeFromSuperview];
        }
    }
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.y < 0) {
        scrollView.contentOffset = CGPointZero;
    }
}

@end
