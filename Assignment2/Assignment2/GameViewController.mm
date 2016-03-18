//
//  GameViewController.m
//  Assignment2
//
//  Created by Santo Tallarico on 2016-03-05.
//  Copyright © 2016 Santo Tallarico. All rights reserved.
//

#import "GameViewController.h"
#import <OpenGLES/ES2/glext.h>

using std::vector;

#define BUFFER_OFFSET(i) ((char *)NULL + (i))

// Uniform index.
enum
{
    UNIFORM_MODELVIEWPROJECTION_MATRIX,
    UNIFORM_NORMAL_MATRIX,
    UNIFORM_MODELVIEW_MATRIX,
    UNIFORM_TEXTURE,
    UNIFORM_AMBIENT_COMPONENT,
    NUM_UNIFORMS
};
GLint uniforms[NUM_UNIFORMS];

// Attribute index.
enum
{
    ATTRIB_VERTEX,
    ATTRIB_NORMAL,
    NUM_ATTRIBUTES
};

GLfloat gPanelVertexData[48] =
{
    // Data layout for each line below is:
    // positionX, positionY, positionZ,     normalX, normalY, normalZ,      texture0, texture1
    -1.0f, -1.0f, 0.0f,        0.0f, 0.0f, 1.0f,        0.0f, 0.0f,
    1.0f, -1.0f, 0.0f,         0.0f, 0.0f, 1.0f,        1.0f, 0.0f,
    1.0f, 1.0f, 0.0f,         0.0f, 0.0f, 1.0f,        1.0f, 1.0f,
    -1.0f, -1.0f, 0.0f,         0.0f, 0.0f, 1.0f,        0.0f, 0.0f,
    1.0f, 1.0f, 0.0f,          0.0f, 0.0f, 1.0f,        1.0f, 1.0f,
    -1.0f, 1.0f, 0.0f,         0.0f, 0.0f, 1.0f,        0.0f, 1.0f
};

@interface GameViewController () {
    GLuint _program;
    
    GLKMatrix4 _modelViewProjectionMatrix;
    GLKMatrix4 _modelViewMatrix;
    GLKMatrix3 _normalMatrix;
    
    GLuint _vertexArray;
    GLuint _vertexBuffer;
    
    GLuint _leftTexture;
    GLuint _rightTexture;
    GLuint _bothTexture;
    GLuint _noneTexture;
    GLuint _floorTexture;
    GLuint _texCoordSlot;
    GLuint _textureUniform;
    
    
    GLKVector4 ambientComponent;
    
    
    Maze* maze;
    
    GLKVector3 _translation;
    float _rotation;
    
    vector<Wall> walls;
    PhysicsEngine physics;
    bool moving;
    Model enemy;
    
    CGPoint _lastTranslate;
}
@property (strong, nonatomic) EAGLContext *context;
@property (strong, nonatomic) GLKBaseEffect *effect;

- (void)setupGL;
- (void)tearDownGL;

- (BOOL)loadShaders;
- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file;
- (BOOL)linkProgram:(GLuint)prog;
- (BOOL)validateProgram:(GLuint)prog;
@end

