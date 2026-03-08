precision highp float;
uniform float uTime;
uniform vec2 uResolution;
uniform vec2 uMouse;
uniform float uTimeProgress;
uniform int uCycleMode; // 0:auto, 1:sun, 2:moon, 3:solar_eclipse, 4:lunar_eclipse
uniform float uBloom;
uniform float uSize;
uniform float uRadius;
uniform float uHorizonProp;
uniform float uMoonPhase;
uniform vec3 uMoonGlowColor;
uniform float uStarIntensity;
uniform bool uSeaEnabled;
varying vec2 vUv;

#define PI 3.14159265359

// Noise functions for stars and craters
float hash(vec2 p) {
    p = fract(p * vec2(123.34, 456.21));
    p += dot(p, p + 45.32);
    return fract(p.x * p.y);
}

float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);
    float a = hash(i);
    float b = hash(i + vec2(1.0, 0.0));
    float c = hash(i + vec2(0.0, 1.0));
    float d = hash(i + vec2(1.0, 1.0));
    return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}

float fbm(vec2 p) {
    float v = 0.0;
    float a = 0.5;
    for (int i = 0; i < 5; i++) {
        v += a * noise(p);
        p *= 2.0;
        a *= 0.5;
    }
    return v;
}

vec3 getSkyColor(float altitude, float progress, int mode) {
    // Top to Bottom gradients
    vec3 dayTop = vec3(0.1, 0.4, 0.8);
    vec3 dayBottom = vec3(0.4, 0.7, 1.0);
    
    vec3 sunsetTop = vec3(0.0, 0.1, 0.3);
    vec3 sunsetBottom = vec3(1.0, 0.3, 0.1);
    
    vec3 nightTop = vec3(0.01, 0.01, 0.02);
    vec3 nightBottom = vec3(0.03, 0.05, 0.1);
    
    vec3 eclipseTop = vec3(0.0, 0.01, 0.03);
    vec3 eclipseBottom = vec3(0.05, 0.05, 0.1);

    if (mode == 3) return mix(eclipseTop, eclipseBottom, altitude);
    
    float nightFactor = smoothstep(0.2, 0.4, abs(progress - 0.5) * 2.0);
    if (mode == 1) nightFactor = 0.0;
    if (mode == 2 || mode == 4) nightFactor = 1.0;

    vec3 top = mix(dayTop, nightTop, nightFactor);
    vec3 bottom = mix(dayBottom, nightBottom, nightFactor);
    
    // Sunset transition
    float sunsetFactor = smoothstep(0.4, 0.0, abs(progress - 0.5));
    top = mix(top, sunsetTop, sunsetFactor);
    bottom = mix(bottom, sunsetBottom, sunsetFactor);

    return mix(top, bottom, altitude);
}

