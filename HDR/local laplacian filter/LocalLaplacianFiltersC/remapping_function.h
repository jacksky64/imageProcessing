// File Description

#ifndef REMAPPING_FUNCTION_H
#define REMAPPING_FUNCTION_H

#include <opencv2/opencv.hpp>
#include <cmath>

class RemappingFunction {
public:
	RemappingFunction(float alpha, float beta);
	~RemappingFunction();

	float alpha() const { return alpha_; }
	void set_alpha(float alpha) { alpha_ = alpha; }

	float beta() const { return beta_; }
	void set_beta(float beta) { beta_ = beta; }

	void Evaluate(float value,
		float reference,
		float sigma_r,
		float& output);

	void Evaluate(const cv::Vec3d& value,
		const cv::Vec3d& reference,
		float sigma_r,
		cv::Vec3d& output);

	template<typename T>
	void Evaluate(const cv::Mat& input, cv::Mat& output,
		const T& reference, float sigma_r);

private:
	float DetailRemap(float delta, float sigma_r);
	float EdgeRemap(float delta);

	float SmoothStep(float x_min, float x_max, float x);

private:
	float alpha_, beta_;
};

inline float RemappingFunction::DetailRemap(float delta, float sigma_r) {
	float fraction = delta / sigma_r;
	float polynomial = pow(fraction, alpha_);
	if (alpha_ < 1) {
		const float kNoiseLevel = 0.01;
		float blend = SmoothStep(kNoiseLevel,
			2 * kNoiseLevel, fraction * sigma_r);
		polynomial = blend * polynomial + (1 - blend) * fraction;
	}
	return polynomial;
}

inline float RemappingFunction::EdgeRemap(float delta) {
	return beta_ * delta;
}

template<typename T>
void RemappingFunction::Evaluate(const cv::Mat& input, cv::Mat& output,
	const T& reference, float sigma_r) {
	output.create(input.rows, input.cols, input.type());
	for (int i = 0; i < input.rows; i++) {
		for (int j = 0; j < input.cols; j++) {
			Evaluate(input.at<T>(i, j), reference, sigma_r, output.at<T>(i, j));
		}
	}
}

#endif  // REMAPPING_FUNCTION_H