@implementation GameViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    tapGesture.numberOfTapsRequired = 2;
    [self.view addGestureRecognizer:tapGesture];
    
    UITapGestureRecognizer *movingGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleMovingGesture:)];
    movingGesture.numberOfTapsRequired = 2;
    movingGesture.numberOfTouchesRequired = 2;
    [self.view addGestureRecognizer:movingGesture];
    
    UIPanGestureRecognizer *doubleDragGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleDragGesture:)];
    doubleDragGesture.maximumNumberOfTouches = 2;
    doubleDragGesture.minimumNumberOfTouches = 2;
    [self.view addGestureRecognizer:doubleDragGesture];
    
    UIPanGestureRecognizer *singleDragGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleDragGesture:)];
    singleDragGesture.maximumNumberOfTouches = 1;
    singleDragGesture.minimumNumberOfTouches = 1;
    [self.view addGestureRecognizer:singleDragGesture];
    
    _translation.x = 0;
    _translation.y = 0;
    _translation.z = 0;
    
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];

    if (!self.context) {
        NSLog(@"Failed to create ES context");
    }
    
    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    
    maze = new Maze();
    maze->Create();
    walls = vector<Wall>();
    physics = PhysicsEngine();
    moving = false;
    enemy = Model();
    
    [self setupGL];
    
    for (int i = 0; i < 4; i++) {
        for (int j = 0; j < 4; j++) {
            MazeCell cell = maze->GetCell(j, i);
            bool left = false;
            bool right = false;
            
            if (cell.northWallPresent) {
                if (i != 0) {
                    if (maze->GetCell(j, i - 1).northWallPresent) {
                        left = true;
                    }
                }
                if (i != 3){
                    if (maze->GetCell(j, i + 1).northWallPresent) {
                        right = true;
                    }
                }
                Wall w = Wall();
                
                if (left && right) {
                    w = Wall(_vertexArray, _bothTexture, _textureUniform, GLKVector3Make(2 * i, 0, 2 * -j + 1.0f - 0.001f), GLKVector3Make(0, 0, 0));
                }
                else if (left) {
                    w = Wall(_vertexArray, _leftTexture, _textureUniform, GLKVector3Make(2 * i, 0, 2 * -j + 1.0f - 0.001f), GLKVector3Make(0, 0, 0));
                }
                else if (right) {
                    w = Wall(_vertexArray, _rightTexture, _textureUniform, GLKVector3Make(2 * i, 0, 2 * -j + 1.0f - 0.001f), GLKVector3Make(0, 0, 0));
                }
                else {
                    w = Wall(_vertexArray, _noneTexture, _textureUniform, GLKVector3Make(2 * i, 0, 2 * -j + 1.0f - 0.001f), GLKVector3Make(0, 0, 0));
                }
                walls.push_back(w);
                physics.hitboxes.push_back(Hitbox::GetHitboxFromModel());
            }
            left = false;
            right = false;
            if (cell.eastWallPresent) {
                if (j != 0) {
                    if (maze->GetCell(j - 1, i).eastWallPresent) {
                        right = true;
                    }
                }
                if (j != 3){
                    if (maze->GetCell(j + 1, i).eastWallPresent) {
                        left = true;
                    }
                }
                Wall w = Wall();
                
                if (left && right) {
                    w = Wall(_vertexArray, _bothTexture, _textureUniform, GLKVector3Make(2 * i + 1.0f - 0.001f, 0, 2 * -j), GLKVector3Make(M_PI_2, 0, 0));
                }
                else if (left) {
                    w = Wall(_vertexArray, _rightTexture, _textureUniform, GLKVector3Make(2 * i + 1.0f - 0.001f, 0, 2 * -j), GLKVector3Make(M_PI_2, 0, 0));
                }
                else if (right) {
                    w = Wall(_vertexArray, _leftTexture, _textureUniform, GLKVector3Make(2 * i + 1.0f - 0.001f, 0, 2 * -j), GLKVector3Make(M_PI_2, 0, 0));
                }
                else {
                    w = Wall(_vertexArray, _noneTexture, _textureUniform, GLKVector3Make(2 * i + 1.0f - 0.001f, 0, 2 * -j), GLKVector3Make(M_PI_2, 0, 0));
                }
                walls.push_back(w);
                physics.hitboxes.push_back(Hitbox::GetHitboxFromModel());
            }
            left = false;
            right = false;
            if (cell.southWallPresent) {
                if (i != 0) {
                    if (maze->GetCell(j, i - 1).southWallPresent) {
                        right = true;
                    }
                }
                if (i != 3){
                    if (maze->GetCell(j, i + 1).southWallPresent) {
                        left = true;
                    }
                }
                Wall w = Wall();
                
                if (left && right) {
                    w = Wall(_vertexArray, _bothTexture, _textureUniform, GLKVector3Make(2 * i, 0, 2 * -j - 1.0f + 0.001f), GLKVector3Make(0, 0, 0));
                }
                else if (left) {
                    w = Wall(_vertexArray, _rightTexture, _textureUniform, GLKVector3Make(2 * i, 0, 2 * -j - 1.0f + 0.001f), GLKVector3Make(0, 0, 0));
                }
                else if (right) {
                    w = Wall(_vertexArray, _leftTexture, _textureUniform, GLKVector3Make(2 * i, 0, 2 * -j - 1.0f + 0.001f), GLKVector3Make(0, 0, 0));
                }
                else {
                    w = Wall(_vertexArray, _noneTexture, _textureUniform, GLKVector3Make(2 * i, 0, 2 * -j - 1.0f + 0.001f), GLKVector3Make(0, 0, 0));
                }
                walls.push_back(w);
                physics.hitboxes.push_back(Hitbox::GetHitboxFromModel());
            }
            left = false;
            right = false;
            if (cell.westWallPresent) {
                if (j != 0) {
                    if (maze->GetCell(j - 1, i).westWallPresent) {
                        left = true;
                    }
                }
                if (j != 3){
                    if (maze->GetCell(j + 1, i).westWallPresent) {
                        right = true;
                    }
                }
                Wall w = Wall();
                
                if (left && right) {
                    w = Wall(_vertexArray, _bothTexture, _textureUniform, GLKVector3Make(2 * i - 1.0f + 0.001f, 0, 2 * -j), GLKVector3Make(M_PI + M_PI_2, 0, 0));
                }
                else if (left) {
                    w = Wall(_vertexArray, _rightTexture, _textureUniform, GLKVector3Make(2 * i - 1.0f + 0.001f, 0, 2 * -j), GLKVector3Make(M_PI + M_PI_2, 0, 0));
                }
                else if (right) {
                    w = Wall(_vertexArray, _leftTexture, _textureUniform, GLKVector3Make(2 * i - 1.0f + 0.001f, 0, 2 * -j), GLKVector3Make(M_PI + M_PI_2, 0, 0));
                }
                else {
                    w = Wall(_vertexArray, _noneTexture, _textureUniform, GLKVector3Make(2 * i - 1.0f + 0.001f, 0, 2 * -j), GLKVector3Make(M_PI + M_PI_2, 0, 0));
                }
                walls.push_back(w);
                physics.hitboxes.push_back(Hitbox::GetHitboxFromModel());
            }
            walls.push_back(Wall(_vertexArray, _floorTexture, _textureUniform, GLKVector3Make(2 * i, -1.0f, 2 * -j), GLKVector3Make(0, M_PI_2, 0)));
        }
    }
}

