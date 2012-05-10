//
//  ASPGLSprite.m
//  Demo
//
//  Created by Руслан Федоров on 4/20/12.
//  Copyright (c) 2012 MIPT iLab. All rights reserved.
//

#import "ASPGLSprite.h"
#define DEFAULT_AR YES
#define DEFAULT_BOUNDS CGSizeMake(0,0)
#define DEFAULT_POS GLKVector2Make(0,0)

//Геометрические и текстурные вершины для opengl 
typedef struct {
    CGPoint geometryVertex;
    CGPoint textureVertex;
} TexturedVertex;
typedef struct {
    TexturedVertex bl;
    TexturedVertex br;    
    TexturedVertex tl;
    TexturedVertex tr;    
} TexturedQuad;


@interface ASPGLSprite(){
//	Летающий лейбл рядом с обьектом, для дебага
	UILabel *_debugLabel;
	UIView *_debugView;
	GLfloat aspect;
}
//GLKit stuff
@property (strong) GLKBaseEffect * effect;
@property (assign) TexturedQuad quad;
@property (strong) GLKTextureInfo * textureInfo;

+ (void) addSpriteToFreeCache:(ASPGLSprite*)sp;
@end

@implementation ASPGLSprite

@synthesize effect = _effect;
@synthesize quad = _quad;
@synthesize textureInfo = _textureInfo;
@synthesize position = _position;
@synthesize contentSize = _contentSize;
@synthesize velocity = _velocity;
@synthesize fileName=_fileName;
@synthesize hidden=_hidden;
@synthesize rotation=_rotation;
@synthesize properties=_properties;


static NSMutableSet *__ASPGLFreeSprites;
static NSCache *__ASPGLTextureCache;

#pragma mark Class Methods
+ (ASPGLSprite*) spriteWithTextureName:(NSString*)fileName effect:(GLKBaseEffect*)effect{
	if (__ASPGLFreeSprites)
		for (ASPGLSprite *sp in __ASPGLFreeSprites){
			if (![sp.fileName compare:fileName]){
				sp.hidden=NO;
				[__ASPGLFreeSprites removeObject:sp];
				return sp;
			}
		}
	return [[ASPGLSprite alloc] initWithFile:fileName effect:effect];
}
+ (void) addSpriteToFreeCache:(ASPGLSprite*)sp{
	if (!__ASPGLFreeSprites){
		__ASPGLFreeSprites=[[NSMutableSet alloc] init];
	}
	[__ASPGLFreeSprites addObject:sp];
}
+ (GLKTextureInfo*) loadTextureToStorage:(NSString*)fileName{
	if (!__ASPGLTextureCache){
		__ASPGLTextureCache=[[NSCache alloc] init];
	}
	NSDictionary * options = [NSDictionary dictionaryWithObjectsAndKeys:
							  [NSNumber numberWithBool:YES],
							  GLKTextureLoaderOriginBottomLeft, 
							  nil];
	NSError *error;    
	NSString *path = [[NSBundle mainBundle] pathForResource:fileName ofType:nil];
	if (!path) return nil;
	GLKTextureInfo *texture=[GLKTextureLoader textureWithContentsOfFile:path options:options error:&error];
	if (texture==nil){
		NSLog(@"Failed to load texture: %@",[error localizedDescription]);
		return nil;
	}
	[__ASPGLTextureCache setObject:texture forKey:fileName];
	return texture;
}
+ (GLKTextureInfo*) textureByFileName:(NSString*)fileName loadIfEmpty:(BOOL)load{
	GLKTextureInfo *texture=[__ASPGLTextureCache objectForKey:fileName];
	if(load&&!(texture))
		texture=[ASPGLSprite loadTextureToStorage:fileName];
	
	return texture;
}
+ (void) clearTextureCache{
	if (__ASPGLTextureCache){
		[__ASPGLTextureCache removeAllObjects];
	}
}
#pragma mark - Init
- (id)initWithFile:(NSString *)fileName effect:(GLKBaseEffect *)effect position:(GLKVector2)position bounds:(CGSize)size respectAspectRatio:(BOOL)respectAR{
    if ((self = [super init])) { 
		//Дополнительные параметры для всяких мелочей
		self.properties=[NSMutableDictionary dictionaryWithCapacity:1];
		[_properties setValue:@"NoName" forKey:@"Name"];
		//Мелочь
		self.fileName=fileName;
		//Привет шейдер
        self.effect = effect;
		//Загружаем текстуру
		self.textureInfo = [ASPGLSprite textureByFileName:fileName loadIfEmpty:YES];
		CGSize textureSize=CGSizeMake(self.textureInfo.width, self.textureInfo.height);
		aspect=textureSize.width/(GLfloat)textureSize.height;
		//Хитрая весч с изменением размера
		//Если размеры не нулевые
		if (size.height&&size.width){
			//То в зависимости от учета\неучета AspectRatio выставляем указанные размеры
			if (respectAR){
				self.contentSize=size;
			}else
				_contentSize=size;
		}else {
			//Если же нулевые размеры (т.е не указаны) то используем размер текстуры
			_contentSize=textureSize;
		}
		TexturedQuad newQuad;
		newQuad.bl.geometryVertex = CGPointMake(0, 0);
		newQuad.br.geometryVertex = CGPointMake(textureSize.width, 0);
		newQuad.tl.geometryVertex = CGPointMake(0, textureSize.height);
		newQuad.tr.geometryVertex = CGPointMake(textureSize.width, textureSize.height);
		
		newQuad.bl.textureVertex = CGPointMake(0, 0);
		newQuad.br.textureVertex = CGPointMake(1, 0);
		newQuad.tl.textureVertex = CGPointMake(0, 1);
		newQuad.tr.textureVertex = CGPointMake(1, 1);
		//Рожаем позицию. Счет ведем от самой нижней точки обьекта
		self.position=GLKVector2Make(position.x, position.y);
		self.quad = newQuad;
		self.hidden=NO;
    }
    return self;
}
- (id)initWithFile:(NSString *)fileName 
			effect:(GLKBaseEffect *)effect 
			bounds:(CGSize)size 
