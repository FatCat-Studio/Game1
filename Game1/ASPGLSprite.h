//
//  ASPGLSprite.h
//  Demo
//
//  Created by Руслан Федоров on 4/20/12.
//  Copyright (c) 2012 MIPT iLab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

@interface ASPGLSprite : NSObject

@property (strong,nonatomic) NSString *fileName;
@property (strong) NSString *name;
@property (assign) GLKVector2 position;
@property (nonatomic) CGSize contentSize;
@property (assign) GLKVector2 velocity;
@property (assign) GLfloat rotation;
@property (assign) BOOL hidden;

#pragma mark Class Methods
+ (ASPGLSprite*) spriteWithTextureName:(NSString*)fileName effect:(GLKBaseEffect*)effect;
+ (GLKTextureInfo*) loadTextureToStorage:(NSString*)fileName;
+ (void) clearTextureCache;
#pragma mark Init
- (id)initWithFile:(NSString *)fileName 
			effect:(GLKBaseEffect *)effect
		  position:(GLKVector2)position
			bounds:(CGSize)size 
respectAspectRatio:(BOOL)respectAR;
- (id)initWithFile:(NSString *)fileName 
			effect:(GLKBaseEffect *)effect 
		  position:(GLKVector2)position
			bounds:(CGSize)size;
- (id)initWithFile:(NSString *)fileName 
			effect:(GLKBaseEffect *)effect
		  position:(GLKVector2)position;
- (id)initWithFile:(NSString *)fileName 
			effect:(GLKBaseEffect *)effect 
			bounds:(CGSize)size;
- (id)initWithFile:(NSString *)fileName 
			effect:(GLKBaseEffect *)effect 
			bounds:(CGSize)size 
respectAspectRatio:(BOOL)respectAR;
- (id)initWithFile:(NSString *)fileName 
			effect:(GLKBaseEffect *)effect;
#pragma mark -
- (void)render;
- (void)update:(CGFloat)dt;
- (void)outOfView;
- (void)enableDebugOnView:(UIView*)view;
@end

@interface ASPGLSprite (Coordinates)
@property (nonatomic) GLKVector2 centerPosition;
@end

//#pragma mark - Prototypes -
//static __inline__ bool interceptRect(ASPGLSprite *sp1,ASPGLSprite *sp2){
//}