- (void)handleTapGesture:(UITapGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateRecognized) {
        _translation.x = 0;
        _translation.y = 0;
        _translation.z = 0;
        _rotation = 0;
    }
}

- (void)handleMovingGesture:(UITapGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateRecognized) {
        moving = !moving;
    }
}

- (void)handleDoubleDragGesture:(UIPanGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateChanged) {
        _rotation += ([sender translationInView:self.view].x - _lastTranslate.x) / 100.0f;
        _lastTranslate = [sender translationInView:self.view];
    }
    if (sender.state == UIGestureRecognizerStateEnded) {
        _lastTranslate.x = 0;
        _lastTranslate.y = 0;
    }
}

- (void)handleSingleDragGesture:(UIPanGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateChanged) {
        _translation.x += cosf(_rotation) * ([sender translationInView:self.view].x - _lastTranslate.x) / 100.0f + sinf(_rotation) * ([sender translationInView:self.view].y - _lastTranslate.y) / 100.0f;
        _translation.z -= cosf(_rotation) * ([sender translationInView:self.view].y - _lastTranslate.y) / 100.0f - sinf(_rotation) * ([sender translationInView:self.view].x - _lastTranslate.x) / 100.0f;
        _lastTranslate = [sender translationInView:self.view];
    }
    if (sender.state == UIGestureRecognizerStateEnded) {
        _lastTranslate.x = 0;
        _lastTranslate.y = 0;
    }
}

