from pyray import *
import math
import sys

input_data = sys.stdin.read().splitlines()

MAX_GENERATIONS = int(input_data[0])
CELL_COUNT_V, CELL_COUNT_H = map(int, input_data[1].split())
CELL_SIZE, MARGIN = map(int, input_data[2].split())
PATTERN_ORIGIN_X, PATTERN_ORIGIN_Y = map(int, input_data[3].split())

START_CELLS = [
    (x, y)
    for y, line in enumerate(input_data[4:])  
    for x, char in enumerate(line)
    if char == "O"
]


SCREEN_SIZE_V = CELL_COUNT_V * CELL_SIZE + 2 * MARGIN
SCREEN_SIZE_H = CELL_COUNT_H * CELL_SIZE + 2 * MARGIN

print(f'Loaded config: \n\
        Max generations: {MAX_GENERATIONS}\n\
        Screen size:\t {SCREEN_SIZE_H}x{SCREEN_SIZE_V}\n\
        Cell count:\t {CELL_COUNT_V}x{CELL_COUNT_H} \n\
        Cell size:\t {CELL_SIZE} \n\
        Margin:\t\t {MARGIN} \n\
        Pattern start:\t ({PATTERN_ORIGIN_X},{PATTERN_ORIGIN_Y})\n\
        Starter origin:\t {START_CELLS} \n\
      ')

grid = [[False for _ in range(CELL_COUNT_H)] for _ in range(CELL_COUNT_V)]
for cell in START_CELLS:
  grid[cell[1] + PATTERN_ORIGIN_Y][cell[0] + PATTERN_ORIGIN_X] = True



alive_count = 0
def updateGrid():
  grid_next = [[False for _ in range(CELL_COUNT_H)] for _ in range(CELL_COUNT_V)]
  global alive_count
  alive_count = 0
  for y in range(CELL_COUNT_V):
    for x in range(CELL_COUNT_H):
      neighbours = 0
      for dy in range(-1,2):
        for dx in range(-1,2):
          if (dx == 0 and dy == 0):
            continue
          ypos = y + dy
          xpos = x + dx
          if (0 <= ypos < CELL_COUNT_V) and (0 <= xpos < CELL_COUNT_H) and grid[ypos][xpos]:            
            neighbours += 1
      if (grid[y][x] and (neighbours == 2 or neighbours == 3)) or (not grid[y][x] and neighbours == 3):
        grid_next[y][x] = True
        alive_count +=1
      else:
        grid_next[y][x] = False

  grid[:] = grid_next



generation = 0


set_trace_log_level(TraceLogLevel.LOG_ERROR)
# set_config_flags(FLAG_WINDOW_HIGHDPI);
# set_config_flags(FLAG_WINDOW_UNDECORATED);
# set_config_flags(FLAG_BORDERLESS_WINDOWED_MODE);

# set_target_fps(60)
init_window(SCREEN_SIZE_V, SCREEN_SIZE_H - 24, "Game Of Life in Python")

while not window_should_close() and generation < MAX_GENERATIONS:
  begin_drawing()
  clear_background(BLACK)
  draw_fps(SCREEN_SIZE_H - 100, 10)
  draw_text(f"Generation:\t{generation}"  , 10, 10, 25, WHITE)
  draw_text(f"Alive count:\t{alive_count}", 10, 40, 25, WHITE)

  
  for y in range(CELL_COUNT_V):
    for x in range(CELL_COUNT_H):
      if grid[y][x]:
        draw_rectangle(x * CELL_SIZE + MARGIN,y * CELL_SIZE + MARGIN,CELL_SIZE,CELL_SIZE,WHITE)
  
  # if not is_key_down(KEY_SPACE):
  updateGrid()
  generation += 1
  end_drawing()
close_window()



