color = {
		white =		{1.00,	1.00,	1.00},
		ltgrey =	{0.50,	0.60,	0.70},
		blue =		{0.10,	0.10,	0.70},
		purple =	{0.70,	0.00,	0.70},
		green =		{0.50,	1.00,	0.20},
		orange =	{1.00,	0.60,	0.10},
		red =		{0.90,	0.10,	0.10}
}

color.r = function (name)
        return color[name][1]
end

color.g = function (name)
        return color[name][2]
end

color.b = function (name)
        return color[name][3]
end

color.rgb = function (name)
        return color[name][1],color[name][2],color[name][3]
end

return color
