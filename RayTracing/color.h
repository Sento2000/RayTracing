#ifndef COLOR_H
#define COLOR_J

#include"vec3.h"

using color = vec3;

void write_color(std::ostream& out, const color& pixel_color)
{
	auto r = pixel_color.x();
	auto g = pixel_color.y();
	auto b = pixel_color.z();

	int rbyte = int(r * 255.99);
	int gbyte = int(g * 255.99);
	int bbyte = int(b * 255.99);

	out << rbyte << ' ' << gbyte << ' ' << bbyte << '\n';
}

#endif