// PSIEngine Copyright (c) 2021 Sakari Lehtonen <sakari@psitriangle.net>
//
// Binds all the C++ classes to the Lua side, using LuaIntf.

#pragma once

#include "PSITriangleEngine.h"

#include "PSIGlobals.h"

#include "InputHandler.h"
#include "ProgramOptions.h"

#include "vendor/LuaIntf/LuaIntf.h"

extern "C" {
#include <lua.h>
#include <lauxlib.h>
#include <lualib.h>
}

class LuaAPI {
public:
	LuaAPI() = default;
	~LuaAPI() = default;

	lua_State *get_state() {
		return _lua;
	}

	void set_audio(const shared_ptr<PSIAudio> &audio) {
		_audio = audio;
	}
	void set_video(const shared_ptr<PSIVideo> &video) {
		_video = video;
	}
	void set_input(const shared_ptr<InputHandler> &input) {
		_input = input;
	}
	void set_options(const shared_ptr<ProgramOptions> &options) {
		_options = options;
	}

	void set_script_string(std::string script_string) {
		_script_str = script_string;
		_loading_script_from_string = true;
	}

	int init();

	// Run lua script main.
	int run_main();

private:
	// Lua state.
	lua_State *_lua;

	// Pointers to our global classes.
	shared_ptr<PSIVideo> _video;
	shared_ptr<PSIAudio> _audio;
	shared_ptr<InputHandler> _input;

	// Program options passed from main to Lua.
	shared_ptr<ProgramOptions> _options;
	// Whether we are loading script from string or file ?
	bool _loading_script_from_string = false;
	// Script string to load script from.
	std::string _script_str;

	// Bind PSIEngine and application interface to Lua.
	bool bind_lua();
};
