// PSIEngine copyright (c) 2021 Sakari Lehtonen <sakari@psitriangle.net>
//
// Main application entry point for PSITriangle Engine.
// Setup program options, load Lua -script and start application.

#include <iomanip> 

#include "LuaAPI.h"
#include "ProgramOptions.h"

#ifdef __APPLE__    
#include <CoreFoundation/CoreFoundation.h>
#endif

#define HAVE_GETOPT_LONG

#ifdef HAVE_GETOPT_LONG
#  include <getopt.h>
#else
#  include <unistd.h>
#endif
#include <stdlib.h>

const std::string VERSION_STR = "0.9";

// Global logger instance.
PSILog g_logger;
bool g_logger_initialized = false;

// Printf style log function implementation for the logger.
void psilog_func(int level, char const *fmt, ...) {
	// Initialize.
	if (g_logger_initialized == false) {
		g_logger.set_filter(PSILog::MSG);
		g_logger_initialized = true;
	}

	// Format a variable list of arguments suitable for the logger.
	va_list args;
	va_start(args, fmt);
		va_list args_copy;
			va_copy(args_copy, args);
			const int len = std::vsnprintf(NULL, 0, fmt, args_copy);
		va_end(args_copy);

		// Return a formatted string without risking memory mismanagement
		// and without assuming any compiler or platform specific behavior.
		std::vector<char> zc(len + 1);
		std::vsnprintf(zc.data(), zc.size(), fmt, args);
	va_end(args);

	std::string log_entry_str = std::string(zc.data(), zc.size());

	// Stream the log entry to the logger.
	g_logger(level) << log_entry_str;
}

// On macOS we use the bundle resource path as the asset directory, when running from a bundled (distributed) version.
#ifdef __APPLE__    
std::string get_bundle_resources_path() {
	CFBundleRef mainBundle = CFBundleGetMainBundle();
	CFURLRef resourcesURL = CFBundleCopyResourcesDirectoryURL(mainBundle);

	char path[PATH_MAX];
	if (!CFURLGetFileSystemRepresentation(resourcesURL, TRUE, (UInt8 *)path, PATH_MAX)) {
		psilog_err("Failed getting resources URL!");
		return nullptr;
	}

	CFRelease(resourcesURL);

	return std::string(path);
}
#endif

static void usage(int status) {
	if (status != 0) {
		fprintf(stderr, "No script provided. Try `%s hypercube`. See `%s -h' for more information\n", 
		PSI_G::program_name, PSI_G::program_name);
	} else {
		printf("Usage: %s [SCRIPT_NAME]\nRuns engine script from '%s/[SCRIPT_NAME].lua'\n"
			"\nCommandline options:\n"
			"-a, --antialias [COUNT]\t\tSet MSAA samples to [COUNT]\n"
			"-h, --help\t\t\tDisplay this help and exit\n"
			"-f, --fullscreen\t\tStart in fullscreen\n"
			"-x, --width [PIXELS]\t\tSet window width to [PIXELS]\n"
			"-y, --height [PIXELS]\t\tSet window height to [PIXELS]\n"
			"-n, --vsync [VSYNC]\t\tSet vsync to 0 or 1\n"
			"-m, --monitor [INDEX]\t\tRun on monitor INDEX\n"
			"-v, --version\t\t\tDisplay version information and exit\n",
			PSI_G::program_name, PSI_G::asset_dir);
	}

	exit(status);
}

static void version(void) {
	printf("PSIEngine %s Copyright (C) 2021 Sakari Lehtonen <sakari@psitriangle.net>\n", VERSION_STR.c_str());
}

