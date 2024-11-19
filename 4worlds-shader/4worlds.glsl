const float line_width = .05;
const float anti_alias = .007;
const float circle_radius = .175;
const float circle_distance = .57; // from origin

float square_distance(vec2 uv, vec2 origin) {
    vec2 dd = abs(uv - origin);
    return max(dd.x, dd.y);
}

// [n_min, n_max] -> [0, 1]
float squash(float n, float n_min, float n_max) {
  n = max(n, n_min);
  n = min(n, n_max);
  return (n - n_min) / (n_max - n_min);
}

// [0,1] grayscale
float worlds(vec2 uv) {
    float half_width = (line_width - anti_alias) / 2.;
    float inner = circle_radius - half_width;
    float outer = circle_radius + half_width;
    float inner_fuzz = inner - anti_alias;
    float outer_fuzz = outer + anti_alias;

    uv = abs(uv);
    float d = distance(vec2(circle_distance), uv);
    float d_low = squash(d, inner_fuzz, inner);
    float d_high = squash(d, outer, outer_fuzz);
    return d_low - d_high;
}

bool w_all(vec2 uv) {
    vec2 dd = abs(uv); // distance from image center
    float d = max(dd.x, dd.y); // whichever is longer
    return d < 1. && d > (1. - line_width);
}

bool w_right(vec2 uv) {
    vec2 dd = abs(uv - vec2(circle_distance, 0)); // distance from point between worlds
    float d = max(dd.x + circle_distance, dd.y);
    return d < 1. && d > (1. - line_width);
}

bool w_left(vec2 uv) {
    return w_right(vec2(-uv.x, uv.y));
}

bool w_top(vec2 uv) {
    return w_right(uv.yx);
}

bool w_bottom(vec2 uv) {
    return w_right(vec2(-uv.y, uv.x));
}

bool w_topright(vec2 uv) {
    if (uv.x < 0. || uv.y < 0.) {
        return false;
    }
    vec2 dd = abs(uv - vec2(circle_distance)); // distance from world center
    float d = max(dd.x, dd.y) + circle_distance;
    return d < 1. && d > (1. - line_width);
}

bool w_topleft(vec2 uv) {
    return w_topright(vec2(-uv.x, uv.y));
}

bool w_bottomleft(vec2 uv) {
    return w_topright(-uv);
}

bool w_bottomright(vec2 uv) {
    return w_topright(vec2(uv.x, -uv.y));
}

void main() {
    vec2 uv = gl_FragCoord.xy - iResolution.xy / 2.;
    float mx = max(iResolution.x, iResolution.y);
    uv /= mx / 2.; // (-1,1)

    // center
    uv *= 1.5;

    int t = int(iTime * 4.) % 12;

    vec3 c = vec3(1.-(
        worlds(uv) + float(
            ((t == 0 || t == 6) && w_all(uv))
            || (t == 1 && w_right(uv))
            || (t == 2 && w_bottomright(uv))
            || (t > 1 && t < 5 && w_topright(uv))
            || (t == 4 && w_topleft(uv))
            || (t == 5 && w_top(uv))
            || (t == 7 && w_left(uv))
            || (t == 8 && w_topleft(uv))
            || (t > 7 && t < 11 && w_bottomleft(uv))
            || (t == 10 && w_bottomright(uv))
            || (t == 11 && w_bottom(uv))
        )
            //+ float(world4(-uv))
    ));

    gl_FragColor = vec4(c, 1);
}
