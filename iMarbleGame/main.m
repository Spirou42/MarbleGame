//
//  main.m
//  MarbleGame
//
//  Created by Carsten Müller on 7/30/13.
//  Copyright Carsten Müller 2013. All rights reserved.
//

#import <UIKit/UIKit.h>

int main(int argc, char *argv[]) {
    
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    int retVal = UIApplicationMain(argc, argv, nil, @"MarbleGameAppDelegate");
    [pool release];
    return retVal;
}
