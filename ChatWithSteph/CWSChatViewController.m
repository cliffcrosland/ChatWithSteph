//
//  CWSChatViewController.m
//  ChatWithSteph
//
//  Created by Clifton Crosland on 7/12/13.
//  Copyright (c) 2013 Clifton Crosland. All rights reserved.
//

#import "CWSChatViewController.h"
#import "CWSSecrets.h"
#import <Firebase/Firebase.h>
#import <Parse/Parse.h>

@interface CWSChatViewController ()

@end

@implementation CWSChatViewController

@synthesize chatList;
@synthesize userName;
@synthesize firebase;

@synthesize inputzTextField;
@synthesize chatzTableView;
@synthesize nameButton;

#pragma mark - Starten up, the SHIELD. I mean Firebase.

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    // For the time being, you start as the great Stephanie!!!
    userName = @"Stephanie";
    [self setButtonLabelToName: userName];
    
    // To hold our chat
    chatList = [[NSMutableArray alloc] init];
    
    // Set up table delegate-ness
    chatzTableView.delegate = self;
    chatzTableView.dataSource = self;
    inputzTextField.delegate = self;
    
    // Firebase sicknAAASSSSSS
    firebase = [[Firebase alloc] initWithUrl:[CWSSecrets secretForKey:@"firebase-root-url"]];
    
    [firebase observeEventType:FEventTypeChildAdded withBlock:^(FDataSnapshot *snapshot) {
        [chatList addObject:@{ @"idName": snapshot.name, @"value": snapshot.value}];
        [chatzTableView reloadData];
    }];
    
    [firebase observeEventType:FEventTypeChildChanged withBlock:^(FDataSnapshot *snapshot) {
        int i = [self indexOfChatItemWithIdName:snapshot.name];
        if (i == -1) return;
        [chatList replaceObjectAtIndex:i withObject:@{ @"idName": snapshot.name, @"value": snapshot.value}];
        [chatzTableView reloadData];
    }];
    
    [firebase observeEventType:FEventTypeChildRemoved withBlock:^(FDataSnapshot *snapshot) {
        int i = [self indexOfChatItemWithIdName:snapshot.name];
        if (i == -1) return;
        [chatList removeObjectAtIndex:i];
        [chatzTableView reloadData];
    }];
    
}

#pragma mark - Post/delete message to firebase

- (void)postMessage:(NSString *)message
{
    inputzTextField.text = @"";
    
    // Add message to firebase
    [[firebase childByAutoId] setValue:@{@"userName" : userName, @"text" : message}];
    
    // Send push notification to Parse
    NSString *pushMessage = [NSString stringWithFormat:@"%@ said \"%@\"", userName, message];
    [PFPush sendPushMessageToChannelInBackground:@"messages" withMessage:pushMessage];
}

- (void)deleteMessageWithIdName:(NSString *)idName
{
    [[firebase childByAppendingPath:idName] removeValue];
}

#pragma mark - chat list helpers

- (int)indexOfChatItemWithIdName:(NSString *)idName
{
    for (int i = 0; i < [chatList count]; i++) {
        NSDictionary *item = [chatList objectAtIndex:i];
        if ([item[@"idName"] isEqualToString: idName]) {
            return i;
        }
    }
    return -1;
}

#pragma mark - name button handling

- (IBAction)nameButtonPressed:(id)sender
{
    userName = [userName isEqualToString:@"Cliff"] ? @"Stephanie" : @"Cliff";
    [self setButtonLabelToName: userName];
}

- (void)setButtonLabelToName:(NSString *)name
{
    NSString *buttonLabel = [NSString stringWithFormat:@"From %@", name];
    [nameButton setTitle:buttonLabel forState:UIControlStateNormal];
}

#pragma mark - text field handling

- (BOOL)textFieldShouldReturn:(UITextField*)aTextField
{
    [aTextField resignFirstResponder];
    
    [self postMessage: aTextField.text];
    
    return NO;
}

#pragma mark - table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [chatList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell.textLabel.font = [UIFont systemFontOfSize:14];
    cell.textLabel.numberOfLines = 0; // use as many lines as necessary.
    
    // Reverse order
    int index = ([chatList count] - 1) - indexPath.row;
    
    NSDictionary *chatMessage = [chatList objectAtIndex:index][@"value"];
    
    cell.textLabel.text = chatMessage[@"text"];
    cell.detailTextLabel.text = chatMessage[@"userName"];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int index = ([chatList count] - 1) - indexPath.row;
    NSString *message = [chatList objectAtIndex:index][@"value"][@"text"];
    
    CGSize tableSize = [tableView contentSize];
    
    CGSize computedSize = [message sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:tableSize lineBreakMode:NSLineBreakByWordWrapping];
    
    return computedSize.height + 50;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle != UITableViewCellEditingStyleDelete) return;
    
    // tableview row index is reverse of chatList index.
    int chatIndex = ([chatList count] - 1) - indexPath.row;
    NSDictionary *chatItem = [chatList objectAtIndex:chatIndex];
    
    [self deleteMessageWithIdName:chatItem[@"idName"]];
}

@end