- (void)dealloc
{    
    [self tearDownGL];
    
    if ([EAGLContext currentContext] == self.context) {
        [EAGLContext setCurrentContext:nil];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

    if ([self isViewLoaded] && ([[self view] window] == nil)) {
        self.view = nil;
        
        [self tearDownGL];
        
        if ([EAGLContext currentContext] == self.context) {
            [EAGLContext setCurrentContext:nil];
        }
        self.context = nil;
    }

    // Dispose of any resources that can be recreated.
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)setupGL
{
    [EAGLContext setCurrentContext:self.context];
    
    [self loadShaders];
    
    uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX] = glGetUniformLocation(_program, "modelViewProjectionMatrix");
    uniforms[UNIFORM_NORMAL_MATRIX] = glGetUniformLocation(_program, "normalMatrix");
    uniforms[UNIFORM_MODELVIEW_MATRIX] = glGetUniformLocation(_program, "modelViewMatrix");
    uniforms[UNIFORM_TEXTURE] = glGetUniformLocation(_program, "texture");
    uniforms[UNIFORM_AMBIENT_COMPONENT] = glGetUniformLocation(_program, "ambientComponent");
    
    self.effect = [[GLKBaseEffect alloc] init];
    self.effect.light0.enabled = GL_TRUE;
    self.effect.light0.ambientColor = GLKVector4Make(0.75f, 0.75f, 0.75f, 1.0f);
    self.effect.light0.diffuseColor = GLKVector4Make(0.5f, 0.5f, 0.5f, 1.0f);
    
    
    ambientComponent = GLKVector4Make(0.7, 0.7, 0.7, 1.0);
    
    glEnable(GL_DEPTH_TEST);
    glEnable(GL_BLEND);
    glBlendFunc(GL_ONE, GL_SRC_COLOR);
    
    glGenVertexArraysOES(1, &_vertexArray);
    glBindVertexArrayOES(_vertexArray);
    
    glGenBuffers(1, &_vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(gPanelVertexData), gPanelVertexData, GL_STATIC_DRAW);
    
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(float) * 8, BUFFER_OFFSET(0));
    glEnableVertexAttribArray(GLKVertexAttribNormal);
    glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, sizeof(float) * 8, BUFFER_OFFSET(12));
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, sizeof(float) * 8, BUFFER_OFFSET(sizeof(float) * 6));
    
    
    glBindVertexArrayOES(0);
    
    _leftTexture = [self setupTexture:@"leftarrow.png"];
    _rightTexture = [self setupTexture:@"rightarrow.png"];
    _bothTexture = [self setupTexture:@"botharrow.png"];
    _noneTexture = [self setupTexture:@"test.jpg"];
    _floorTexture = [self setupTexture:@"floor.jpg"];
    
}

- (void)tearDownGL
{
    [EAGLContext setCurrentContext:self.context];
    
    glDeleteBuffers(1, &_vertexBuffer);
    glDeleteVertexArraysOES(1, &_vertexArray);
    
    self.effect = nil;
    
    if (_program) {
        glDeleteProgram(_program);
        _program = 0;
    }
}

#pragma mark - GLKView and GLKViewController delegate methods

- (void)update
{
    physics.Update();
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    glClearColor(0.65f, 0.65f, 0.65f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    float aspect = fabs(self.view.bounds.size.width / self.view.bounds.size.height);
    GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(65.0f), aspect, 0.1f, 100.0f);
    
    self.effect.transform.projectionMatrix = projectionMatrix;
    
    GLKMatrix4 baseModelViewMatrix = GLKMatrix4MakeTranslation(0, 0, 0);
    baseModelViewMatrix = GLKMatrix4Rotate(baseModelViewMatrix, _rotation, 0.0f, 1.0f, 0.0f);
    baseModelViewMatrix = GLKMatrix4Translate(baseModelViewMatrix, _translation.x, _translation.y, _translation.z - 4.0f);
    
    for (int i = 0; i < walls.size(); i++) {
        GLKMatrix4 modelViewMatrix = GLKMatrix4MakeTranslation(walls[i].position.x, walls[i].position.y, walls[i].position.z);
        modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, walls[i].rotation.x, 0.0f, 1.0f, 0.0f);
        modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, walls[i].rotation.y, 1.0f, 0.0f, 0.0f);
        modelViewMatrix = GLKMatrix4Multiply(baseModelViewMatrix, modelViewMatrix);
        
        _normalMatrix = GLKMatrix3InvertAndTranspose(GLKMatrix4GetMatrix3(modelViewMatrix), NULL);
        
        _modelViewProjectionMatrix = GLKMatrix4Multiply(projectionMatrix, modelViewMatrix);
                
        walls[i].Render();
        
        glBindVertexArrayOES(walls[i].vertexData);
        
        glUseProgram(_program);
        
        glUniformMatrix4fv(uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX], 1, 0, _modelViewProjectionMatrix.m);
        glUniformMatrix3fv(uniforms[UNIFORM_NORMAL_MATRIX], 1, 0, _normalMatrix.m);
        glUniformMatrix4fv(uniforms[UNIFORM_MODELVIEW_MATRIX], 1, 0, _modelViewMatrix.m);
        glUniform4fv(uniforms[UNIFORM_AMBIENT_COMPONENT], 1, ambientComponent.v);
        
        glDrawArrays(GL_TRIANGLES, 0, 6);
    }
}

