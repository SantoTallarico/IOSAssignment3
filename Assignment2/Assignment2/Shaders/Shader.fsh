//
//  Shader.fsh
//  Assignment2
//
//  Created by Santo Tallarico on 2016-03-05.
//  Copyright © 2016 Santo Tallarico. All rights reserved.
//

precision mediump float;

varying lowp vec2 textureOut;
uniform sampler2D texture;


uniform vec4 ambientComponent;

void main()
{
    
    vec4 ambient = ambientComponent;
    
    gl_FragColor = ambient * texture2D(texture, textureOut);
    gl_FragColor.a = 1.0;
}
