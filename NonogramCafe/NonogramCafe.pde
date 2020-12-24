import com.cage.zxing4p3.*;

// Nonogram configuration
private final String giveawayCode = "4Test"; // Giveaway code or text to cipher
private final String fileName = "Nono_01"; // Name of the file to export
private final int numCols = 10; // Width of the puzzle
private final int numRows = 15; // Height of the puzzle
private final int xOffset = 9; // Leftmost X coordinate
private final int yOffset = 8; // Topmost Y coordinate

// Debug tools
private final boolean usePlainText = false; // Disable code encryption
private final boolean showSolution = false; // Disable solution masking

// Visual constants
private final int cellSize = 16; // Length and height of every square cell
private final int hintOffset = 4; // Spacing between hints and nonogram

private final color[] gridColors = { // Background color of the cells
  color(200,255,165),  // Yellow 1
  color(200,215,165),  // Yellow 2
  color(165,255,200),  // Green 1
  color(165,215,200)   // Green 2
};

private final color[] hintColors = { // Background color of the hints
  color(230,230,230),  // Gray 1
  color(200,200,200)   // Gray 2
};

// Logical constants
private final int qrDimension = 50; // Maximum size of a generated QR (will be trimmed)

// Encryption cipher
private final String[] numbersMap = {"Zero", "One", "Two", "Three", "Four", "Five", "Six", "Seven", "Eight", "Nine" };
private final String[] lettersMap = {"Alfa", "Bravo", "Charlie", "Delta", "Echo", "Foxtrot", "Golf", "Hotel", "India", 
                          "Juliet", "Kilo", "Lima", "Mike", "November", "Oscar", "Papa", "Quebec", "Romeo", 
                          "Sierra", "Tango", "Uniform", "Victor", "Whiskey", "X-ray", "Yankee", "Zulu" };

// Global variables
private String encryptedCode; // Giveaway code once encrypted
private int qrCodeSize; // Size of the QR code once trimmed
private int[][] qrCode; // Full QR code, 0 for white, 1 for black
private int[][] nonogram; // Nonogram, 0 for white, 1 for black
private int[][] horHints; // Horizontal hints
private int[][] verHints; // Vertical hints
private int maxHorHints; // Max number of horizontal hints to compute size
private int maxVerHints; // Max number of vertical hints to compute size

// Preparing the QR code and nonogram
public void setup() {
  size(600, 400);
  surface.setResizable(true);
  
  generateEncryptedCode();
  generateQRCode();
  generateNonogram();
  
  changeWindowSize();
}

// Drawing the QR code and nonogram
public void draw() {
  
  background(255);
  
  // Skip the 1st frame to allow picture loading time
  if(frameCount == 1) return;
  
  noLoop();
  
  drawQRSection();
  drawNonogramSection();
  exportFile();
}

// Encrypt the giveaway code if needed
private void generateEncryptedCode() {
  if(usePlainText)
    encryptedCode = giveawayCode;
  else
    encryptedCode = encryptString(giveawayCode);
}

// Encrypt a giveaway code
private String encryptString(String code) {
  String encrypted = "";
  
  for(int i = 0; i < code.length(); i++)
    encrypted += (i > 0 ? " " : "") + encryptChar(code.charAt(i));
    
  return encrypted;
}

// Encrypt a single character with a word
private String encryptChar(char character) {
  if(character >= '0' && character <= '9')
    return "#" + numbersMap[(int)(character - '0')];
    
  if(character >= 'a' && character <= 'z')
    return lettersMap[(int)(character - 'a')].toLowerCase();
    
  if(character >= 'A' && character <= 'Z')
    return lettersMap[(int)(character - 'A')].toUpperCase();
    
  return character + "";
}