shared_ptr<ProgramOptions> parse_cmd_line(int argc, char *argv[]) {
	shared_ptr<ProgramOptions> opts = make_shared<ProgramOptions>();

	int optch; 
	char *ptr;
	const char *optstr = "hfnvs:a:m:x:y:";
#ifdef HAVE_GETOPT_LONG
	const struct option longopts[] = {
		{"help", no_argument, 0, 'h'},
		{"version", no_argument, 0, 'v'},
		{"fullscreen", no_argument, 0, 'f'},
		{"vsync", no_argument, 0, 'n'},
		{"script", required_argument, 0, 's'},
		{"antialias", required_argument, 0, 'a'},
		{"monitor", required_argument, 0, 'm'},
		{"width", required_argument, 0, 'x'},
		{"height", required_argument, 0, 'y'},
		{NULL, 0, 0, 0}
	};
	while ((optch = getopt_long(argc, argv, optstr, longopts, NULL)) != -1) {
#else
	while ((optch = getopt(argc, argv, optstr)) != -1) {
#endif /* HAVE_GETOPT_LONG */
		switch(optch) {
		case 'a':
			if (optarg) {
				opts->msaa_samples = strtol(optarg, &ptr, 10);
			}
			break;
		case 'h': 
			usage(EXIT_SUCCESS);
			break;
		case 'f':
			opts->fullscreen = !opts->fullscreen;
			break;
		case 'n':
			opts->vsync = !opts->vsync;
			break;
		case 'x':
			if (optarg) {
				opts->screen_width = strtol(optarg, &ptr, 10);
			}
			break;
		case 'y':
			if (optarg) {
				opts->screen_height = strtol(optarg, &ptr, 10);
			}
			break;
		case 'm':
			if (optarg) {
				opts->monitor_index = strtol(optarg, &ptr, 10);
			}
			break;
		case 'e': 
			opts->exit_after_one_frame = 1;
			break;
		case 'v': 
			version(); 
			exit(EXIT_SUCCESS);
			break;
		default:
			usage(EXIT_FAILURE);
			break;
		}
	}

	// Get main script name from parameter without option.
	if (argc > optind) {
		opts->main_script_name = std::string(argv[optind]);
	}

	return opts;
}

// References to global class instances.
shared_ptr<PSIVideo> video;
shared_ptr<InputHandler> input;
shared_ptr<PSIAudio> audio;

// Key callback for GLFW window. Passes input to our input handler.
// Needs to be here as a static method.
void key_callback(GLFWwindow *window, int key, int scancode, int action, int mods) {
	GLboolean val = true;

	psilog(PSILog::INPUT, "key = %d scancode = %d action = %d mods = %d", key, scancode, action, mods);

	if (action == GLFW_PRESS) {
		val = true;
	} else if (action == GLFW_RELEASE) {
		val = false;
	}

	// Update our input handler.
	input->set_key(key, val);
	input->set_modifiers(mods);
}

// GLFW mouse position callback. Passes position to our input handler.
void mouse_pos_callback(GLFWwindow *window, GLdouble xpos, GLdouble ypos) {
	// Update our cursor position.
	// Calculates internally mouse camera angles also.
	input->set_cursor_pos(xpos, ypos);
}

// GLFW mouse button callback. Passes mouse button to our input handler.
void mouse_button_callback(GLFWwindow *window, GLint button, GLint action, GLint mods) {
	GLboolean val = false;
	if (action == GLFW_PRESS) {
		val = true;
	} else if (action == GLFW_RELEASE) {
		val = false;
	}

	input->set_mouse_button(button, val);
}

// Window gained or lost focus callback.
void window_focus_callback(GLFWwindow *window, int focused) {
	// Pass to our video handler.
	video->set_window_focus(focused);
}

// GLFW viewport size changed callback.
void framebuffer_size_callback(GLFWwindow *window, int width, int height) {
	video->resize_viewport(width, height);
}

// GLFW window refresh callback. Called when contents of a window is damaged and needs to be refreshed.
void window_refresh_callback(GLFWwindow* window) {
	video->resize_refresh();
}

int main(int argc, char **argv) {
	PSI_G::program_name = argv[0];

	// Set current asset directory.
	std::string asset_dir;
	#ifdef BUILD_BUNDLE
		// If we are bundling the program, asset directory on macOS will be the resource path.
		asset_dir = get_bundle_resources_path();
	#else
		// Else we are running directly form the build directory, set static relative path.
		// TODO: figure out how to find this properly .. 
		// Should be probably defined from CMAKE through a find_psi_assets_dir()
		// function with -DPSI_ASSET_DIR.
		asset_dir = "../assets";
	#endif
	PSI_G::asset_dir = asset_dir.c_str();

	// Parse command line options.
	shared_ptr<ProgramOptions> opts = parse_cmd_line(argc, argv);
	opts->asset_dir = asset_dir;

	if (opts->main_script_name == "") {
		usage(EXIT_FAILURE);
	}

	// Create Lua -script loader.
	unique_ptr<LuaAPI> lua_loader;
	lua_loader = make_unique<LuaAPI>();

	// Initialize input.
	input = make_shared<InputHandler>();
	// Pass the input object to our Lua env as a global variable.
	lua_loader->set_input(input);

	// Initialize our video system. 
	// We are using GLFW for window management & GLEW for OpenGL loading.
	video = make_shared<PSIVideo>();
	video->set_window_size(opts->screen_width, opts->screen_height);
	video->set_fullscreen(opts->fullscreen);
	video->set_msaa_samples(opts->msaa_samples);
	video->set_vsync(opts->vsync);
	video->set_window_title("PSIEngine :: " + opts->main_script_name);

	if (video->init() == false) {
		psilog_err("Failed initializing video");
		return EXIT_FAILURE;
	}

	// Register event handlers.
	GLFWwindow *win = video->get_window();
	glfwSetKeyCallback(win, key_callback);
	glfwSetCursorPosCallback(win, mouse_pos_callback);
	glfwSetMouseButtonCallback(win, mouse_button_callback);
	glfwSetWindowFocusCallback(win, window_focus_callback);
	glfwSetFramebufferSizeCallback(win, framebuffer_size_callback);

	// Pass the video object to our Lua env.
	lua_loader->set_video(video);

	// Audio.
	audio = make_shared<PSIAudio>();
	lua_loader->set_audio(audio);

	// Pass program options to lua loader.
	lua_loader->set_options(opts);

	// Initialize and run Lua -script.
	lua_loader->init();
	lua_loader->run_main();
}
