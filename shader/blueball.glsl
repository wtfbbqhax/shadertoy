#version 330 core

#ifdef GL_ES
precision mediump float;
#endif

//#extension GL_OES_standard_derivatives : enable

uniform float time;
uniform vec2 mouse;
uniform vec2 resolution;
out vec4 fragColor;


struct Light
{
	float radius;
	vec3 color;
	vec2 position;
	float intensity;
};
	
vec3 getCircleColor(Light circle, vec2 pos) {
	float dist = length(pos - circle.position);
	vec3 color = vec3(0.0, 0.0, 0.0);
	if (dist < circle.radius){
		color = circle.color;
	} else {
		color = circle.intensity * circle.color / (dist + circle.intensity - circle.radius);
	}
	return color;
}

Light circle1 = Light(0.13, vec3(0.0, 1.0, 1.0), vec2(0.5, 0.5), 0.01);
Light circle2 = Light(0.02, vec3(1.0, 0.5, 1.0), vec2(0.5, 0.5), 0.05);

void main( void ) {

	vec2 position = ( gl_FragCoord.xy / resolution.xy );
	position.y = 0.5 + ((position.y - 0.5) * (resolution.y/resolution.x));
	vec3 c1 = getCircleColor(circle1, position);
	vec3 c2 = getCircleColor(circle2, position);
	fragColor = vec4( c1 + c2, 1.0 );
}
