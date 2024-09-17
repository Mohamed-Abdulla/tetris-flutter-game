import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:tetris/piece.dart';
import 'package:tetris/pixel.dart';
import 'package:tetris/value.dart';

/*
Game Board->  this is 2*2 grid with null representing empty space
a non empty space will have a color represent landed pieces

 */

List<List<Tetromino?>> gameBoard =
    List.generate(columnLength, (i) => List.generate(rowLength, (j) => null));

class GameBoard extends StatefulWidget {
  const GameBoard({super.key});

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> {
  Piece currentPiece = Piece(type: Tetromino.L);
  int currentScore = 0;
  bool gameOverStatus = false;
  @override
  void initState() {
    super.initState();
    startGame();
  }

  void startGame() {
    currentPiece.initializePiece();
    //frame rate for refresh
    Duration frameRate = const Duration(milliseconds: 400);
    gameLoop(frameRate);
  }

//check for collision detection
//return true if there is a collision

  bool checkCollision(Direction direction) {
    // loop through all direction index
    for (int i = 0; i < currentPiece.position.length; i++) {
      // calculate the index of the current piece
      int row = (currentPiece.position[i] / rowLength).floor();
      int col = (currentPiece.position[i] % rowLength);

      // directions
      if (direction == Direction.down) {
        row++;
      } else if (direction == Direction.right) {
        col++;
      } else if (direction == Direction.left) {
        col--;
      }

      // check for collisions with boundaries
      if (col < 0 || col >= rowLength || row >= columnLength) {
        return true;
      }

      // check for collisions with other landed pieces
      if (row >= 0 && gameBoard[row][col] != null) {
        return true;
      }
    }
    // if there is no collision return false
    return false;
  }

  void checkLanding() {
    //if going down is occupied
    if (checkCollision(Direction.down)) {
// mark the position occupied on the board
      for (int i = 0; i < currentPiece.position.length; i++) {
        //calculate row and col of current piece
        int row = (currentPiece.position[i] / rowLength).floor();
        int col = currentPiece.position[i] % rowLength;

        if (row >= 0 && col >= 0) {
          //mark the position as occupied\
          gameBoard[row][col] = currentPiece.type;
        }
      }
      //once landed, create a new piece
      createNewPiece();
    }
  }

  void gameLoop(Duration frameRate) {
    Timer.periodic(frameRate, (timer) {
      setState(() {
        //clear lines
        clearLines();
        checkLanding();

        //check if game is over
        if (gameOverStatus) {
          timer.cancel();
          showGameOverDialog();
        }
        //move the piece down
        currentPiece.movePiece(Direction.down);
      });
    });
  }

  void showGameOverDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Game Over'),
          content: Text('Your score is $currentScore'),
          actions: [
            TextButton(
              onPressed: () {
                resetGame();
                Navigator.of(context).pop();
              },
              child: const Text('Play Again'),
            ),
          ],
        );
      },
    );
  }

  void resetGame() {
    gameBoard = List.generate(
        columnLength, (i) => List.generate(rowLength, (j) => null));
    currentScore = 0;
    gameOverStatus = false;
    //create a new piece
    createNewPiece();
    //start the game
    startGame();
  }

  void createNewPiece() {
    //create a random  object to generate random tetromino types
    Random rand = Random();

    Tetromino randomType =
        Tetromino.values[rand.nextInt(Tetromino.values.length)];
    currentPiece = Piece(type: randomType);

    currentPiece.initializePiece();

    if (gameOver()) {
      gameOverStatus = true;
    }
  }

  void moveLeft() {
    if (!checkCollision(Direction.left)) {
      setState(() {
        currentPiece.movePiece(Direction.left);
      });
    }
  }

  void moveRight() {
    if (!checkCollision(Direction.right)) {
      setState(() {
        currentPiece.movePiece(Direction.right);
      });
    }
  }

  void moveRotate() {
    setState(() {
      currentPiece.rotatePiece();
    });
  }

//clear lines

  void clearLines() {
    // step 1: Loop through each row of the game board from bottom to top
    for (int row = columnLength - 1; row >= 0; row--) {
      // step 2: Initialize a variable to track if the row is full
      bool rowIsFull = true;
      // step 3: Check if the row if full (all columns in the row are filled with pieces)
      for (int col = 0; col < rowLength; col++) {
        // if there's an empty column, set rowisFull to false and break the loop
        if (gameBoard[row][col] == null) {
          rowIsFull = false;
          break;
        }
      }

      // step 4: If the row is full, clear the row and move all rows above it down by one
      if (rowIsFull) {
        for (int r = row; r > 0; r--) {
          gameBoard[r] = List.from(gameBoard[r - 1]);
        }

        gameBoard[0] = List.generate(row, (i) => null);

        currentScore++;
      }
    }
  }

  bool gameOver() {
    for (int col = 0; col < rowLength; col++) {
      if (gameBoard[0][col] != null) {
        //game over
        //clear the game board
        gameBoard = List.generate(
            columnLength, (i) => List.generate(rowLength, (j) => null));
        //reset the score
        currentScore = 0;
        return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: rowLength),
              itemCount: rowLength * columnLength,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (BuildContext context, int index) {
                int row = (index / rowLength).floor();
                int col = index % rowLength;
                if (currentPiece.position.contains(index)) {
                  return Pixel(
                    color: currentPiece.color,
                  );
                }

                //landed pieces
                else if (gameBoard[row][col] != null) {
                  final Tetromino? tetrominoType = gameBoard[row][col];
                  return Pixel(
                    color: tetrominoColors[tetrominoType!]!,
                  );
                } else {
                  return Pixel(
                    color: Colors.grey[900]!,
                  );
                }
              },
            ),
          ),

          //game controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: moveLeft,
                child: const Icon(Icons.arrow_back),
              ),
              ElevatedButton(
                onPressed: moveRotate,
                child: const Icon(Icons.arrow_downward),
              ),
              ElevatedButton(
                onPressed: moveRight,
                child: const Icon(Icons.arrow_forward),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
