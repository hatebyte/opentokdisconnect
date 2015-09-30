//
//  MyOTGLKVideoView.m
//  SimpleOpenTok
//
//  Created by Scott Jones on 9/30/15.
//  Copyright © 2015 Scott Jones. All rights reserved.
//

#import "MyOTGLKVideoView.h"

@implementation MyOTGLKVideoView

- (void)teardownGL {
    [super teardownGL];
    [EAGLContext setCurrentContext:nil];
}

@end
