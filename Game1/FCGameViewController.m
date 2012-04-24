//
//  FCGameViewController.m
//  Game1
//
//  Created by Руслан Федоров on 4/24/12.
//  Copyright (c) 2012 MIPT iLab. All rights reserved.
//

#import "FCGameViewController.h"

@implementation FCGameViewController{
    ASPGLSprite *first;
}
-(void) viewDidLoad{
    [super viewDidLoad];
    
    first = [ASPGLSprite spriteWithTextureName:@"ball.png" effect: self.effect];
    first.position = GLKVector2Make(self.viewIOSize.width/2, self.viewIOSize.height/2);
    first.contentSize = CGSizeMake(10,10);
    [self.sprites addObject:first];
}

#define A 50
#define B 50
#define a 3
#define b 2
#define q 0
-(void)update{
    static int t = 1;
    first.position = GLKVector2Make(50*sin(2*t+0), 50*sin(3*t));
}
@end