// Generate the QR code and extract the data in a grid
private void generateQRCode() {
  // Generate the QR code into an image
  ZXING4P qrGenerator = new ZXING4P();
  PImage qrCodeImg = qrGenerator.generateQRCode(encryptedCode, qrDimension, qrDimension);
  qrCodeImg.loadPixels();
  
  int trimTopLeft = 0;
  int trimBottomRight = qrCodeImg.width-1;
  
  // Trim the top-left empty space
  while(red(qrCodeImg.get(trimTopLeft, trimTopLeft)) > 128)
    trimTopLeft++;
    
  // Trim the bottom-right empty space
  while(red(qrCodeImg.get(trimTopLeft, trimBottomRight)) > 128)
    trimBottomRight--;
  
  // Compute the QR size
  qrCodeSize = trimBottomRight + 1 - trimTopLeft;
  
  // Construct the grid
  qrCode = new int[qrCodeSize][qrCodeSize];
  for(int row = 0; row < qrCodeSize; row++) {
    for(int col = 0; col < qrCodeSize; col++) {
      qrCode[row][col] = red(qrCodeImg.get(col + trimTopLeft, row + trimTopLeft)) > 128 ? 0 : 1;
    }
  }
}

// Generate the nonogram hints from the QR code subsection
private void generateNonogram() {
  generateNonogramGrid();
  generateHorizontalHints();
  generateVerticalHints();
}

// Extract the nonogram section into the grid
private void generateNonogramGrid() {
  nonogram = new int[numRows][numCols];
  for(int row = 0; row < numRows; row++) {
    for(int col = 0; col < numCols; col++) {
      nonogram[row][col] = qrCode[row + yOffset][col + xOffset];
    }
  }
}

// Compute the horizontal hints of the nonogram
private void generateHorizontalHints() {
  horHints = new int[numRows][];
  maxHorHints = 0;
  
  for(int row = 0; row < numRows; row++) {
    int[] hints = new int[(numCols + 1)/2];
    int numHints = 0;
    int cellCount = 0;
    
    // Go through the column
    for(int col = 0; col < numCols; col++) {
      // If there is a group of black cells, increment
      if(nonogram[row][col] == 1) {
        cellCount++;
      } 
      // Otherwise if a cell group is over
      else if(cellCount > 0) {
        hints[numHints++] = cellCount;
        cellCount = 0;
      }
    }
    
    // Add the last group if necessary
    if(cellCount > 0) {
      hints[numHints++] = cellCount;
    }
    
    // An empty row will have a hint of zero
    if(numHints == 0) {
      numHints = 1;
      hints[0] = 0;
    }
    
    // Transfer the hints to a properly sized array
    horHints[row] = new int[numHints];
    for(int i = 0; i < numHints; i++) {
      horHints[row][i] = hints[i];
    }
    
    // Hold the size of the biggest array
    if(numHints > maxHorHints) {
      maxHorHints = numHints;
    }
  }
}

// Compute the vertical hints of the nonogram
private void generateVerticalHints() {
  verHints = new int[numCols][];
  
    for(int col = 0; col < numCols; col++) {
    int[] hints = new int[(numRows + 1)/2];
    int numHints = 0;
    int cellCount = 0;
    
    // Go through the row
    for(int row = 0; row < numRows; row++) {
      // If there is a group of black cells, increment
      if(nonogram[row][col] == 1) {
        cellCount++;
      } 
      // Otherwise if a cell group is over
      else if(cellCount > 0) {
        hints[numHints++] = cellCount;
        cellCount = 0;
      }
    }
    
    // Add the last group if necessary
    if(cellCount > 0) {
      hints[numHints++] = cellCount;
    }
    
    // An empty column will have a hint of zero
    if(numHints == 0) {
      numHints = 1;
      hints[0] = 0;
    }
    
    // Transfer the hints to a properly sized array
    verHints[col] = new int[numHints];
    for(int i = 0; i < numHints; i++) {
      verHints[col][i] = hints[i];
    }
    
    // Hold the size of the biggest array
    if(numHints > maxVerHints) {
      maxVerHints = numHints;
    }
  }
}

// Resize the window to match the size of the content
private void changeWindowSize() {
  surface.setSize((qrCodeSize + 3 + numCols + maxHorHints) * cellSize + hintOffset,
    max((qrCodeSize + 2) * cellSize, (numRows + 2 + maxVerHints) * cellSize + hintOffset));
}

