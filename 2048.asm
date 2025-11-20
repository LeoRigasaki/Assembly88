%assign VIDEO_MEM 0xb800
%assign ROW_SIZE 160
%assign COL_SIZE 2

[org 0x0100]
start_game:
    ; Reset Score
    mov word [score], 0
    
    ; Reset Board
    mov cx, 16
    mov di, board
    xor al, al
    rep stosb
    
	jmp text

clsclr:
	push es 
	push ax 
	push cx
	push di
	mov ax, 0xb800
	mov es,ax
	xor di,di
	mov ax,0x720               ;Clear screen
	mov cx,2000
	cld
	rep stosw
	pop di 
	pop cx
	pop ax 
	pop es
	ret

	printstr:
		mov ah,0x13
		mov al,1			;The string to be printed my name Sohaib and the Value
		mov bh,0
		mov bl,5
		mov dx,0x0A20
		mov cx,10
		push cs
		pop es
		mov bp,str1
		int 0x10
	printstr2:
		mov ah,0x13
		mov al,1
		mov bh,0
		mov bl,3			;Roll no in purple
		mov dx,0x0B20
		mov cx,18
		push cs
		pop es
		mov bp,str0
		int 0x10
		ret
timer:
	mov ax,0xb800
	mov es , ax				;upper screen timer pst
	mov di,2
	mov dh,0x06
	mov dl,0x35
	mov bx,6
time:
	mov word [es:di],dx
		call delay			;delay of 5secs
		sub dl,0x01
		sub bx,1
		cmp bx,0
		jnz time
		ret
delay:
	mov bp,20
	mov si,20
back:
	dec bp
	jnz back
	dec si
	cmp si,0
	jnz back
	ret
	

text:
	call clsclr
	call printstr
	call timer
	call clsclr					;main func
	mov ax, 0x0002
    int 0x10

    mov ax, 0xb800              ; text data
    mov es, ax
    cld
buildgrid:
    mov word [curr_off], 1
    mov word [cell_ptr], board
    call add_new_cell
    call print_board
    call print_score
check_input:
    mov ah, 0                   
    int 0x16                    ;BIOS service for keyboard

    cmp ah, 0x48                ; Up Arrow
    je goup
    cmp ah, 0x11                ; W key
    je goup
	
    cmp ah, 0x50                ; Down Arrow
    je godown
    cmp ah, 0x1F                ; S key
    je godown
	
    cmp ah, 0x4d                ; Right Arrow
    je goright
    cmp ah, 0x20                ; D key
    je goright
	
	cmp ah, 0x4b                ; Left Arrow
    je goleft
    cmp ah, 0x1E                ; A key
    je goleft

    cmp al, 'r'                 ; R key for Restart
    je start_game
    cmp al, 'R'
    je start_game

    cmp ah, 0x1                 ; Esc to exit
    jne check_input
    jmp exit

goleft:
    mov bp, move_left
goright:
    mov bp, move_right
    jmp do_movement
goup:							;for each movement input 
    mov bp, move_up
    jmp do_movement
godown:
    mov bp, move_down
do_movement:
    mov al, byte [bp]
    cbw
    mov word [curr_off], ax
    
    mov al, byte [bp+1]
    cbw
    add ax, board       ; Add to board address (16-bit add)
    xor dx, dx
    mov dl, byte [bp+2]
    call compute_movement
    call print_board
%ifdef dos
    call system_time
%endif

    call check_win
    call check_loss
    jmp buildgrid

check_win:
    mov cx, 16
    mov si, board
check_win_loop:
    lodsb
    cmp al, 11 ; 2048 tile (2^11)
    je win_screen
    loop check_win_loop
    ret

check_loss:
    ; 1. Check for empty cells
    mov cx, 16
    mov si, board
check_empty_loop:
    lodsb
    cmp al, 0
    je not_loss ; Found empty cell, game continues
    loop check_empty_loop

    ; 2. Check Horizontal Merges
    ; Rows: 0,1,2,3; 4,5,6,7; etc.
    ; Check indices 0,1,2 (skip last in row)
    mov cx, 4 ; 4 rows
    mov bx, 0 ; Row start index
