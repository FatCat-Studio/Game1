//
//  ASPGLKMainVIewController.m
//  Demo
//
//  Created by Руслан Федоров on 4/20/12.
//  Copyright (c) 2012 MIPT iLab. All rights reserved.
//

#import "ASPGLKViewController.h"
#import "ASPGLSprite.h"
@interface ASPGLKViewController ()

@end
@implementation ASPGLKViewController
@synthesize context=_context,effect=_effect,sprites=_sprites,viewIOSize,backgroundColor=_backgroundColor;
-(CGSize)viewIOSize{
	return self.view.bounds.size; //А ларчик просто открывался, бля.
}

#pragma mark Load
- (void) setupGL{
	self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
	if (!_context)
		NSLog(@"Failed to create openGL context");
	((GLKView*)self.view).context=_context;
	[EAGLContext setCurrentContext:_context];
	self.preferredFramesPerSecond=60;
	self.effect = [[GLKBaseEffect alloc] init];
	GLKMatrix4 projectionMatrix = GLKMatrix4MakeOrtho(0,self.viewIOSize.width, 0, self.viewIOSize.height, -1024, 1024);
	//GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(65.0f), self.viewIOSize.height/self.viewIOSize.width, -4.0f, 10.0f);
	self.effect.transform.projectionMatrix = projectionMatrix;
	self.sprites=[NSMutableArray arrayWithCapacity:10];
	self.backgroundColor=GLKVector3Make(0.2, 0.2, 0.2);
}
- (void) viewDidLoad{
	srand(time(NULL));
	[super viewDidLoad];
	[self setupGL];
}
#pragma mark Unload
- (void) tearDownGL{
	if ([EAGLContext currentContext]==_context){
		[EAGLContext setCurrentContext:nil];
	}
	self.context=nil;
}
- (void) viewDidUnload{
	[self tearDownGL];
	[super viewDidUnload];
	
}
#pragma -
#pragma mark Stuff
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
	return YES;
}
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	self.effect.transform.projectionMatrix=GLKMatrix4MakeOrtho(0,self.viewIOSize.width, 0, self.viewIOSize.height, -1024, 1024);
	
}
#pragma mark Drawing
- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect{
	glClearColor(_backgroundColor.x, _backgroundColor.y, _backgroundColor.z, 1);
    glClear(GL_COLOR_BUFFER_BIT);    
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    glEnable(GL_BLEND);
	for (ASPGLSprite *sp in self.sprites) {
		[sp render];
	}
}

- (void) update{
	for (ASPGLSprite *sp in self.sprites){
		[sp update:self.timeSinceLastUpdate];
	}
}


@end