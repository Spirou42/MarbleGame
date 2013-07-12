
uniform sampler2D tex;
uniform sampler2D glossMap;

varying vec2 v_texCoord;
varying vec4 lightColor;
uniform vec4 tColor;
void main()
{
     vec4 color = texture2D( tex, v_texCoord ); 
	vec4 base_color = texture2D(tex, v_texCoord).rgba;
	base_color.rgb/=1.3;
	vec3 gloss_color = texture2D(glossMap,v_texCoord).rgb;
	float reflectivity = 0.30*gloss_color.r + 
			0.59*gloss_color.g + 
			0.11*gloss_color.b;
//	vec4 lightColor = vec4(0.60, .600, .60,1.0);

	gl_FragColor = base_color+(lightColor*reflectivity);

}
