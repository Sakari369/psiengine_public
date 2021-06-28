// PSIEngine copyright (c) 2021 Sakari Lehtonen <sakari@psitriangle.net>
//
// Mouse and keyboard handling.

#pragma once

// Includes
#include "PSIVideo.h"
#include "PSIMath.h"

class InputHandler {
	public:
		InputHandler() = default;
		~InputHandler() = default;

		// Get wasd -style keyboard movement as translation vector.
		glm::vec3 get_key_movement(glm::vec3 &front, glm::vec3 &up, GLfloat frametime);
		// Is keyboard key currently pressed ?
		GLboolean key_pressed(GLint key);
		// Set mouse cursor position callback.
		void set_cursor_pos(GLdouble x, GLdouble y);
		// Get mouse movement delta from last position.
		glm::vec3 get_mouse_delta();
		// Is mouse button pressed ?
		GLboolean mouse_button_pressed(GLint button);

		// Set key active.
		void set_key(GLint key, GLboolean val) {
			_keys[key] = val;
			if (val == true) { _key_pressed[key] = true; }
		}
		GLboolean key_held(GLint key) {
			return _keys[key];
		}

		void set_movement_speed(GLfloat movement_speed) {
			_movement_speed = movement_speed;
		}
		GLfloat get_movement_speed() {
			return _movement_speed;
		}

		void set_modifiers(GLint mods) {
			_mods = mods;
		}
		GLint get_modifiers() {
			return _mods;
		}

		// Store mouse button state.
		void set_mouse_button(GLint button, GLboolean val) {
			_mouse_buttons[button] = val;
			if (val == true) {
				_mouse_buttons_pressed[button] = true;
			}
		}

		GLboolean mouse_button_held(GLint button) {
			return _mouse_buttons[button];
		}

	private:
		// Keyboard map.
		bool _keys[1024] = { false };
		// Is key being pressed ?
		GLint _key_pressed[1024] = { 0 };

		// Keyboard modifiers currently active (shift, alt etc).
		GLuint _mods = 0;
		// Movement vector.
		GLfloat _movement_speed = 0.1f;
		// First time mouse event ?
		GLboolean _first_mouse_event = true;

		// Mouse buttons active.
		bool _mouse_buttons[GLFW_MOUSE_BUTTON_LAST] = { false };
		// Mouse buttons pressed.
		bool _mouse_buttons_pressed[GLFW_MOUSE_BUTTON_LAST] = { false };

		// Last mouse position.
		PSIMath::pos<GLfloat> _last_mouse_pos = { 0.0f, 0.0f };
		// Movement delta from last position.
		glm::vec3 _mouse_delta = glm::vec3(0.0f, 0.0f, 0.0f);
		// Mouse sensitivity factor for cursor position setting.
		GLfloat _mouse_sens = 0.05f;
};