void main() {
    vec2 uv = vUv;
    vec2 p = (uv - 0.5) * 2.0;
    p.x *= uResolution.x / uResolution.y;

    vec2 m = (uMouse - 0.5) * 2.0;
    m.x *= uResolution.x / uResolution.y;

    float aspect = uResolution.x / uResolution.y;
    float horizon = uHorizonProp * 2.0 - 1.0; 
    
    // 0..1 is a FULL day/night cycle
    float progress = uTimeProgress;
    
    // Fixed mode logic with subtle animation if autoCycle is on
    float animOffset = (uCycleMode != 0 && uCycleMode != 3) ? sin(uTime * 0.2) * 0.05 : 0.0;
    
    if (uCycleMode == 1) progress = 0.5 + animOffset; // Sun
    if (uCycleMode == 2) progress = 0.0 + animOffset; // Moon
    if (uCycleMode == 3) progress = 0.5; // Solar Eclipse (Fixed)
    if (uCycleMode == 4) progress = 0.0 + animOffset; // Lunar Eclipse
    
    // angle maps 0..1 to 1.5PI..-0.5PI (Clockwise full circle)
    float angle = 1.5 * PI - progress * 2.0 * PI;
    
    float orbitRadius = uRadius * 1.5;
    vec2 sunPos = vec2(cos(angle), sin(angle)) * orbitRadius + vec2(0.0, horizon);
    
    // Moon is opposite to sun in celestial cycles
    float moonAngle = angle + PI;
    vec2 moonPos = vec2(cos(moonAngle), sin(moonAngle)) * orbitRadius + vec2(0.0, horizon);

    if (uCycleMode == 3) { // Solar Eclipse
        sunPos = vec2(0.0, 0.4); 
        moonPos = sunPos;
    } else if (uCycleMode == 4) { // Lunar
        moonPos = vec2(0.0, 0.4 + animOffset * 0.2);
    }
    
    // 1. Atmosphere
    vec3 color = getSkyColor(uv.y, progress, uCycleMode);

    // 2. Stars
    float nightStrength = smoothstep(0.1, 0.5, abs(progress - 0.5) * 2.0);
    if (uCycleMode == 3) nightStrength = 0.8;
    if (uCycleMode == 1) nightStrength = 0.0;
    if (uCycleMode == 2 || uCycleMode == 4) nightStrength = 1.0;

    if (nightStrength > 0.1) {
        float stars = pow(hash(uv * 600.0), 60.0) * uStarIntensity * nightStrength;
        stars *= abs(sin(uTime * 0.3 + hash(uv) * 20.0));
        color += stars;
    }

    // Mouse Interaction: Subtle glow or distortion
    float distToMouse = length(p - m);
    color += vec3(0.1, 0.2, 0.3) * exp(-distToMouse * 5.0) * 0.3;

    // 3. Bodies
    float baseSize = 0.05 * uSize;
    
    if (uCycleMode != 2 && uCycleMode != 4) { // Sun
        float distToSun = length(p - sunPos);
        float sunDisk = smoothstep(baseSize, baseSize * 0.9, distToSun);
        float sunGlow = exp(-distToSun * 8.0) * uBloom;
        
        if (uCycleMode == 3) {
            // Solar Eclipse - Smoother Corona to avoid "mosaic"
            float corona = smoothstep(baseSize, baseSize * 1.05, distToSun) * smoothstep(baseSize * 4.5, baseSize * 1.05, distToSun);
            // Scale noise and use softer mixing
            float n = fbm(p * 5.0 - uTime * 0.15);
            vec3 coronaColor = mix(vec3(1.0, 0.95, 0.9), vec3(0.6, 0.8, 1.0), n);
            color += coronaColor * corona * (0.6 + n * 0.4) * uBloom;
            color = mix(color, vec3(0.0), smoothstep(baseSize * 1.02, baseSize, distToSun));
        } else {
            color += vec3(1.0, 0.9, 0.7) * sunDisk;
            color += vec3(1.0, 0.5, 0.2) * sunGlow * 0.6;
        }
    }

    if (uCycleMode != 1 && uCycleMode != 3) { // Moon
        float distToMoon = length(p - moonPos);
        float moonDisk = smoothstep(baseSize, baseSize * 0.95, distToMoon);
        
        vec3 moonColor = vec3(0.85, 0.9, 0.95);
        if (uCycleMode == 4) {
            moonColor = vec3(0.7, 0.12, 0.05); // Deeper Blood Moon
            color += vec3(0.6, 0.1, 0.05) * exp(-distToMoon * 10.0) * uBloom;
        }
        
        // Normalized coordinates inside the moon disk for texture and shading
        vec2 moonP = (p - moonPos) / baseSize;
        
        // Multi-layered texture: Maria (large dark spots) + Craters (small details)
        float maria = fbm(moonP * 1.5 + 1.2) * 0.4;
        float craters = fbm(moonP * 4.0) * 0.15;
        float textureDetail = max(0.0, 1.0 - (maria + craters));
        
        // Base surface color with texture
        vec3 moonSurface = moonColor * textureDetail;
        
        // Phase masking - Improved for spherical feel (Earthshine)
        if (uCycleMode == 0 || uCycleMode == 2) {
            // Use uMoonPhase to control the phase (0.0: New, 0.5: Half, 1.0: Full)
            // Map uMoonPhase to a horizontal rotation angle
            float phaseRot = (uMoonPhase - 0.5) * PI * 1.2;
            vec3 lightDir = normalize(vec3(sin(phaseRot), 0.2, cos(phaseRot)));
            
            float sphericalIntensity = dot(vec3(moonP, sqrt(max(0.0, 1.0 - dot(moonP, moonP)))), lightDir);
            
            // Use more contrast for phases
            float brightMask = smoothstep(-0.1, 0.1, sphericalIntensity);
            
            // Combine everything
            vec3 brightSide = moonSurface * (0.9 + 0.1 * brightMask);
            vec3 darkSide = moonColor * 0.12 * textureDetail; // Earthshine color
            
            vec3 finalMoon = mix(darkSide, brightSide, brightMask);
            
            // Rim highlight for definition
            float rim = pow(1.0 - max(0.0, dot(vec3(moonP, 0.0), vec3(moonP, 0.0))), 3.0) * 0.15;
            finalMoon += rim * uMoonGlowColor;
            
            color = mix(color, finalMoon, moonDisk);
        } else {
            // Eclipses
            color = mix(color, moonSurface, moonDisk);
        }
        
        color += uMoonGlowColor * exp(-distToMoon * 12.0) * uBloom * 0.4;
        color += vec3(0.4, 0.5, 0.6) * exp(-distToMoon * 15.0) * uBloom * 0.4;
    }

    // 4. Sea Reflection - Improved Multi-layered Noise
    float seaLevel = (horizon + 1.0) / 2.0; // Map back to 0..1 uv.y
    if (uSeaEnabled && uv.y < seaLevel) {
        float seaMask = smoothstep(seaLevel, seaLevel - 0.02, uv.y);
        vec3 seaBase = color * 0.4 + vec3(0.01, 0.03, 0.06);
        
        // Select correct body position for reflection
        vec2 targetPos = (uCycleMode == 1 || (uCycleMode == 0 && progress > 0.2 && progress < 0.8)) ? sunPos : moonPos;
        if (uCycleMode == 3) targetPos = sunPos;
        if (uCycleMode == 4) targetPos = moonPos;
        
        float dx = abs(p.x - targetPos.x);
        
        // Specular Reflection
        float distToHorizon = abs(uv.y - seaLevel);
        float reflectWidth = 10.0 + distToHorizon * 20.0;
        float reflectGlow = exp(-dx * reflectWidth) * smoothstep(seaLevel, 0.0, uv.y) * uBloom;
        
        vec3 reflectColor = vec3(1.0);
        if (uCycleMode == 1 || uCycleMode == 3 || (uCycleMode == 0 && progress > 0.2 && progress < 0.8)) {
            reflectColor = vec3(1.0, 0.7, 0.3); 
            reflectGlow *= smoothstep(-0.4, 0.5, targetPos.y);
        } else if (uCycleMode == 4) {
            reflectColor = vec3(1.0, 0.2, 0.1); 
            reflectGlow *= smoothstep(-0.4, 0.5, targetPos.y);
        } else {
            reflectColor = vec3(0.6, 0.7, 0.9); 
            reflectGlow *= smoothstep(-0.4, 0.5, targetPos.y);
        }
        
        seaBase += reflectColor * reflectGlow * 0.6;
        
        // Layered Ripples
        float ripple1 = noise(uv * vec2(15.0, 80.0) + uTime * 0.5) * 0.02;
        float ripple2 = noise(uv * vec2(30.0, 150.0) - uTime * 0.3) * 0.01;
        seaBase += (ripple1 + ripple2) * reflectGlow;
        seaBase += ripple1 * 0.5;
        
        // Mouse Waves
        float mouseWave = exp(-length(p - m) * 10.0) * 0.1;
        seaBase += mouseWave * vec3(0.5, 0.7, 1.0);
        
        color = mix(color, seaBase, seaMask);
    }

    gl_FragColor = vec4(color, 1.0);
}
