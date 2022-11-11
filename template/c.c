#include <tgmath.h>
#define N 640
#define H 480

const float A = 0, B = 1;
float Y[N];
float H;
float Curr;
float Min, Max;
float K;

float f(float x)
{
	float
		s = sin(x),
		c = cos(x);
	return (s*s*s + c*c*c) / 2.f;
}

void _start(void)
{
	H = (B - A) / N;
	Curr = A;
	for (int i = 0; i < N; ++i)
	{
		Y[i] = f(Curr);
		Curr += H;
	}
	Min = Y[0];
	Max = Y[0];
	for (int i = 0; i < N; ++i)
	{
		if (Y[i] > Max)
			Max = Y[i];
		if (Y[i] < Min)
			Min = Y[i];
	}
	K = H / (Max - Min);
	for (int i = 0; i < N; ++i)
	{
		Y[i] = (Y[i] - Min) * K;
	}
}