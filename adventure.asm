; adventure.asm - Enhanced simple text-based adventure game for DOS
; nasm -f bin -o adventure.com adventure.asm

org 100h

section .data
    welcome_msg db 'Welcome to the Adventure Game!', 0x0D, 0x0A, '$'
    instructions db 'Type "n" for North, "s" for South, "e" for East, "w" for West, "i" for Inventory, "h" for Health, "x" to Exit.', 0x0D, 0x0A, '$'
    invalid_msg db 'Invalid command. Please try again.', 0x0D, 0x0A, '$'
    north_msg db 'You move North.', 0x0D, 0x0A, '$'
    south_msg db 'You move South.', 0x0D, 0x0A, '$'
    east_msg db 'You move East.', 0x0D, 0x0A, '$'
    west_msg db 'You move West.', 0x0D, 0x0A, '$'
    current_location_msg db 'Current location: (', '$'
    location_suffix db ')', 0x0D, 0x0A, '$'
    inventory_msg db 'Inventory:', 0x0D, 0x0A, '$'
    empty_inventory_msg db 'Your inventory is empty.', 0x0D, 0x0A, '$'
    item_collected_msg db 'You found an item!', 0x0D, 0x0A, '$'
    health_pack_msg db 'You found a health pack!', 0x0D, 0x0A, '$'
    enemy_encounter_msg db 'You encounter an enemy! Lose 10 health.', 0x0D, 0x0A, '$'
    game_over_msg db 'Game Over. You have died.', 0x0D, 0x0A, '$'
    health_msg db 'Health: ', '$'
    points_msg db 'Points: ', '$'
    exit_msg db 'Exiting the game. Goodbye!', 0x0D, 0x0A, '$'
    location_descriptions db 'A dark forest.', 0x0D, 0x0A, '$', 'A sunny meadow.', 0x0D, 0x0A, '$', 'A quiet village.', 0x0D, 0x0A, '$'
    found_item_gold_msg db 'You found a gold item! It is worth 50 points.', 0x0A, 0x0D, '$'
    found_item_silver_msg db 'You found a silver item! It is worth 30 points.', 0x0A, 0x0D, '$'
    found_item_bronze_msg db 'You found a bronze item! It is worth 10 points.', 0x0A, 0x0D, '$'
    encounter_strong_enemy_msg db 'You encounter a strong enemy! Lose 20 health.', 0x0A, 0x0D, '$'


section .bss
    command resb 1
    player_x resb 1
    player_y resb 1
    items resb 10
    points resw 1
    health resw 1

section .text
    global _start

_start:
    ; Initialize video mode to 80x25 text mode
    mov ax, 0x03  ; Text mode
    int 0x10      ; BIOS video interrupt
    mov dx, welcome_msg
    call print_string
    mov dx, instructions
    call print_string

    ; Initialize player position to the center of a 10x10 grid
    mov byte [player_x], 5
    mov byte [player_y], 5

    ; Initialize points and health
    mov word [points], 0
    mov word [health], 100

game_loop:
    ; Get user command
    call get_command

    ; Process command
    mov al, [command]
    cmp al, 'n'
    je move_north
    cmp al, 's'
    je move_south
    cmp al, 'e'
    je move_east
    cmp al, 'w'
    je move_west
    cmp al, 'i'
    je show_inventory
    cmp al, 'h'
    je show_health
    cmp al, 'x'
    je exit_game

    ; Invalid command
    mov dx, invalid_msg
    call print_string
    jmp game_loop

move_north:
    cmp byte [player_y], 0  
    je game_loop           
    dec byte [player_y]     
    mov dx, north_msg
    call print_string
    call update_location
    jmp game_loop

move_south:
    cmp byte [player_y], 9 
    je game_loop            
    inc byte [player_y]    
    mov dx, south_msg
    call print_string
    call update_location
    jmp game_loop

move_east:
    cmp byte [player_x], 9 
    je game_loop           
    inc byte [player_x]  
    mov dx, east_msg
    call print_string
    call update_location
    jmp game_loop

move_west:
    cmp byte [player_x], 0 
    je game_loop           
    dec byte [player_x]   
    mov dx, west_msg
    call print_string
    call update_location
    jmp game_loop

show_inventory:
    mov dx, inventory_msg
    call print_string
    mov si, items
    mov cx, 10
    mov bx, 0
    mov dl, '1'
