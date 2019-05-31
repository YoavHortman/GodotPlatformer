extends TileMap

var grid = [];

func _ready():
	randomize();
	grid.resize(31);
	for n in 31:
		grid[n] = [];
		grid[n].resize(51);
		for m in 51:
			if n % 30 == 0 or m % 50 == 0:
				if randi() % 20 == 0:
					grid[n][m] = -1;
				else:
					if n == 50:
						grid[n][m] = 3;
					elif n == 0:
						grid[n][m] = 5;
					else: 
						grid[n][m] = 1;
			elif m % 3 == 0:
				if randi() % 10 == 0:
					grid[n][m] = -1
					grid[n][m + 1] = -1
				else:
					grid[n][m] = 5;
			else:
				grid[n][m] = -1;

	for n in range(0,31):
		for m in range(0,51):
			set_cell(n, m, grid[n][m]);
