//
//  NSString+Ext.m
//  BjAiSports
//
//  Created by 吴林丰 on 2018/12/18.
//  Copyright © 2018 吴林丰. All rights reserved.
//

#import "NSString+Ext.h"
#include <sys/types.h>
#include <sys/sysctl.h>
#include <sys/socket.h> // Per msqr
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>

@implementation NSString (Ext)


-(void)test{
    NSLog(@"haha");
}
@end