row_check_outer:
    push cx
    mov cx, 3 ; 3 pairs per row
    mov si, board
    add si, bx
row_check_inner:
    lodsb       ; Load current
    mov ah, al
    mov al, [si] ; Load next (si already incremented by lodsb)
    cmp ah, al
    je not_loss_pop ; Found match
    loop row_check_inner
    
    add bx, 4 ; Next row
    pop cx
    loop row_check_outer

    ; 3. Check Vertical Merges
    ; Cols: 0,4,8,12; 1,5,9,13; etc.
    ; Check indices 0,4,8 (skip last in col)
    mov cx, 4 ; 4 cols
    mov bx, 0 ; Col start index
col_check_outer:
    push cx
    mov cx, 3 ; 3 pairs per col
    mov si, board
    add si, bx
col_check_inner:
    lodsb       ; Load current
    mov ah, al
    ; Next is at si + 3 (since lodsb moved 1, need +3 to get +4 total)
    mov al, [si+3] 
    cmp ah, al
    je not_loss_pop ; Found match
    
    add si, 3 ; Move to next in col (si is at i+1, need i+4, so +3)
    loop col_check_inner
    
    inc bx ; Next col
    pop cx
    loop col_check_outer
    
    ; If we get here, NO moves possible.
    jmp loss_screen

not_loss_pop:
    pop cx
not_loss:
    ret

loss_screen:
    call clsclr
    mov ah, 0x13
    mov al, 1
    mov bh, 0
    mov bl, 0x04 ; Red
    mov dx, 0x0C20 ; Center screen
    mov cx, 9
    push cs
    pop es
    mov bp, str_loss
    int 0x10
    
    ; Wait for key to restart
    mov ah, 0
    int 0x16
    jmp start_game

win_screen:
    call clsclr
    mov ah, 0x13
    mov al, 1
    mov bh, 0
    mov bl, 0x0E ; Yellow
    mov dx, 0x0C20 ; Center screen
    mov cx, 8
    push cs
    pop es
    mov bp, str_win
    int 0x10
    
    ; Wait for key to restart
    mov ah, 0
    int 0x16
    jmp start_game


%ifdef dos
					; Wait time function
system_time:
    xor dx, dx
    mov cx, 5
    mov ah, 0x86
    int 0x0015
    mov ah, 0x0c
    int 0x0021
    ret
%endif              ;  This function will first count how many empty cells  
					;are there, then get a random cell and adds a random 2 in the place
add_new_cell:
%ifdef dos
    mov cx, 17                          ; Sets the board size               
    mov bp, board                       ; Gets the ptr to the board
    xor bx, bx                 			;for empty box
add_empty:
    mov dl, byte [bp]                   ; Gets the value of the current cell
    cmp dl, 0                           ; Checks if the current cell is empty
    jne _count_continue                 ; if not empty, iterate
    inc bl                              ; if empty,+1  zero counter
_count_continue:
    inc bp                              ; +1 the ptr to the next cell
    loop add_empty                   ; Iterate the counter
    cmp bl, 0                           ; Checks if there are empty cells
    je _add_new_cell_exit               ; if no empty cells just exit
    
    mov ah, 0x00                        ; bios for system time
    int 0x1a

    mov ax, dx                          ; coping interrupt time took
    xor dx, dx                          
    div bx             
    mov bh, dl                          ;remainder in dx

    mov cx, 16                          
    mov bp, board                       
    xor bl, bl
	
check_two:
    mov dl, byte [bp]                   ; Gets the value of the current cell
    cmp dl, 0                           ; Checks if it's an empty cell
    jne _check_item_loop                ;else loop
    cmp bl, bh                          ; comp if the curr count is random value we picked
    je _add_and_exit                    ; if yes the add another area/cell and leave
    inc bl                              ; +1 in the 0 count

_check_item_loop:
    inc bp                 
    loop check_two                    ;+1 to add another 2 in grid

_add_and_exit:
    and al, 1                           
    inc al                              
    mov byte [bp], al                   

