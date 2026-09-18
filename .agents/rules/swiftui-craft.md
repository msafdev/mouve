# Rule: SwiftUI Craft & Anti-Liquid Glass

1. **No Liquid Glass**:
   - Avoid using system translucent glass / materials (`.ultraThinMaterial`, `.regularMaterial`) as backgrounds.
   - Use opaque, matte, rich solid colors, subtle inner stroke borders, and fine highlights.
2. **Mechanical & Tactile Depth**:
   - For buttons, include physical press travel (e.g. `offset(y: isPressed ? 3 : 0)`), bottom bezel shadow reduction, and scale dampening (`0.98`).
3. **Motion Curves**:
   - Use `MotionTokens.snappy`, `MotionTokens.bouncy`, and `MotionTokens.smooth`.
   - Never hardcode `.easeInOut(duration: 0.3)`.
4. **Elevation**:
   - Apply `ElevationTokens` (ambient + key shadows) rather than standard single `.shadow()`.
