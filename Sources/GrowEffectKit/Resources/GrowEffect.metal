#include <SwiftUI/SwiftUI.h>
#include <metal_stdlib>

using namespace metal;

[[ stitchable ]]
half4 growGlow(
  float2 position,
  half4 color,
  float2 origin,
  float2 size,
  float amplitude,
  float progress
) {
  float2 safeSize = max(size, float2(1.0));
  float safeProgress = max(progress, 0.001);
  float2 uvPosition = position / safeSize;
  float2 uvOrigin = origin / safeSize;
  float distance = length(uvPosition - uvOrigin);
  float glowIntensity = smoothstep(0.0, 1.0, progress) * exp(-distance * distance) * amplitude;
  glowIntensity *= smoothstep(0.0, 1.0, 1.0 - distance / safeProgress);

  return color * glowIntensity;
}
