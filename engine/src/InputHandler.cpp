#include "InputHandler.h"

glm::vec3 InputHandler::get_mouse_delta() {
	glm::vec3 delta = _mouse_delta;

	// Reset delta so it is not continous movement.
	_mouse_delta.x = 0.0f;
	_mouse_delta.y = 0.0f;

	return delta;
}

void InputHandler::set_cursor_pos(GLdouble x, GLdouble y) {
	// First time running, set reference point.
	if(_first_mouse_event == true) {
		_last_mouse_pos.x = x;
		_last_mouse_pos.y = y;

		_first_mouse_event = false;
	}

	// Increase mouse delta.
	_mouse_delta.x = _mouse_sens * (x - _last_mouse_pos.x);
	_mouse_delta.y = _mouse_sens * (_last_mouse_pos.y - y);

	// Store previous mouse position for calculating mouse delta.
	_last_mouse_pos.x = x;
	_last_mouse_pos.y = y;
}

GLboolean InputHandler::mouse_button_pressed(GLint button) {
	GLboolean pressed = false;
	if (_mouse_buttons_pressed[button] == true) {
		pressed = true;
		_mouse_buttons_pressed[button] = false;
	}

	return pressed;
}

GLboolean InputHandler::key_pressed(GLint key) {
	GLboolean pressed = false;
	if (_key_pressed[key] == true) {
		pressed = true;
		_key_pressed[key] = false;
	}

	return pressed;
}

#define DEFAULT_TARGET_FPS 60
glm::vec3 InputHandler::get_key_movement(glm::vec3 &front, glm::vec3 &up, GLfloat frametime) {
	GLfloat frametime_mult  = ((1.0 / DEFAULT_TARGET_FPS) * 1000.0f) / frametime;
	GLfloat speed = _movement_speed * frametime_mult;
	glm::vec3 translation = glm::vec3(0.0f);

	// Translate along front vector, meaning movement along Z-axis.
	// W, forwards.
	if (_keys[GLFW_KEY_W] == true) {
		translation += speed * front;
	}
	// S, backwards.
	else if (_keys[GLFW_KEY_S] == true) {
		translation += -1.0f * speed * front;
	}

	// Translate along X-axis.
	// A, D -- horizontal movement, strafing.
	// A, left.
	if (_keys[GLFW_KEY_A] == true) {
		translation += -1.0f * speed * glm::normalize(glm::cross(front, up));
	}
	// D, right.
	else if (_keys[GLFW_KEY_D] == true) {
		// Translate along X-axis.
		translation += speed * glm::normalize(glm::cross(front, up));
	}

	// Translate along Y-axis.
	// Flying up.
	if (_mouse_buttons[GLFW_MOUSE_BUTTON_2] == true) {
		translation += -1.0f * speed * up;
	}
	// Flying down.
	else if (_mouse_buttons[GLFW_MOUSE_BUTTON_1] == true) {
		translation += speed * up;
	}

	return translation;
}
