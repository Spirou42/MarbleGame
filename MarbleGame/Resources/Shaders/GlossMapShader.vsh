
attribute vec4 a_position;
attribute vec2 a_texCoord;
attribute vec4 a_color;								
attribute vec2 a_mapCoord;

varying vec4 v_fragmentColor;						
varying vec2 v_texCoord;							
varying vec2 v_mapCoord;

void main()											
{													
  gl_Position = CC_MVPMatrix * a_position;
  v_fragmentColor = a_color;
  v_texCoord = a_texCoord;
  v_mapCoord = a_mapCoord;
}													
/*
 uniform sampler2D tex;
 uniform sampler2D glossMap;
 attribute vec4 a_position;
 attribute vec2 a_texCoord;
 varying vec4 lightColor;
 varying vec2 v_texCoord;
 
 void main()
 {
 gl_FrontColor = gl_Color;
 lightColor = vec4(1.0, 1.0, 1.0, 1.0);
 v_texCoord = gl_MultiTexCoord0.xy;
 //	v_texCoord = a_texCoord;
 
 gl_Position = ftransform();
 //gl_Position = CC_MVPMAtirx * a_position;
 
 }
*/