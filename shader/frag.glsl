//
// http://glslsandbox.com/e#36013.0
//
#version 330 core
precision highp float;

#ifdef GL_ES
precision mediump float;
#endif


uniform float time;
uniform vec2 mouse;
uniform vec2 resolution;
out vec4 fragColor;


// -- SPACE -- (http://glslsandbox.com/e#29173.1)
#define iterations 14
#define formuparam2 0.79

#define volsteps 5
#define stepsize 0.290

#define zoom 0.900
#define tile   0.850
#define speed2  0.10

#define brightness 0.003
#define darkmatter 0.400
#define distfading 0.560
#define saturation 0.800


#define transverseSpeed zoom*2.0
#define cloud 0.11


float triangle(float x, float a) {
    float output2 = 2.0*abs(  2.0*  ( (x/a) - floor( (x/a) + 0.5) ) ) - 1.0;
    return output2;
}

float field(in vec3 p) {
    float strength = 7. + .03 * log(1.e-6 + fract(sin(time) * 4373.11));
    float accum = 0.;
    float prev = 0.;
    float tw = 0.;

    for (int i = 0; i < 6; ++i) {
        float mag = dot(p, p);
        p = abs(p) / mag + vec3(-.5, -.8 + 0.1*sin(time*0.7 + 2.0), -1.1+0.3*cos(time*0.3));
        float w = exp(-float(i) / 7.);
        accum += w * exp(-strength * pow(abs(mag - prev), 2.3));
        tw += w;
        prev = mag;
    }
    return max(0., 5. * accum / tw - .7);
}


// -- CREATURE -- (AKA Bubbas lilla snabelverk)
const float pi = 3.1415926535897931;

float sdPlane(in vec3 p) {
    return p.y + 0.4;
}

float sdSphere(in vec3 p, in float r) {
    return length(p) - r;
}

float sdCapsule( vec3 p, vec3 a, vec3 b, float r ) {
    vec3 pa = p - a, ba = b - a;
    float h = clamp( dot(pa, ba) / dot(ba , ba), 0.0, 1.0 );
    return length( pa - ba * h ) - r;
}

float motor(float _min, float _max, float time) {
    float t = 0.5 + 0.5 * sin(time);
    return mix(_min, _max, t);
}

vec3 rotate_from_origin(vec3 origin, vec3 target, float r, float angle) {
    return vec3(
            origin.x + r * cos(angle),
            origin.y + r * sin(angle),
            target.z
            );
}

vec3 preserve(vec3 p0, vec3 p1, float len) {
    vec3 v = p1 - p0;
    vec3 u = normalize(v);
    return p0 + len * u;
}