// Draw the full QR code section
private void drawQRSection() {
  translate(cellSize, cellSize);
  
  for(int row = 0; row < qrCodeSize; row++) {
    for(int col = 0; col < qrCodeSize; col++) {
      noStroke();
      fill(255 * (1 - qrCode[row][col]));
      rect(col * cellSize, row * cellSize, cellSize, cellSize);
    }
  }
  
  // Mask solving section
  if(!showSolution) {
    fill(255);
    rect(xOffset * cellSize, yOffset * cellSize, numCols * cellSize, numRows * cellSize);
  }
  
  // Tint solving section
  fill(210, 210, 210, 100);
  rect(xOffset * cellSize, yOffset * cellSize, numCols * cellSize, numRows * cellSize);
  
  // Drawing an inset contour
  stroke(100, 100, 100, 100);
  line(xOffset * cellSize, yOffset * cellSize, (xOffset + numCols) * cellSize - 1, yOffset * cellSize);
  line(xOffset * cellSize, yOffset * cellSize, xOffset * cellSize, (yOffset + numRows) * cellSize - 1);
  stroke(200, 200, 200, 100);
  line((xOffset + numCols) * cellSize - 1, yOffset * cellSize, (xOffset + numCols) * cellSize - 1, (yOffset + numRows) * cellSize - 1);
  line(xOffset * cellSize, (yOffset + numRows) * cellSize - 1, (xOffset + numCols) * cellSize - 1, (yOffset + numRows) * cellSize - 1);
}

// Draw the full nonogram section
private void drawNonogramSection() {
  translate((qrCodeSize + 1 + maxHorHints) * cellSize + hintOffset, maxVerHints * cellSize + hintOffset);
  
  drawNonogram();
  drawHorizontalHints();
  drawVerticalHints();
}

// Draw the nonogram grid
private void drawNonogram() {
  for(int row = 0; row < numRows; row++) {
    for(int col = 0; col < numCols; col++) {
      noStroke();
      fill(gridColors[2 * ((row/5 + col/5) % 2) + (row + col) % 2]);
      rect(col*cellSize, row*cellSize, cellSize+1, cellSize+1);
      
      // Draw the contour
      strokeWeight(1);
      stroke(0,0,0, 50);
      rect(col * cellSize, row * cellSize, cellSize, cellSize);
    }
  }
}

// Draw the vertical hints
private void drawHorizontalHints() {
  for(int row = 0; row < numRows; row++) {
    int numHints = horHints[row].length;
    
    for(int i = 0; i < numHints; i++) {
      int hint = horHints[row][i];
      
      // Draw the hint box
      noStroke();
      fill(hintColors[((numHints - 1 - i) % 2 + row) % 2]);
      rect((i - numHints) * cellSize - hintOffset, row * cellSize, cellSize, cellSize);
      
      // Draw the hint text
      fill(0);
      textSize(cellSize - 1 + (hint >= 10 ? -4 : 0));
      textAlign(CENTER, CENTER);
      text(hint, -(numHints - i - 0.5) * cellSize - hintOffset, (row + 0.5f) * cellSize - 2);
      
      // Draw the contour
      strokeWeight(1);
      stroke(0, 0, 0, 50);
      noFill();
      rect((i - numHints) * cellSize - hintOffset, row * cellSize, cellSize, cellSize);
    }
  }
}

// Draw the vertical hints
private void drawVerticalHints() {
  for(int col = 0; col < numCols; col++) {
    int numHints = verHints[col].length;
    
    for(int i = 0; i < numHints; i++) {
      int hint = verHints[col][i];
      
      // Draw the hint box
      noStroke();
      fill(hintColors[((numHints - 1 - i) % 2 + col) % 2]);
      rect(col * cellSize, (i - numHints) * cellSize - hintOffset, cellSize, cellSize);
      
      // Draw the hint text
      fill(0);
      textSize(cellSize - 1 + (hint >= 10 ? -4 : 0));
      textAlign(CENTER, CENTER);
      text(hint, (col + 0.5f) * cellSize + 1, -(numHints - i - 0.5) * cellSize - hintOffset - 2);
      
      // Draw the contour
      strokeWeight(1);
      stroke(0, 0, 0, 50);
      noFill();
      rect(col * cellSize, (i - numHints) * cellSize - hintOffset, cellSize, cellSize);
    }
  }
}

// Save the puzzle into a PNG image
private void exportFile() {
  save(String.format("output/%s.png", fileName));
}
