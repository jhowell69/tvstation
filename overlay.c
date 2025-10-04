// === PLEASE READ ===
//compiled with 
//gcc overlay.c -o overlay -lX11 -lXrender -lXcomposite -lcairo
//you need to edit line 69 to specify your own channel callsign path
//I may edit this later to be more usable so you can use the program binary file instead of having to compile it yourself


#include <X11/Xlib.h>
#include <X11/Xutil.h>
#include <cairo/cairo.h>
#include <cairo/cairo-xlib.h>
#include <unistd.h>
#include <stdio.h>

int main() {
    Display *dpy = XOpenDisplay(NULL);
    if (!dpy) {
        fprintf(stderr, "Cannot open display\n");
        return 1;
    }

    int screen = DefaultScreen(dpy);
    Window root = RootWindow(dpy, screen);

    // Set size of channel logo
    int win_width = 100;
    int win_height = 100;

    // Get screen size
    int screen_width = DisplayWidth(dpy, screen);
    int screen_height = DisplayHeight(dpy, screen);

    // Set position of channel logo. By default, this puts it at the bottom right
    //this far offset is useful if you're using a crt tv
    // Offset to be compatible with vintage 4:3 CRT televisions
    int x = screen_width - win_width - 110;
    int y = screen_height - win_height - 30;

    // Use ARGB visual for transparency
    XVisualInfo vinfo;
    if (!XMatchVisualInfo(dpy, screen, 32, TrueColor, &vinfo)) {
        fprintf(stderr, "No ARGB visual found\n");
        return 1;
    }

    XSetWindowAttributes attrs;
    attrs.override_redirect = True;
    attrs.colormap = XCreateColormap(dpy, root, vinfo.visual, AllocNone);
    attrs.background_pixel = 0;
    attrs.border_pixel = 0;

    Window win = XCreateWindow(
        dpy, root, x, y, win_width, win_height, 0,
        vinfo.depth, InputOutput, vinfo.visual,
        CWOverrideRedirect | CWColormap | CWBackPixel | CWBorderPixel,
        &attrs
    );

    XMapWindow(dpy, win);
    XFlush(dpy);

    // Create Cairo surface
    cairo_surface_t *surface = cairo_xlib_surface_create(dpy, win, vinfo.visual, win_width, win_height);
    cairo_t *cr = cairo_create(surface);

    // Load PNG image
    // I'm not sure if $HOME from the bash env works here in C so you will either need
    // to create the path or recompile this program with your own file path
    const char *image_path = "/home/tvbox/Pictures/channelcallsign.png";
    cairo_surface_t *image = cairo_image_surface_create_from_png(image_path);
    if (cairo_surface_status(image) != CAIRO_STATUS_SUCCESS) {
        fprintf(stderr, "Failed to load image: %s\n", image_path);
        return 1;
    }

    // Draw image
    double img_width = cairo_image_surface_get_width(image);
    double img_height = cairo_image_surface_get_height(image);

    double scale_x = (double)win_width / img_width;
    double scale_y = (double)win_height / img_height;

    cairo_scale(cr, scale_x, scale_y);
    cairo_set_source_surface(cr, image, 0, 0);
    cairo_paint(cr);


    // Flush and clean up
    cairo_surface_flush(surface);
    XFlush(dpy);

    cairo_surface_destroy(image);
    cairo_destroy(cr);
    cairo_surface_destroy(surface);

    // Keep window alive
    while (1) {
        sleep(1);
    }

    XCloseDisplay(dpy);
    return 0;
}