float smin( float a, float b, float k ) {
    float h = clamp( 0.5+0.5*(b-a)/k, 0.0, 1.0 );
    return mix( b, a, h ) - k*h*(1.0-h);
}
float map(in vec3 p) {
    float t = time * .0;
    float cx = 0.;
    float cz = 0.;
    vec3 p0 = vec3(-cx, 0.0, 0.0);
    vec3 p1 = vec3(-cx, -0., -cz);
    vec3 p2 = vec3(-cx, -0., -cz);
    vec3 p3 = vec3(-cx, 0., cz);
    vec3 p4 = vec3(-cx, -0., cz);

    vec3 p5 = vec3(cx, 0.0, 0.0);
    vec3 p6 = vec3(cx, -0.2, -cz);
    vec3 p7 = vec3(cx, -0.4, -cz);
    vec3 p8 = vec3(cx, 0.2, cz);
    vec3 p9 = vec3(cx, -0.4, cz);

    vec3 p10 = vec3(0.0, 0.0, 0.0);
    vec3 p11 = vec3(cx, -0.2, 0.0);

    vec3 p12 = vec3(cx * 2.2, 0.2, 0.0);
    vec3 p13 = vec3(cx * 2.4, 0.1, 0.0);

    float angle0 = 0.0;
    float angle1 = 0.0;
    p0.y = -motor(-0.05, 0.05, t * 4.0);
    angle0 = -motor(pi * 0.15, pi * 0.65, t * 2.0 - pi * 0.5);
    angle1 = -motor(pi * 0.15, pi * 0.65, t * 2.0 + pi * 0.5);
    p1 = rotate_from_origin(p0, p1, 0.2, angle0);
    p3 = rotate_from_origin(p0, p3, 0.2, angle1);
    angle0 += -motor(0.0, pi * 0.5, t * 2.0 + pi);
    angle1 += -motor(0.0, pi * 0.5, t * 2.0 + pi + pi);
    p2 = rotate_from_origin(p1, p2, 0.2, angle0);
    p4 = rotate_from_origin(p3, p4, 0.2, angle1);

    p5.y = -motor(-0.05, 0.05, t * 4.0);
    angle0 = -motor(pi * 0.15, pi * 0.65, t * 2.0 - pi * 0.5);
    angle1 = -motor(pi * 0.15, pi * 0.65, t * 2.0 + pi * 0.5);
    p6 = rotate_from_origin(p5, p6, 0.2, angle0);
    p8 = rotate_from_origin(p5, p8, 0.2, angle1);
    angle0 += -motor(0.0, pi * 0.5, t * 2.0 + pi);
    angle1 += -motor(0.0, pi * 0.5, t * 2.0 + pi + pi);
    p7 = rotate_from_origin(p6, p7, 0.2, angle0);
    p9 = rotate_from_origin(p8, p9, 0.2, angle1);

    p10.y = -motor(-0.02, 0.02, t * 4.0 - pi * 0.5);
    p11 = preserve(p5, p11, -0.25);

    p12.y -= motor(-0.02, 0.02, t * 4.0 - pi * 2.0);
    p13.y -= motor(-0.02, 0.02, t * 4.0 - pi * 0.1);

    float w = 0.0;

    float d = sdPlane(p);

    d = min(d, sdCapsule(p, p0, p1, w));
    d = min(d, sdCapsule(p, p1, p2, w));
    d = min(d, sdCapsule(p, p0, p3, w));
    d = min(d, sdCapsule(p, p3, p4, w));

    d = min(d, sdCapsule(p, p5, p6, w));
    d = min(d, sdCapsule(p, p6, p7, w));
    d = min(d, sdCapsule(p, p5, p8, w));
    d = min(d, sdCapsule(p, p8, p9, w));

    d = min(d, sdCapsule(p, p0, p10, w));
    d = min(d, sdCapsule(p, p10, p5, w));

    d = min(d, sdCapsule(p, p12, p11, w));
    d = min(d, sdCapsule(p, p13, p12, w));

    d = smin(d, sdCapsule(p, p5, p11, w), 0.1);

    return d;
}

vec3 calcNormal(in vec3 p) {
    vec3 e = vec3(0.001, 0.0, 0.0);
    vec3 nor = vec3(
            map(p + e.xyy) - map(p - e.xyy),
            map(p + e.yxy) - map(p - e.yxy),
            map(p + e.yyx) - map(p - e.yyx)
            );
    return normalize(nor);
}

float castRay(in vec3 ro, in vec3 rd, in float maxt) {
    float precis = 0.001;
    float h = precis * 2.0;
    float t = 0.0;
    for(int i = 0; i < 60; i++) {
        if(abs(h) < precis || t > maxt) continue;
        h = map(ro + rd * t);
        t += h;
    }
    return t;
}

vec3 render(in vec3 ro, in vec3 rd) {
    vec3 col = vec3(1.0);
    float t = castRay(ro, rd, 20.0);
    vec3 pos = ro + rd * t;
    vec3 nor = calcNormal(pos);
    vec3 lig = normalize(vec3(-0.4, 0.7, 0.5));
    float dif = clamp(dot(lig, nor), 0.0, 1.0);
    float spec = pow(clamp(dot(reflect(rd, nor), lig), 0.0, 1.0), 16.0);
    col = col * (dif + spec);
    return col;
}


// -- UTIL / MISC --
vec3 hsv2rgb(vec3 c)
{
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}