respectAspectRatio:(BOOL)respectAR{
	return [self initWithFile:fileName effect:effect position:DEFAULT_POS bounds:size respectAspectRatio:respectAR];
}
- (id)initWithFile:(NSString *)fileName 
			effect:(GLKBaseEffect *)effect 
		  position:(GLKVector2)position
			bounds:(CGSize)size{
	return [self initWithFile:fileName effect:effect position:position bounds:size respectAspectRatio:DEFAULT_AR];
}
- (id)initWithFile:(NSString *)fileName 
			effect:(GLKBaseEffect *)effect 
			bounds:(CGSize)size{
	return [self initWithFile:fileName effect:effect position:DEFAULT_POS bounds:size respectAspectRatio:DEFAULT_AR];
}
- (id)initWithFile:(NSString *)fileName 
			effect:(GLKBaseEffect *)effect
		  position:(GLKVector2)position{
	return [self initWithFile:fileName effect:effect position:position bounds:DEFAULT_BOUNDS respectAspectRatio:DEFAULT_AR];
}
- (id)initWithFile:(NSString *)fileName 
			effect:(GLKBaseEffect *)effect{
	return [self initWithFile:fileName effect:effect position:DEFAULT_POS bounds:DEFAULT_BOUNDS respectAspectRatio:DEFAULT_AR];
}
#pragma Accessors
- (void)setContentSize:(CGSize)contentSize{
	//Предполагается, что в _contentSize лежит адекватный размер
	if (aspect>=1){
		_contentSize.width=contentSize.width;
		_contentSize.height=contentSize.width/aspect;
	}else {
		_contentSize.width=contentSize.height*aspect;
		_contentSize.height=contentSize.height;
	}
}

- (GLfloat) aspect{
	return _contentSize.width/(GLfloat)_contentSize.height;
}