check_inventory:
    cmp byte [si], 0
    je empty_check
    mov ah, 02h
    int 21h
    mov dl, ':'
    int 21h
    mov dl, ' '
    int 21h
    inc dl
    inc bx
    cmp bx, 10
    je done_check
    jmp next_item
empty_check:
    cmp bx, 0
    jne next_item
    mov dx, empty_inventory_msg
    call print_string
done_check:
    jmp game_loop
next_item:
    inc si
    loop check_inventory

show_health:
    mov dx, health_msg
    call print_string
    mov ax, [health]
    call print_number
    jmp game_loop

print_string:
    mov ah, 09h
    int 21h
    ret

get_command:
    mov ah, 01h
    int 21h
    mov [command], al
    ret

update_location:
    mov dx, current_location_msg
    call print_string
    mov al, [player_x]
    call print_digit
    mov dl, ','
    mov ah, 02h
    int 21h
    mov dl, ' '
    int 21h
    mov al, [player_y]
    call print_digit
    mov dx, location_suffix
    call print_string

    ; Show location description
    mov bx, 30
    mov al, [player_x]
    mul byte [player_y]
    add bx, ax
    mov si, location_descriptions
    add si, bx
    mov dx, si
    call print_string

    ; Check for item or enemy at location
    call check_for_item_or_enemy
    ret

check_for_item_or_enemy:
    ; 10% chance of finding an item, 10% chance of finding a health pack,
    ; 10% chance of encountering an enemy, 10% chance of encountering a stronger enemy.
    in al, 0x40
    and al, 0Fh
    cmp al, 1
    je found_item
    cmp al, 2
    je found_health_pack
    cmp al, 3
    je encounter_enemy
    cmp al, 4
    je encounter_strong_enemy
    jmp no_event

found_item:
    ; Enhanced with different types of items
    in al, 0x40
    and al, 03h
    cmp al, 0
    je found_item_gold
    cmp al, 1
    je found_item_silver
    cmp al, 2
    je found_item_bronze
    jmp no_event

found_item_gold:
    mov dx, found_item_gold_msg
    call print_string
    add word [points], 50
    jmp store_item_generic

found_item_silver:
    mov dx, found_item_silver_msg
    call print_string
    add word [points], 30
    jmp store_item_generic

found_item_bronze:
    mov dx, found_item_bronze_msg
    call print_string
    add word [points], 10
    jmp store_item_generic

store_item_generic:
    mov si, items
    mov cx, 10
find_empty_slot_generic:
    cmp byte [si], 0
    je store_item_final
    inc si
    loop find_empty_slot_generic
    jmp no_event
store_item_final:
    mov byte [si], 1
    jmp no_event
find_empty_slot:
    cmp byte [si], 0
    je store_item
    inc si
    loop find_empty_slot
    jmp no_event
store_item:
    mov byte [si], 1
    ; Increase points
    add word [points], 10
    mov dx, points_msg
    call print_string
    mov ax, [points]
    call print_number
    jmp no_event

found_health_pack:
    mov dx, health_pack_msg
    call print_string
    ; Increase health
    add word [health], 20
    cmp word [health], 100
    jle no_event
    mov word [health], 100 ; Cap health at 100
    jmp no_event

encounter_enemy:
    mov dx, enemy_encounter_msg
    call print_string
    ; Decrease health
    sub word [health], 10
    call check_health
    jmp no_event

encounter_strong_enemy:
    mov dx, encounter_strong_enemy_msg
    call print_string
    ; Decrease health significantly
    sub word [health], 20
    call check_health
    jmp no_event

check_health:
    cmp word [health], 0
    jg no_event
    mov dx, game_over_msg
    call print_string
    jmp exit_game

no_event:
    ret

print_digit:
    add al, '0'  ; Convert number to ASCII character
    mov dl, al
    mov ah, 02h
    int 21h
    ret

print_number:
    ; Print number in ax as decimal
    push ax
    mov cx, 10
    xor dx, dx
    div cx
    add dl, '0'
    push dx
    xor dx, dx
    div cx
    add dl, '0'
    mov ah, 02h
    pop dx
    int 21h
    mov dl, al
    int 21h
    pop ax
    ret

exit_game:
    mov dx, exit_msg
    call print_string
    mov ax, 4C00h
    int 21h
    ret
