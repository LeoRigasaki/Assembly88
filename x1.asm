[org 0x0100]
							; call the text for the text mode as well enter in mainloop for grid build
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
check_input:
    mov ah, 0                   
    int 0x16                    ;BIOS service for keyboard

    cmp ah, 0x48                ;up
    je goup
	
    cmp ah, 0x50                ;down
    je godown
	
    cmp ah, 0x4d                ; right
    je goright
	
	cmp ah, 0x4b                ;left
    je goleft

    cmp ah, 0x1                 ; We need it to exit the game
    jne check_input
    jmp exit

goleft:
    mov bp, move_left
    jmp do_movement
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
    mov ax, board
    add al, byte [bp+1]
    xor dx, dx
    mov dl, byte [bp+2]
    call compute_movement
    call print_board
%ifdef dos
    call system_time
%endif

    jmp buildgrid


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
 _add:
    mov bx, cx
    mov bp, [cell_ptr]

add
_find:
    add bp, [curr_off]
    mov dl, byte [bp]
    cmp dl, 0
    je _skip_add
    cmp dl, ah
    jne _return
    mov byte [bp], 0
    mov bp, [cell_ptr]
    inc byte [bp]

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
    mov cx, 17                          
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