#pragma mark -  OpenGL ES 2 shader compilation

- (BOOL)loadShaders
{
    GLuint vertShader, fragShader;
    NSString *vertShaderPathname, *fragShaderPathname;
    
    // Create shader program.
    _program = glCreateProgram();
    
    // Create and compile vertex shader.
    vertShaderPathname = [[NSBundle mainBundle] pathForResource:@"Shader" ofType:@"vsh"];
    if (![self compileShader:&vertShader type:GL_VERTEX_SHADER file:vertShaderPathname]) {
        NSLog(@"Failed to compile vertex shader");
        return NO;
    }
    
    // Create and compile fragment shader.
    fragShaderPathname = [[NSBundle mainBundle] pathForResource:@"Shader" ofType:@"fsh"];
    if (![self compileShader:&fragShader type:GL_FRAGMENT_SHADER file:fragShaderPathname]) {
        NSLog(@"Failed to compile fragment shader");
        return NO;
    }
    
    // Attach vertex shader to program.
    glAttachShader(_program, vertShader);
    
    // Attach fragment shader to program.
    glAttachShader(_program, fragShader);
    
    // Bind attribute locations.
    // This needs to be done prior to linking.
    glBindAttribLocation(_program, GLKVertexAttribPosition, "position");
    glBindAttribLocation(_program, GLKVertexAttribNormal, "normal");
    glBindAttribLocation(_program, GLKVertexAttribTexCoord0, "textureIn");
    
    // Link program.
    if (![self linkProgram:_program]) {
        NSLog(@"Failed to link program: %d", _program);
        
        if (vertShader) {
            glDeleteShader(vertShader);
            vertShader = 0;
        }
        if (fragShader) {
            glDeleteShader(fragShader);
            fragShader = 0;
        }
        if (_program) {
            glDeleteProgram(_program);
            _program = 0;
        }
        
        return NO;
    }
    
    // Release vertex and fragment shaders.
    if (vertShader) {
        glDetachShader(_program, vertShader);
        glDeleteShader(vertShader);
    }
    if (fragShader) {
        glDetachShader(_program, fragShader);
        glDeleteShader(fragShader);
    }
    
    return YES;
}

- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file
{
    GLint status;
    const GLchar *source;
    
    source = (GLchar *)[[NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil] UTF8String];
    if (!source) {
        NSLog(@"Failed to load vertex shader");
        return NO;
    }
    
    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &source, NULL);
    glCompileShader(*shader);
    
#if defined(DEBUG)
    GLint logLength;
    glGetShaderiv(*shader, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetShaderInfoLog(*shader, logLength, &logLength, log);
        NSLog(@"Shader compile log:\n%s", log);
        free(log);
    }
#endif
    
    glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
    if (status == 0) {
        glDeleteShader(*shader);
        return NO;
    }
    
    return YES;
}

- (BOOL)linkProgram:(GLuint)prog
{
    GLint status;
    glLinkProgram(prog);
    
#if defined(DEBUG)
    GLint logLength;
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program link log:\n%s", log);
        free(log);
    }
#endif
    
    glGetProgramiv(prog, GL_LINK_STATUS, &status);
    if (status == 0) {
        return NO;
    }
    
    return YES;
}

- (BOOL)validateProgram:(GLuint)prog
{
    GLint logLength, status;
    
    glValidateProgram(prog);
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program validate log:\n%s", log);
        free(log);
    }
    
    glGetProgramiv(prog, GL_VALIDATE_STATUS, &status);
    if (status == 0) {
        return NO;
    }
    
    return YES;
}

- (GLuint)setupTexture:(NSString *)file {
    NSError *error;
    NSString *path = [[NSBundle mainBundle] pathForResource:file ofType:nil];
    
    NSDictionary *options = @{ GLKTextureLoaderOriginBottomLeft: @YES };
    GLKTextureInfo *info = [GLKTextureLoader textureWithContentsOfFile:path options:options error:&error];
    if (info == nil) {
        NSLog(@"Error loading file: %@", error.localizedDescription);
    } else {
        return info.name;
    }
    return info.name;
}

@end
