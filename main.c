#include <stdio.h>
#include <stdint.h>
#include <math.h>

uint8_t test1[] = "\x20\x09""1234.5678\n$\0";
uint8_t test2[] = "\x20\x0a-1234.5678\n$\0";
uint8_t test3[] = "\x20\x04""1234\n$\0";
uint8_t test4[] = "\x20\x07-0.5678\n$\0";
uint8_t test5[] = "\x20\x04-0.0\n$\0";

float stof__(uint8_t* s)
{
	int8_t sign = 1;
	uint8_t l = s[1];
	uint8_t i = 2;
	uint16_t _i = 0;
	uint16_t _d = 0;
	uint16_t _d10 = 1;
	if (l == 0)
		return NAN;
	if (s[2] == '-')
	{
		sign = -1;
		i = 3;
	}
stof__loop1:
	if (i - 2 >= l)
		goto ret;
	if (s[i] == '$')
		goto ret;
	if (s[i] == '.')
		goto stof__loop1_end;

	_i = _i * 10;
	_i = _i + s[i] - '0';

	i++;
	goto stof__loop1;
stof__loop1_end :
	i++;
stof__loop2 :
	if (i - 2>= l)
		goto stof__loop2_end;
	if (s[i] == '$')
		goto stof__loop2_end;

	_d = _d * 10;
	_d = _d + s[i] - '0';
	_d10 = _d10 * 10;

	i++;
	goto stof__loop2;
	stof__loop2_end :
ret:
	return (_i + (_d * 1.f / _d10)) * sign; // _d _d10 / _i + sign *
}

int main(int argc, char const* argv[])
{
	uint8_t* tests[5] = { &test1[0], &test2[0], &test3[0], &test4[0], &test5[0] };
	for (int i = 0; i < 5; ++i)
	{
		printf("%s\t%f\n", (tests[i]) + 2, stof__(tests[i]));
	}
	return 0;
}