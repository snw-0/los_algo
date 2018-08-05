color = {
		white =		{1.00,	1.00,	1.00},
		blue =		{0.10,	0.10,	0.40},
		dkblue =	{0.00,	0.00,	0.20},

		orange =	{1.00,	0.60,	0.10},

		red3 =		{1.00,	0.50,	0.30},
		red2 =		{0.80,	0.20,	0.20},
		red1 =		{0.45,	0.10,	0.10},
		red0 =		{0.25,	0.05,	0.05},

		purple3 =	{0.90,	0.60,	1.00},
		purple2 =	{0.60,	0.30,	0.80},
		purple1 =	{0.35,	0.15,	0.60},
		purple0 =	{0.20,	0.10,	0.50},

		green3 =	{0.60,	1.00,	0.20},
		green2 =	{0.20,	0.70,	0.10},
		green1 =	{0.10,	0.40,	0.10},
		green0 =	{0.00,	0.20,	0.20},

		light3 =	{0.90,	0.80,	0.60},
		light2 =	{0.40,	0.50,	0.40},
		light1 =	{0.20,	0.20,	0.40},
		light0 =	{0.20,	0.10,	0.20},

		grey3 =		{0.40,	0.40,	0.40},
		grey2 =		{0.30,	0.30,	0.30},
		grey1 =		{0.20,	0.20,	0.20},
		grey0 =		{0.15,	0.15,	0.15}
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
