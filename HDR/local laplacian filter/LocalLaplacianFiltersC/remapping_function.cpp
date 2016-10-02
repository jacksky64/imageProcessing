// File Description

#include "remapping_function.h"

#include <cmath>
#include <algorithm>

using namespace std;

RemappingFunction::RemappingFunction(float alpha, float beta)
	: alpha_(alpha), beta_(beta) {}

RemappingFunction::~RemappingFunction() {}

float RemappingFunction::SmoothStep(float x_min, float x_max, float x) {
	float y = (x - x_min) / (x_max - x_min);
	y = max(0.0f, min(1.0f, y));
	return pow(y, 2) * pow(y - 2, 2);
}

void RemappingFunction::Evaluate(float value,
	float reference,
	float sigma_r,
	float& output) {
	float delta = std::abs(value - reference);
	int sign = value < reference ? -1 : 1;

	if (delta < sigma_r) {
		output = reference + sign * sigma_r * DetailRemap(delta, sigma_r);
	}
	else {
		output = reference + sign * (EdgeRemap(delta - sigma_r) + sigma_r);
	}
}


void RemappingFunction::Evaluate(const cv::Vec3d& value,
	const cv::Vec3d& reference,
	float sigma_r,
	cv::Vec3d& output) {
	cv::Vec3d delta = value - reference;
	float mag = cv::norm(delta);
	if (mag > 1e-10) delta /= mag;

	if (mag < sigma_r) {
		output = reference + delta * sigma_r * DetailRemap(mag, sigma_r);
	}
	else {
		output = reference + delta * (EdgeRemap(mag - sigma_r) + sigma_r);
	}
}