// -- MAIN --
void main() {
    vec2 uv2 = 2. * gl_FragCoord.xy / vec2(512) - 1.;
    vec2 uvs = uv2 * vec2(512)  / 512.;

    float time2 = time;
    float speed = speed2;
    speed = -.02 * cos(time2*0.02 + 3.1415926/4.0);
    //speed = 0.0;
    float formuparam = formuparam2;

    //get coords and direction
    //mouse rotation
    float a_xz = 0.9;
    float a_yz = -.6;
    float a_xy = 0.9 + time*0.04;

    mat2 rot_xz = mat2(cos(a_xz),sin(a_xz),-sin(a_xz),cos(a_xz));
    mat2 rot_yz = mat2(cos(a_yz),sin(a_yz),-sin(a_yz),cos(a_yz));
    mat2 rot_xy = mat2(cos(a_xy),sin(a_xy),-sin(a_xy),cos(a_xy));


    float v2 =1.0;
    vec3 dir=vec3(uvs*zoom,1.);
    vec3 from=vec3(0.0, 0.0,0.0);
    from.x -= 5.0*(mouse.x-0.5);
    from.y -= 5.0*(mouse.y-0.5);


    vec3 forward = vec3(0.,0.,1.);
    from.x += transverseSpeed*(1.0)*cos(0.01*time) + 0.001*time;
    from.y += transverseSpeed*(1.0)*sin(0.01*time) +0.001*time;
    from.z += 0.003*time;

    dir.xy*=rot_xy;
    forward.xy *= rot_xy;
    dir.xz*=rot_xz;
    forward.xz *= rot_xz;
    dir.yz*= rot_yz;
    forward.yz *= rot_yz;

    from.xy*=-rot_xy;
    from.xz*=rot_xz;
    from.yz*= rot_yz;


    //zoom
    float zooom = (time2-3311.)*speed;
    from += forward* zooom;
    float sampleShift = mod( zooom, stepsize );

    float zoffset = -sampleShift;
    sampleShift /= stepsize; // make from 0 to 1

    //volumetric rendering
    float s=0.24;
    float s3 = s + stepsize/2.0;
    vec3 v=vec3(0.);
    float t3 = 0.0;

    vec3 backCol2 = vec3(0.);
    for (int r=0; r<volsteps; r++) {
        vec3 p2=from+(s+zoffset)*dir;// + vec3(0.,0.,zoffset);
        vec3 p3=from+(s3+zoffset)*dir;// + vec3(0.,0.,zoffset);

        p2 = abs(vec3(tile)-mod(p2,vec3(tile*2.))); // tiling fold
        p3 = abs(vec3(tile)-mod(p3,vec3(tile*2.))); // tiling fold
#ifdef cloud
        t3 = field(p3);
#endif

        float pa,a=pa=0.;
        for (int i=0; i<iterations; i++) {
            p2=abs(p2)/dot(p2,p2)-formuparam; // the magic formula
            //p=abs(p)/max(dot(p,p),0.005)-formuparam; // another interesting way to reduce noise
            float D = abs(length(p2)-pa); // absolute sum of average change
            a += i > 7 ? min( 12., D) : D;
            pa=length(p2);
        }


        //float dm=max(0.,darkmatter-a*a*.001); //dark matter
        a*=a*a; // add contrast
        //if (r>3) fade*=1.-dm; // dark matter, don't render near
        // brightens stuff up a bit
        float s1 = s+zoffset;
        // need closed form expression for this, now that we shift samples
        float fade = pow(distfading,max(0.,float(r)-sampleShift));
        //t3 += fade;
        v+=fade;
        //backCol2 -= fade;

        // fade out samples as they approach the camera
        if( r == 0 )
            fade *= (1. - (sampleShift));
        // fade in samples as they approach from the distance
        if( r == volsteps-1 )
            fade *= sampleShift;
        v+=vec3(s1,s1*s1,s1*s1*s1*s1)*a*brightness*fade; // coloring based on distance

        backCol2 += mix(.4, 1., v2) * vec3(1.8 * t3 * t3 * t3, 1.4 * t3 * t3, t3) * fade;


        s+=stepsize;
        s3 += stepsize;
    }

    v=mix(vec3(length(v)),v,saturation); //color adjust

    vec4 forCol2 = vec4(v*.01,1.);
#ifdef cloud
    backCol2 *= cloud;
#endif
    backCol2.b *= 1.8;
    backCol2.r *= 0.05;

    backCol2.b = 0.5*mix(backCol2.g, backCol2.b, 0.8);
    backCol2.g = 0.0;
    backCol2.bg = mix(backCol2.gb, backCol2.bg, 0.5*(cos(time*0.01) + 1.0));
    vec4 spaceCol = forCol2 + vec4(backCol2, 1.0); // Output of space shader

    // CREATURE
    vec2 uv = gl_FragCoord.xy / resolution.xy;
    vec2 ms = 2.0 * mouse - 1.0;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= resolution.x / resolution.y;
    vec3 ro = vec3(0.0, 0.0, 1.5);
    vec3 ta = vec3(3. - mod(time, 6.), 0.0, 0.0);
    vec3 cw = normalize(ta - ro);
    vec3 cp = vec3(0.0, 1.0, 0.0);
    vec3 cu = normalize(cross(cw, cp));
    vec3 cv = normalize(cross(cu, cw));
    vec3 rd = normalize(p.x * cu + p.y * cv + 2.5 * cw);
    vec3 col = render(ro, rd);

    vec3 disco = hsv2rgb(vec3(time * .15, .75 + sin(.15), .5 + sin(.15)));

    vec4 snabelCol = vec4(col/* + disco*/, 1.0); // Output of creature shader

    // MASH 'EM
    fragColor = snabelCol * spaceCol;
}
