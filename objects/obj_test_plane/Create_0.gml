event_inherited();

vbuffer = vertex_create_buffer();

// Define basic 1x1 plane shape
vertex_begin(vbuffer, obj_renderer.vformat_color);
add_vertex(-0.5, 0, -0.5);
add_vertex(+0.5, 0, -0.5);
add_vertex(-0.5, 0, +0.5);

add_vertex(+0.5, 0, -0.5);
add_vertex(+0.5, 0, +0.5);
add_vertex(-0.5, 0, +0.5);
vertex_end(vbuffer);