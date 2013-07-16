//
//  CWSChatViewController.h
//  ChatWithSteph
//
//  Created by Clifton Crosland on 7/12/13.
//  Copyright (c) 2013 Clifton Crosland. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Firebase/Firebase.h>

@interface CWSChatViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (nonatomic, strong) Firebase *firebase;
@property (nonatomic, strong) NSMutableArray *chatList;
@property (nonatomic, strong) NSString *userName;

@property (weak, nonatomic) IBOutlet UITableView *chatzTableView;
@property (weak, nonatomic) IBOutlet UITextField *inputzTextField;
@property (weak, nonatomic) IBOutlet UIButton *nameButton;

- (IBAction)nameButtonPressed:(id)sender;

@end
