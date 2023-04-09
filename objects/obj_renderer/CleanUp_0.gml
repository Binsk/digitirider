vertex_format_delete(vformat_color);
vertex_format_delete(vformat_pipe);
if (surface_exists(surface_glow))
    surface_free(surface_glow);
if (surface_exists(surface_depth))
    surface_free(surface_depth);
if (surface_exists(surface_depth_transition))
    surface_free(surface_depth_transition);
if (surface_exists(surface_opaque))
    surface_free(surface_opaque);
if (surface_exists(surface_transluscent))
    surface_free(surface_transluscent);
if (surface_exists(surface_merged))
    surface_free(surface_merged);