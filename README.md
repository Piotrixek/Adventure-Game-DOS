# Adventure-Game-DOS

A simple text-based adventure game for DOS, written in x86 Assembly language. Navigate through a grid, collect items, encounter enemies, and manage your health as you explore the world.

## Features
- **Grid Navigation:** Move North, South, East, and West within a 10x10 grid.
- **Items Collection:** Discover different types of items (gold, silver, bronze) and collect them to earn points.
- **Health Management:** Keep track of your health. Find health packs to restore health or encounter enemies that reduce your health.
- **Scoring System:** Earn points by collecting items. The game displays your current score and health.
- **Inventory Display:** Check your inventory to see the items you've collected.
- **Game Over Condition:** The game ends if your health reaches zero.

## Controls
- **n:** Move North
- **s:** Move South
- **e:** Move East
- **w:** Move West
- **i:** Show Inventory
- **h:** Show Health
- **x:** Exit Game

## Getting Started

### Prerequisites
To run this game, you will need an x86 emulator like DOSBox.

### Running the Game
1. **Assemble the code:**
    ```sh
    nasm -f bin -o adventure.com adventure.asm
    ```

2. **Run the game in DOSBox:**
    ```sh
    dosbox adventure.com
    ```

## Code Overview

The game is implemented in x86 Assembly language and consists of several key sections:

- **Data Section:** Contains the messages and item descriptions.
- **BSS Section:** Defines the uninitialized variables.
- **Text Section:** Contains the main game logic, including movement, item collection, health management, and event handling.

### Key Functions

- **game_loop:** Main loop of the game to process user commands.
- **move_*:** Functions to handle player movement in different directions.
- **show_inventory:** Displays the player's inventory.
- **show_health:** Displays the player's current health.
- **update_location:** Updates and displays the player's current location.
- **check_for_item_or_enemy:** Randomly determines if the player finds an item, health pack, or encounters an enemy.
- **print_string:** Prints a string to the screen.
- **get_command:** Gets a command from the user.
- **print_digit / print_number:** Utility functions to print numbers to the screen.

## Contribution

Contributions are welcome! Please fork the repository and submit pull requests for any improvements or bug fixes.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
