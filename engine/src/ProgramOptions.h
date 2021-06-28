// PSIEngine Copyright (c) 2021 Sakari Lehtonen <sakari@psitriangle.net>
//
// Global program options.

#pragma once

#include "PSIOpenGL.h"
#include "PSIVideo.h"

// Container class to hold our command line options.
// And easy passage to the lua scripts.
class ProgramOptions {
	private:
	public:
		ProgramOptions() = default;
		~ProgramOptions() = default;

		GLint fullscreen = 0;
		GLint vsync = 1;

		GLint screen_width = PSIVideo::DEF_SCREEN_WIDTH;
		GLint screen_height = PSIVideo::DEF_SCREEN_HEIGHT;
		GLint msaa_samples = PSIVideo::DEF_MSAA_SAMPLES;
		GLint monitor_index = 0;

		GLint exit_after_one_frame = 0;

		std::string main_script_name = "";
		std::string asset_dir = "../assets";
};
