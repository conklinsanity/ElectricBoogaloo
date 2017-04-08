//
//  MazeGenerator.swift
//  SpaceRace
//
//  Created by Cade Conklin on 3/17/17.
//  Copyright © 2017 Cade Conklin. All rights reserved.
//

import Foundation
import UIKit
import GameplayKit
import SpriteKit

//
//  Maze.cpp
//  SpaceRace
//
//  Created by Cade Conklin on 3/21/17.
//  Copyright © 2017 Cade Conklin. All rights reserved.
//

#include <iostream>
#include <SFML/Graphics.hpp>
#include <stdlib.h>
#include <time.h>

using namespace std;
using namespace sf;

class board;

class cell {
    cell(int x, int y, int boardWidth, int boardHeight) //constructor
    int xPos //x position in grid
    int yPos //y position in grid
    void drawCell(RenderWindow& window) //draws the cell
    bool walls[4] //are there walls: top,right,bottom,left
    bool init //Has the cell been visited
    int cellSize
    bool isDrawn
    vector<int> neighbors // vector that holds the x and y coordinates of the cell's neighboring cells. the even elements are x values and the odd elements are y
}
cell::cell(int x, int y, int boardWidth, int boardHeight)
{
    xPos = x
    yPos = y
    isDrawn=false
    walls[0]=true //top
    walls[1]=true //right
    walls[2]=true //bottom
    walls[3]=true //left
    init = false //cell has not been visited by default
    if(boardWidth>boardHeight) //800 is width and height of my window
    {
        cellSize = 300 / boardWidth
    }
    else {
       cellSize = 300 / boardHeight
    }
    
}

void cell::drawCell(RenderWindow& window)
{
    if(init==true)
    {
        RectangleShape visited(Vector2f(cellSize,cellSize))      //colors the cells that have been visited
        visited.setPosition(100+(xPos*cellSize), 100+(yPos*cellSize))
        if((xPos == 0 and yPos==0) or (xPos==(800/cellSize)-1 and yPos==(800/cellSize)-1)) //this colors the start and finish squares blue. Only works on the finish square if the maze is square
        visited.setFillColor(Color(5, 88, 130))
        else  // this colors the rest of the squares green
        visited.setFillColor(Color(6, 130, 22))
        window.draw(visited)
    }
    if(walls[0]==true){
        sf::Vertex topLine[] = {                                                           // This block draws lines for the top, right, bottom, and left
            sf::Vertex(sf::Vector2f(100+(xPos*cellSize), 100+(yPos*cellSize))),             // 1___2
            sf::Vertex(sf::Vector2f(100+((xPos+1)*cellSize), 100+(yPos*cellSize)))          // |   |
        }                                                                            // |___|
        window.draw(topLine, 2, sf::Lines)                                                 // 4   3
    }
    
    if(walls[1]==true){
        sf::Vertex rightLine[] = {                                                          // 1 = 100+(xPos*cellSize), 100+(xPos*cellSize)           3 = 100+((xPos+1)*cellSize), 100+((yPos+1)*cellSize)
            sf::Vertex(sf::Vector2f(100+((xPos+1)*cellSize), 100+(yPos*cellSize))),         // 2 = 100+((xPos+1)*cellSize), 100+(yPos*cellSize)       4 = 100+(x*cellSize), 100+((yPos+1)*cellSize)
            sf::Vertex(sf::Vector2f(100+((xPos+1)*cellSize), 100+((yPos+1)*cellSize)))
        }
        window.draw(rightLine, 2, sf::Lines)
    }
    
    if(walls[2]==true){
        sf::Vertex bottomLine[] = {
            sf::Vertex(sf::Vector2f(100+((xPos+1)*cellSize), 100+((yPos+1)*cellSize))),
            sf::Vertex(sf::Vector2f(100+(xPos*cellSize), 100+((yPos+1)*cellSize)))
        }
        window.draw(bottomLine, 2, sf::Lines)
    }
    
    if(walls[3]==true){
        sf::Vertex leftLine[] = {
            sf::Vertex(sf::Vector2f(100+(xPos*cellSize), 100+((yPos+1)*cellSize))),
            sf::Vertex(sf::Vector2f(100+(xPos*cellSize), 100+(yPos*cellSize)))
        }
        window.draw(leftLine, 2, sf::Lines)
    }
    isDrawn=true
    
}


class board {
    public:
    board(RenderWindow& window, int width, int height)
    vector<vector<cell> > cells  // this is the two dimensional array for all the cells. (width by height)
    vector<cell> stackOfCells //this is the stack that we will push and pop cells off of until the whole grid is full
    int widthOfBoard
    int heightOfBoard
    void drawBoard(RenderWindow& window)
    void recursiveMaze(int currentX, int currentY, RenderWindow& window)
    void checkNeighbors(int x, int y) // checks the neighboring cells of cell[x][y] to see if they are empty
    void removeWall(int currX, int currY, int nextX, int nextY) //removes the wall between the current cell and the new cell
}

