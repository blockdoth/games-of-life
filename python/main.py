from pyray import *
import math


MARGIN = 10


config_file = open("../config", "r")

CELL_COUNT_V = config_file.
CELL_COUNT_H = 50

CELL_SIZE = math.floor((SCREEN_SIZE - 2 * MARGIN) / CELL_COUNT)  

init_window(SCREEN_SIZE, SCREEN_SIZE, "Game Of Life Python")


grid = [(False) for y in range(0, CELL_COUNT) for x in range(0, CELL_COUNT)]

print(grid)

while not window_should_close():
    begin_drawing()
    clear_background(BLACK)




    draw_text("Hello world", 190, 200, 20, RED)
    end_drawing()
close_window()