_add_new_cell_exit:
    ret

%else
    mov cx, 17                          ; telling the board size               
    mov bp, board                       ; taking ptr to the board
add_empty:
    mov ah, byte [bp]                   ; Inputting the value of the current cell
    cmp ah, 0                           ; Checks if the current area is null
    je _add_and_exit
    inc bp                              ; increment the ptr to next cell
    loop add_empty                   	; loop the counter
_add_and_exit:
    mov byte [bp], 1                    ; Set the upper value to the board
    ret
%endif
    ;[curr_off] = the offset between elements
    ; dx = line offset
    ; ax = initial cell pointer
compute_movement:
    mov cx, 4
_compute_bound:
    mov word [cell_ptr], ax
    pusha
    call compute_board_line
    popa
    add ax, dx
    loop _compute_bound
    ret

    ; Computing the board line function as it compute a line/column of the board
    ; Params =  [curr_ptr] = Start of cell offset
    ;           [curr_off] = offset b/w items in directions
compute_board_line:
    mov cx, 3       ;Not leaving the boudary
	
_item:
    mov bp, [cell_ptr]	;each values in the cell
    mov ah, byte [bp]
    cmp ah, 0
    jne _add

_move:
    mov bx, cx
    mov bp, [cell_ptr]

_move_find:
    add bp, [curr_off]
    mov dl, byte [bp]
    cmp dl, 0			;is the same value found or not
    je _skip_move
    mov byte [bp], 0
    mov bp, [cell_ptr]
    mov byte [bp], dl
    jmp _item

_skip_move:
    dec bx			;Ignoring the cell with diff val
    cmp bx, 0
    jne _move_find
    jmp _return     ; If no non-zero value found, skip merge
 _add:
    mov bx, cx
    mov bp, [cell_ptr]

add_find:
    add bp, [curr_off]
    mov dl, byte [bp]
    cmp dl, 0
    je _skip_add
    cmp dl, ah
    jne _return
    mov byte [bp], 0
    mov bp, [cell_ptr]
    inc byte [bp]
    
    ; Update Score
    pusha
    mov cl, byte [bp] ; The new exponent value
    mov ax, 1
    shl ax, cl        ; Calculate 2^cl
    add [score], ax   ; Add to score
    popa

    jmp _return

_skip_add:
    dec bx
    cmp bx, 0
    jne add_find

_return:
    mov bx, [curr_off]
    add [cell_ptr], bx
    loop _item
    ret
	
    ; Printing the board function
print_board:
    mov cx, 16                          
_loop_cell:
    pusha                               
    mov al, cl                          
    dec al                              
    call print_cell
    popa
    loop _loop_cell


    ret


    ;
    ; Print cell function
    ; Params:   AL - board index
    ;
print_cell:
    xor ah, ah                          ; Resets AH
    mov bp, board
    mov [cell_ptr], bp
    add [cell_ptr], al

    xor ch, ch
    mov bx, [cell_ptr]                   ; ptr to the board
    mov cl, byte [bx]                   ; Gets actual value on the board
    xor bl, bl
%ifdef dos
    mov bp, board_colors                ; ptr to the first color
    add bp, cx                          ; Adds the value id to color ptr
    mov bh, [bp]                        ; value of the color
%else
    mov bh, 0x1f
    shl cl, 4
    add bh, cl
%endif
	
    push bx                             ; c3ll color
    push 0x0306                         ; cell size

    mov bx, row_offset            		; Gets the row offset
    xor ch, ch                          ; Resets CX
    mov cl, al
    shr cl, 2                           ; div by four ass 4 cells
    shl cl, 1                           ; the size is word
    add bx, cx                          ; + id to the ptr
    mov cx, word [bx]                   
    mov [curr_off], cx            
    push cx                          

    mov bl, 4
    div bl                              ; div the i by 4
    shr ax, 8                           ;taking r from div since the loop will be 3 for rows and cols
    mov bx, col_offset                  
    add bx, ax                         
    xor ch, ch                        
    mov cl, byte [bx]            
    add [curr_off], cx            ; Adds it to current_offset, to be used on the number
    push cx                            

    call constbox
    add sp, 6                           ; remove par but not the draws

    mov bx, [curr_off]                  ;total board cell
    add bx, 162                         ; + line an dthe char
    push bx                             ;number print 

    mov bx, [cell_ptr]                ; ptr in  board
    mov cl, byte [bx]                   ; Gets actual value on the board
    cmp cl, 0
    je exit3
    mov ax, 1
    shl ax, cl
    call print_number
