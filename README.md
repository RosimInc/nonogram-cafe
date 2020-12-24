# RosimInc's SteamGifts Nonogram Generator


## Getting Started


### Prerequisites

Download [Processing](https://processing.org/) (version 3.5.3 or above recommended)

From Processing's [Contribution Manager](https://i.imgur.com/e9L3Bxy.png), install the ***Zxing For Processing (QRCode lib)*** library


### Installing

- Clone this repository (or download the files) to your machine

`git clone https://github.com/RosimInc/nonogram-cafe.git`


### Executing the application

- Open the `NonogramCafe.pde` file from Processing.
- Launch the Nonogram Generator using the `Run` button
- The generated nonogram will be shown on screen
- In the `output` folder, a .png file will have been created as well


## Usage

Here are the options available to generate the nonograms.


### Generating custom nonograms

The section `Nonogram configuration` of the code allows to customize the nonogram that is being generated.

- `giveawayCode`: The 5-character code of the giveaway
- `fileName`: The name of the file that will be exported
- `numCols`: The width of the nonogram, in number of cells
- `numRows`: The height of the nonogram, in number of cells
- `xOffset`: The starting X position of the nonogram
- `yOffset`: The starting Y position of the nonogram

![Demonstrating nonogram configuration](https://i.imgur.com/bQh7IbB.png)

### Debugging options

In case you need more options, there are additional variables that can be changed under `Debug tools`.

- `usePlainText`: The `giveawayCode` variable will be used as-is, without being encrypted. It allows for longer texts or full links.
- `showSolution`: Instead of leaving the QR code with a hole for the nonogram, the solution will be shown. This may help 


## Full Process

Here's how you may easily use this tool to generate puzzles around your giveaways.


### Giveaway creation

- On SteamGifts, create your giveaway.
- Note down the 5-character code of the giveaway (e.g. `https://www.steamgifts.com/giveaway/XXXXX/`)


### Nonogram creation

- Enter the 5-digit code of the gift
- Enter the size of the nonogram
- Enter an offset for the nonogram


### Nonogram testing

- Run the application and test the nonogram on Paint
- Make sure there is only one possible solution
- If there isn't, you can either
    - Change the offset/size to try another puzzle
    - Mark one cell manually as black or white to give a hint that will ensure the unicity of the puzzle
- Keep trying until you get a puzzle you're satisfied with


### Puzzle upload

- The image is generated as a file or can just be screenshotted and sent to a hosting service of your choice
- Greenshot can send screenshots directly to Imgur and makes for an easy way to upload the puzzles
  

### Notes

- The same configuration will always generate the same QR code and nonogram, so don't be afraid to lose it.


## Author

- RosimInc (`rosiminc7@gmail.com`)


## License

This project is licensed under the MIT License - see the LICENSE.md file for details
