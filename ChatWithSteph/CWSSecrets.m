//
//  CWSSecrets.m
//  ChatWithSteph
//
//  Created by Clifton Crosland on 7/15/13.
//  Copyright (c) 2013 Clifton Crosland. All rights reserved.
//

#import "CWSSecrets.h"

@implementation CWSSecrets

+ (NSString *)secretForKey:(NSString *)key
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Secrets" ofType:@"plist"];
    NSDictionary *secrets = [[NSDictionary alloc] initWithContentsOfFile:path];
    return [secrets objectForKey:key];
}

@end