- (void)outOfView{
	_hidden=YES;
	[ASPGLSprite addSpriteToFreeCache:self];
}
#pragma mark - OpenGL Part
- (GLKMatrix4) modelMatrix {
    GLKMatrix4 modelMatrix = GLKMatrix4Identity;    
	//Движение. Координаты - от пяток.
    modelMatrix = GLKMatrix4Translate(modelMatrix, self.position.x, self.position.y, 0);
	//Смена размера (аргументы - во сколько раз менять относительно размера оригинальной текстуры)
	modelMatrix = GLKMatrix4Scale(modelMatrix, _contentSize.width/_textureInfo.width,_contentSize.height/_textureInfo.height, 0);
	
    return modelMatrix;
}

- (void)render { 
	if (_hidden) return;
	self.effect.texture2d0.name = self.textureInfo.name;
	self.effect.texture2d0.enabled = YES;
	self.effect.transform.modelviewMatrix = self.modelMatrix;
	[self.effect prepareToDraw];
	glEnableVertexAttribArray(GLKVertexAttribPosition);
	glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
	long offset = (long)&_quad;        
	glVertexAttribPointer(GLKVertexAttribPosition, 2, GL_FLOAT, GL_FALSE, sizeof(TexturedVertex), (void *) (offset + offsetof(TexturedVertex, geometryVertex)));
	glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, sizeof(TexturedVertex), (void *) (offset + offsetof(TexturedVertex, textureVertex)));
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}

-(void)update:(CGFloat)dt {
	if (_hidden) return;
	GLKVector2 curMove = GLKVector2MultiplyScalar(_velocity, dt);
	self.position = GLKVector2Add(_position, curMove);
	if (_debugLabel){
		CGRect frame=_debugLabel.frame;
		CGFloat y=_debugView.frame.size.height;
		_debugLabel.frame=CGRectMake(_position.x,y-_position.y, frame.size.width, frame.size.height);
		_debugLabel.text=[NSString stringWithFormat:@"%.0f:%.0f\n"
						  ,_velocity.x,_velocity.y];
	}
}
- (void)enableDebugOnView:(UIView*)view{
	_debugLabel=[[UILabel alloc] initWithFrame:CGRectMake(_position.x, _position.y-10, 70, 12)];
	_debugLabel.textColor=[UIColor colorWithWhite:0.5 alpha:1];
	_debugLabel.backgroundColor=[UIColor clearColor];
	_debugLabel.numberOfLines=2;
	_debugLabel.font=[UIFont fontWithName:@"Georgia" size:10];
	[view addSubview:_debugLabel];
	_debugView=view;
}
@end

#pragma mark - Categories -
#import "ASPGLKVector2Extension.h"
@implementation ASPGLSprite (Coordinates)
@dynamic centerPosition;
- (void) setCenterPosition:(GLKVector2)centerPosition{
	self.position=GLKVector2Make(centerPosition.x-self.contentSize.width/2,centerPosition.y-self.contentSize.height/2.);
}
- (GLKVector2)centerPosition{
	return GLKVector2Make(self.position.x+self.contentSize.width/2, self.position.y+self.contentSize.height/2.);
}
@end


@implementation ASPGLSprite (Sizes)
@dynamic diagonal;

- (void) setDiagonal:(GLfloat)diagonal{
	GLKVector2 diagVector = GLKVector2Make(_contentSize.width, _contentSize.height);
	diagVector = GLKVector2SetLength(diagVector, diagonal);
	_contentSize.width=diagVector.x;
	_contentSize.height=diagVector.y;
}

- (GLfloat) diagonal{
	return sqrtf(_contentSize.width*_contentSize.height);
}

- (void) setRadious:(GLfloat)radious{
	if (aspect<0){
		_contentSize.width=radious;
		_contentSize.height=_contentSize.width*aspect;
	}else {
		_contentSize.height=radious;
		_contentSize.width=_contentSize.height/aspect;
	}
}

- (GLfloat) radious{
	return (_contentSize.width<_contentSize.height)?_contentSize.width:_contentSize.height;
}
@end