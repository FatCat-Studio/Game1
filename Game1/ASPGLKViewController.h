//
//  ASPGLKViewController.h
//  Demo
//
//  Created by Руслан Федоров on 4/22/12.
//  Copyright (c) 2012 MIPT iLab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
#import "ASPGLSprite.h"
@interface ASPGLKViewController : GLKViewController
@property (strong) GLKBaseEffect * effect;
@property (strong,nonatomic) EAGLContext *context;
@property (strong,nonatomic) NSMutableArray *sprites;
@property (readonly) CGSize viewIOSize;
@property (assign) GLKVector3 backgroundColor;
@end