void board::drawBoard(RenderWindow& window)
{
    for(int i = 0; i<widthOfBoard; i++)
    {
        for(int j = 0; j<heightOfBoard; j++)
        {
            cells[i][j].drawCell(window)
            
        }
    }
}
board::board(RenderWindow& window, int width, int height)
{
    widthOfBoard=width
    heightOfBoard=height
    
    for(int i = 0; i<widthOfBoard; i++)
    {
        vector<cell> temp
        for(int j = 0; j<heightOfBoard; j++)
        {
            cell tempCell(i,j,widthOfBoard,heightOfBoard)
            temp.push_back(tempCell)
            
        }
        cells.push_back(temp)
    }
    stackOfCells.push_back(cells[0][0])
    recursiveMaze(1,1,window) //this is the cell the function starts on. Change this to make the maze more difficult
}


void board::checkNeighbors(int x, int y)
{
    cells[x][y].neighbors.clear() //resets the vector of neighbors
    //first part of the if statement checks to see if the cell is on the edge (there would be no neighbor to that side)
    //second part of the if statement checks to see if the cell has been visited
    if(y!=0 and cells[x][y-1].init==false) //is the top cell open?
    {
        cells[x][y].neighbors.push_back(x)
        cells[x][y].neighbors.push_back(y-1)
    }
    if(x!=(cells.size()-1) and cells[x+1][y].init==false) //is the right cell open?
    {
        cells[x][y].neighbors.push_back(x+1)
        cells[x][y].neighbors.push_back(y)
    }
    if(y!=(cells[0].size()-1) and cells[x][y+1].init==false) //is the bottom cell open?
    {
        cells[x][y].neighbors.push_back(x)
        cells[x][y].neighbors.push_back(y+1)
    }
    if(x!=0 and cells[x-1][y].init==false) //is the left cell open?
    {
        cells[x][y].neighbors.push_back(x-1)
        cells[x][y].neighbors.push_back(y)
    }
}

void board::removeWall(int currX, int currY, int nextX, int nextY)
{
    if(nextX==currX and nextY<currY) //next cell is above current cell
    {
        cells[currX][currY].walls[0]=false //top wall of current cell
        cells[nextX][nextY].walls[2]=false //bottom wall of next cell
    }
    else if(nextX>currX and nextY==currY) //next cell is to the right of current cell
    {
        cells[currX][currY].walls[1]=false //right wall of current cell
        cells[nextX][nextY].walls[3]=false //left wall of next cell
    }
    else if(nextX==currX and nextY>currY) //next cell is below current cell
    {
        cells[currX][currY].walls[2]=false //bottom wall of current cell
        cells[nextX][nextY].walls[0]=false //top wall of next cell
    }
    else if(nextX<currX and nextY==currY) //next cell is to the left of current cell
    {
        cells[currX][currY].walls[3]=false //left wall of current cell
        cells[nextX][nextY].walls[1]=false //right wall of next cell
    }
}

void board::recursiveMaze(int currentX, int currentY, RenderWindow& window){  //Main recursive function
    checkNeighbors(currentX,currentY);
    
    if(cells[currentX][currentY].neighbors.size()!=0)
    {
        int randCell = rand() % (cells[currentX][currentY].neighbors.size()/2); //picks a random neighbor of the current cell
        removeWall(currentX,currentY,cells[currentX][currentY].neighbors[randCell*2],cells[currentX][currentY].neighbors[randCell*2+1]);
        cells[currentX][currentY].init = true //sets cell as visited
        stackOfCells.push_back(cells[cells[currentX][currentY].neighbors[randCell*2]][cells[currentX][currentY].neighbors[randCell*2+1]])
        recursiveMaze(cells[currentX][currentY].neighbors[randCell*2],cells[currentX][currentY].neighbors[randCell*2+1],window) //re-calls recursiveMaze function with new cell
    }
        
    else if(cells[currentX][currentY].neighbors.size()==0 and stackOfCells.size()!=1)
    {
        cells[currentX][currentY].init = true; //sets cell as visited
        stackOfCells.pop_back()
        recursiveMaze(stackOfCells[stackOfCells.size()-1].xPos,stackOfCells[stackOfCells.size()-1].yPos, window)
        
        
    }
    
}

int main()
    {
        srand(time(NULL))
        int width
        int height
        cout << "Width: "
        cin >> width;
        cout << "Height: "
        cin >> height
        RenderWindow window (VideoMode(1000, 1000), "My window")
        board maze(window,width,height);
        while (window.isOpen())
        {
            Event event;
            while (window.pollEvent(event))
            {
                if (event.type == Event::Closed)
                window.close()
                
            }
            window.clear();
            maze.drawBoard(window)
            window.display()
        }
        
        
}