exit3:
    add sp, 4                           ; Removes parameters from stack
    ret

    ; Draw box function
    ; Params:   [bp+2] - row offset
    ;           [bp+4] - column offset
    ;           [bp+6] - box dimensions
    ;           [bp+8] - char/Color
   constbox:
    mov bp, sp                      ; Store the base of the stack, to get arguments
    xor di, di                      ; Sets DI to screen origin
    add di, [bp+2]                  ; Adds the row offset to DI

    mov dx, [bp+6]                  ; copy sides of the box
    mov ax, [bp+8]                  ; copy color to print
    mov bl, dh                      ; Get the height of the box

    xor ch, ch              
    mov cl, dl                      ; Copy the width of the box
    add di, [bp+4]                  ; Adds the line offset to DI
    rep stosw

    add word [bp+2], 160            
    sub byte [bp+7], 0x01           ; height is in msb 
    mov cx, [bp+6]                  ; Copy the size of the box to test
    cmp ch, 0                       ; height of box
    jnz constbox                    ; If not zero, draw the rest of the box
    ret
	
    ; ax =  num value
    ; [bp+2] =  position
    ;  [bp+4] = color
print_number:
%ifdef dos
    cmp ax, 0
    je exit1
%endif
    mov bp, sp
    mov di, [bp+2]
    xor cx, cx
get_unit:
    cmp ax, 0
    je copy
    xor dx, dx
    mov bx, 10
    div bx
    xor bx, bx
    mov bl, dl
    push bx
    inc cx
    jmp get_unit

copy:
    pop ax
    add al, '0'         ; Add 0 to value for the empty boxes 0+0 = 0
    mov ah, byte [bp+5]             ; Copy color box 
    stosw
    loop copy
exit1:
    ret
exit:
    int 0x20  ; exit/end of line


%ifdef dos
board_colors:
   ;0,2,4,8,16,32,64,128,256,512,1024,2048
db 0x00,0x2f,0x1f,0x4f,0x5f,0x6f,0x79,0x29,0x15,0xce,0xdc,0x8e
%endif
cell_ptr: dw 0x0000
curr_off: dw 0x0000

row_offset:
    dw 160*6,  160*10, 160*14, 160*18

col_offset:
    db 48, 66, 84, 102

move_up:    db 4, 0, 1
move_left:  db 1, 0, 4
move_right: db -1, 3, 4
move_down:  db -4, 12, 1
board:
    db 0,0,0,0
    db 0,0,0,0
    db 0,0,0,0
    db 0,0,0,0

str0:db 'Name: Sohaib Ahmed'
str1:db 'retro 2048'
str_win: db 'YOU WIN!'
str_loss: db 'GAME OVER'
str_score: db 'Score: '
score: dw 0

print_score:
    push es
    pusha
    mov ax, 0xb800
    mov es, ax
    
    ; Print "Score: "
    mov di, 160*2 + 10 ; Row 2, slightly indented
    mov si, str_score
    mov cx, 7
    mov ah, 0x1E       ; Yellow on Blue
print_score_label:
    lodsb
    stosw
    loop print_score_label
    
    ; Print Score Value
    mov ax, [score]
    call print_number_at
    
    popa
    pop es
    ret

; Print number in AX at DI
print_number_at:
    mov bx, 10
    xor cx, cx
get_digits:
    xor dx, dx
    div bx
    push dx
    inc cx
    cmp ax, 0
    jne get_digits
    
print_digits:
    pop ax
    add al, '0'
    mov ah, 0x1E
    stosw
    loop print_digits
    ret
