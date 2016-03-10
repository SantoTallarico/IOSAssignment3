//
//  Shader.vsh
//  Assignment2
//
//  Created by Santo Tallarico on 2016-03-05.
//  Copyright © 2016 Santo Tallarico. All rights reserved.
//

attribute vec4 position;

uniform mat4 modelViewProjectionMatrix;
attribute vec3 normal;

attribute vec2 textureIn;
varying vec2 textureOut;

void main()
{
    textureOut = textureIn;
    
    gl_Position = modelViewProjectionMatrix * position;
}
