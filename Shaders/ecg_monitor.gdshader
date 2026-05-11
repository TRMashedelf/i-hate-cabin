shader_type canvas_item;

// Health: 0.0 = dead, 1.0 = full health
uniform float health : hint_range(0.0, 1.0) = 1.0;
uniform float time_offset : hint_range(0.0, 100.0) = 0.0;

// ECG waveform shape — returns Y value (0..1) for a given X position in the wave cycle
float ecg_wave(float x) {
    // x is 0..1 across one beat cycle
    float y = 0.0;

    // Flat baseline
    y = 0.0;

    // P wave (small bump)
    float p = x - 0.25;
    y += 0.08 * exp(-pow(p / 0.04, 2.0));

    // Q dip
    float q = x - 0.28;
    y -= 0.05 * exp(-pow(q / 0.015, 2.0));

    // R spike (the big peak)
    float r = x - 0.32;
    y += 0.8 * exp(-pow(r / 0.018, 2.0));

    // S dip
    float s = x - 0.37;
    y -= 0.15 * exp(-pow(s / 0.018, 2.0));

    // T wave (recovery bump)
    float t = x - 0.55;
    y += 0.12 * exp(-pow(t / 0.06, 2.0));

    return y;
}

void fragment() {
    // Speed increases as health decreases (panic / distress effect)
    float bpm_multiplier = mix(2.5, 0.6, health);
    float scroll = mod(time_offset * bpm_multiplier, 1.0);

    // Map UV.x to wave cycle position
    float wave_x = mod(UV.x + scroll, 1.0);
    float wave_y = ecg_wave(wave_x);

    // Center the wave vertically; map wave output (approx -0.2..0.9) to UV.y space
    float center = 0.5;
    float wave_screen_y = center - wave_y * 0.45;

    // Distance from the current pixel to the wave line
    float dist = abs(UV.y - wave_screen_y);
    float line_thickness = 0.012;
    float glow_thickness = 0.06;

    // Color: green at full health → yellow → red at low health
    vec3 healthy_color = vec3(0.0, 1.0, 0.3);
    vec3 mid_color     = vec3(1.0, 0.8, 0.0);
    vec3 danger_color  = vec3(1.0, 0.1, 0.1);

    vec3 line_color;
    if (health > 0.5) {
        line_color = mix(mid_color, healthy_color, (health - 0.5) * 2.0);
    } else {
        line_color = mix(danger_color, mid_color, health * 2.0);
    }

    // Flatline effect when health == 0
    if (health < 0.01) {
        wave_screen_y = 0.5;
        dist = abs(UV.y - 0.5);
        line_color = danger_color;
    }

    // Crisp line + soft glow
    float line  = smoothstep(line_thickness, 0.0, dist);
    float glow  = smoothstep(glow_thickness, line_thickness, dist) * 0.25;

    // Dark background with scanlines for that CRT monitor feel
    float scanline = mod(floor(UV.y * 80.0), 2.0) < 1.0 ? 0.85 : 1.0;
    vec3 bg = vec3(0.02, 0.06, 0.02) * scanline;

    vec3 final_color = bg + line_color * (line + glow);
    float alpha = 0.92;

    COLOR = vec4(final_color, alpha);
}