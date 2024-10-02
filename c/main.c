#include <raylib.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct CoordTupple {
  int x;
  int y;
} CoordTupple;

typedef struct Config {
  int SCREEN_SIZE_H;
  int SCREEN_SIZE_V;
  int CELL_COUNT_H;
  int CELL_COUNT_V;  
  int CELL_SIZE;
  int MARGIN;
  int PATTERN_ORIGIN_X;
  int PATTERN_ORIGIN_Y;
  int MAX_GENERATIONS;
  CoordTupple* START_CELLS;
  int START_CELL_COUNT;
} Config;


bool* gridCurrent;
bool* gridNext;
int aliveCount = 0;

Config loadConfig(){
  char inputBuffer[1000];
  int conf[7];
  CoordTupple* startCells = (CoordTupple*) malloc(1000 * sizeof(CoordTupple));
  int startCellsIndex = 0;

  int offset = 0;
  int index = 0;
  while(fgets(inputBuffer, sizeof(inputBuffer), stdin) != NULL){
    // printf("%s", inputBuffer);

    if(index++ < 4){
      char* tok = strtok(inputBuffer, " ");
      while(tok != NULL) {
        conf[offset++] = atoi(inputBuffer); 
        tok = strtok(NULL, " ");
        // printf("=>%s %d \n", inputBuffer, index);
      } 
    }else{
      int y = index - 5;
      int x = 0;
      char chr;
      while((chr = inputBuffer[x]) != EOF){
        if(chr == 'O'){
          startCells[startCellsIndex++] = (CoordTupple) {
            .x = x,
            .y = y
          };
        }
        x++;
      }
    }
  }

  Config config = (Config) {
    .MAX_GENERATIONS = conf[0],
    .CELL_COUNT_H = conf[1],
    .CELL_COUNT_V = conf[2],
    .CELL_SIZE = conf[3],
    .MARGIN = conf[4],
    .PATTERN_ORIGIN_X = conf[5],
    .PATTERN_ORIGIN_Y = conf[6],
    .START_CELLS = startCells, 
    .START_CELL_COUNT = startCellsIndex - 1
  };

  config.SCREEN_SIZE_H = config.CELL_COUNT_H * config.CELL_SIZE + 2 * config.MARGIN;
  config.SCREEN_SIZE_V = config.CELL_COUNT_V * config.CELL_SIZE + 2 * config.MARGIN;
  return config;
}

void updateGrid(Config config){
  aliveCount = 0;
  for(int y = 0; y < config.CELL_COUNT_V; y++){
    for(int x = 0; x < config.CELL_COUNT_H; x++){
      int neighbours = 0;
      for(int dy = -1; dy <= 1; dy++){
        for(int dx = -1; dx <= 1; dx++){
          if(dy == 0 && dx == 0) continue;
          int yPos = y + dy;
          int xPos = x + dx;
          if((yPos >= 0 && yPos < config.CELL_COUNT_V) && 
             (xPos >= 0 && xPos < config.CELL_COUNT_H) && 
              gridCurrent[yPos * config.CELL_COUNT_H + xPos] == true){
            neighbours++;
          }
        }
      }

      int flatPos = y * config.CELL_COUNT_H + x;
      if(gridCurrent[flatPos] == true  && (neighbours == 2 || neighbours == 3) || 
         gridCurrent[flatPos] == false &&  neighbours == 3 ){
        gridNext[flatPos] = true;
        aliveCount++;
      }else{
        gridNext[flatPos] = false;
      }
    }
  }
  bool* temp = gridCurrent;
  gridCurrent = gridNext;
  gridNext = temp;
  memset(gridNext, 0, config.CELL_COUNT_V * config.CELL_COUNT_H * sizeof(bool));
} 

int main(){
  Config config = loadConfig();

  printf("Loaded config: \n");
  printf("\tMax generations: %d\n", config.MAX_GENERATIONS);
  printf("\tScreen size:\t %dx%d\n", config.SCREEN_SIZE_H, config.SCREEN_SIZE_V);
  printf("\tCell count:\t %dx%d\n", config.CELL_COUNT_H, config.CELL_COUNT_V);
  printf("\tCell size:\t %d\n", config.CELL_SIZE);
  printf("\tMargin:\t\t %d\n", config.MARGIN);
  printf("\tPattern origin:\t (%d,%d)\n", config.PATTERN_ORIGIN_X, config.PATTERN_ORIGIN_Y);
  printf("\tStarter cells:\t [");
  for(int i = 0; i < config.START_CELL_COUNT; i++){
    printf("(%d, %d)", config.START_CELLS[i].x, config.START_CELLS[i].y);
    if((i + 1) != config.START_CELL_COUNT){
      printf(", ");
    }
  }
  printf("]\n");


  int totalGridsize = config.CELL_COUNT_H * config.CELL_COUNT_V;

  gridCurrent = (bool*) malloc( totalGridsize * sizeof(bool));
  gridNext = (bool*) malloc( totalGridsize * sizeof(bool));

  for(int i = 0; i < config.START_CELL_COUNT; i++){
    CoordTupple cell = config.START_CELLS[i];
    gridCurrent[(cell.y + config.PATTERN_ORIGIN_Y) * config.CELL_COUNT_H + (cell.x + config.PATTERN_ORIGIN_X)] = true;
  }

  // SetTargetFPS(30);
  SetTraceLogLevel(LOG_ERROR);
  InitWindow(config.SCREEN_SIZE_V, config.SCREEN_SIZE_H - 24, "Game Of Life in C");

  int generation = 0;
  while(!WindowShouldClose() && generation < config.MAX_GENERATIONS){
    BeginDrawing();
    ClearBackground(BLACK);
    DrawFPS(config.SCREEN_SIZE_H - 100, 10);
    DrawText(TextFormat("Generation:\t%d", generation) , 10, 10, 25, WHITE);
    DrawText(TextFormat("Alive count:\t%d", aliveCount), 10, 40, 25, WHITE);

    for(int y = 0; y < config.CELL_COUNT_V; y++){
      for(int x = 0; x < config.CELL_COUNT_V; x++){
        if(gridCurrent[y * config.CELL_COUNT_H + x]){
          DrawRectangle(x * config.CELL_SIZE + config.MARGIN, y * config.CELL_SIZE + config.MARGIN, config.CELL_SIZE, config.CELL_SIZE, WHITE); 
        }
      }
    }
    // if(IsKeyDown(KEY_SPACE)){
      updateGrid(config);
      generation++;
    // }
    EndDrawing();
  }
  CloseWindow();
  return 0;  
}
